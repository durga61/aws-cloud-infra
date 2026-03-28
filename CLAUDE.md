# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Primary Terraform Working Directory

All infrastructure lives under:
```
terraform/eks-alb-argocd-dns-cert-monitoring/
```

Run all Terraform commands from this directory.

## Common Commands

```bash
# Initialize (required after provider/module changes)
terraform init

# Plan changes
terraform plan

# Apply infrastructure
terraform apply --auto-approve

# Destroy infrastructure (manual only — also available via destroy-infra workflow)
terraform destroy --auto-approve

# Format check (enforced in CI)
terraform fmt -check -recursive

# Auto-fix formatting
terraform fmt -recursive

# Update kubeconfig after cluster creation
aws eks update-kubeconfig --name eks-dev --region ap-south-1
```

## CI/CD Workflows

| Workflow | Trigger | Action |
|---|---|---|
| `create-infra.yml` | push/PR to main, manual dispatch | fmt → init → validate → plan (PR) → apply (push) |
| `destroy-infra.yml` | manual dispatch only | terraform destroy |
| `terraform-fmt.yml` | push/PR to main | formatting check |
| `trivy.yml` | push/PR to main | IaC vulnerability scan (CRITICAL/HIGH) |

- Terraform apply has **3 retry attempts** with 30-second intervals.
- AWS authentication uses **OIDC** (no stored credentials).
- Terraform state is stored in S3: `terraform-statefiles-jun25-ap-south1` (region: `ap-south-1`, key: `dev/terraform.tfstate`).

## Architecture

### Core Stack

- **EKS cluster** (`2-eks.tf`) using the `terraform-aws-modules/eks` module
- **VPC** (`1-vpc.tf`) with public/private subnets across multiple AZs; subnets are tagged for ALB/NLB discovery (`kubernetes.io/role/elb`, `kubernetes.io/role/internal-elb`)
- **AWS provider** (`0-aws-provider.tf`): region `ap-south-1`, alias `mumbai`

### Provider Versions

- `hashicorp/aws` ~> 6.9.0
- `hashicorp/helm` >= 2.13.0
- `hashicorp/kubernetes` 2.23.0
- `alekc/kubectl` >= 2.0.3
- Terraform >= 1.5.3

### Add-ons Deployed via Terraform/Helm (numbered files = deployment order)

| File | Component |
|---|---|
| `3-iam.tf`, `4-autoscaler-iam.tf` | IAM roles and IRSA for cluster autoscaler |
| `5-autoscaler-manifest.tf` | Cluster Autoscaler (Helm) |
| `7-helm-load-balancer-controller.tf`, `15-aws-lbc.tf` | AWS Load Balancer Controller |
| `8-argocd.tf` | ArgoCD (GitOps) |
| `9-image-updater.tf` | ArgoCD Image Updater |
| `10-monitoring.tf` | kube-prometheus-stack (Prometheus + Grafana) |
| `11-External-DNS-Cert-Manager-Nginx-ingress.tf` | ExternalDNS, cert-manager, NGINX Ingress |
| `13-metrics-server.tf` | Metrics Server (required for HPA) |
| `16-external-secret-irsa.tf` | External Secrets Operator with IRSA |
| `17-nginx-ingress.tf` | NGINX Ingress Controller |

Helm chart values are in `terraform/eks-alb-argocd-dns-cert-monitoring/values/`.
IAM policy documents are in `terraform/eks-alb-argocd-dns-cert-monitoring/iam/`.

### Other Terraform Modules

- `terraform/appconfig/` — AWS AppConfig resources
- `terraform/cert-example/` — Certificate management examples

## Key Debugging Commands

```bash
# Check autoscaler / AWS LBC logs
kubectl logs -f -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --all-containers=true --prefix
kubectl logs -f -n kube-system -l app.kubernetes.io/name=karpenter

# Verify IRSA permissions for Karpenter
kubectl auth can-i get ec2nodeclasses.karpenter.k8s.aws --as=system:serviceaccount:kube-system:karpenter --all-namespaces

# Test routing before DNS propagation
curl -i --header "Host: myapp.example.com" http://<elb-hostname>/path
```

## Important Notes

- `.tfvars` files are gitignored — never commit secrets or variable files with credentials.
- The `trivy` scan targets `./terraform/eks-alb-argocd-dns-cert-monitoring` — keep IaC clean of CRITICAL/HIGH findings.
- All providers (kubernetes, helm, kubectl) authenticate to EKS using the cluster endpoint and a token from `data.aws_eks_cluster_auth`.

---

## Known Gaps & Recommendations

### Immediate / Broken Config (fix before applying)

| Issue | File | Action |
|-------|------|--------|
| `local.cluster_name` is undefined | `1-vpc.tf`, `2-eks.tf:8` | Add `cluster_name = "eks"` (or similar) to locals in `1-vpc.tf` |
| `.terraform.lock.hcl` is gitignored | `.gitignore:35` | Remove the lock file entry — it should be committed for reproducibility |
| ArgoCD runs with `--insecure` | `values/argocd.yaml:8` | Remove `--insecure`; configure TLS via cert-manager/ingress instead |

### Security Hardening

| Issue | File | Action |
|-------|------|--------|
| No EKS control plane logging | `2-eks.tf` | Add `cluster_enabled_log_types = ["api", "audit", "authenticator"]` |
| No etcd secrets encryption | `2-eks.tf` | Add `cluster_encryption_config` with a KMS CMK |
| No Terraform state locking | `0-aws-provider.tf` | Add `dynamodb_table = "terraform-lock"` to S3 backend block |
| EKS public API unrestricted | `2-eks.tf:12` | Add `public_access_cidrs = ["<your-ip>/32"]` or disable public access |
| External Secrets IAM wildcard | `16-external-secret-irsa.tf` | Scope `Resource` to specific secret ARNs instead of `"*"` |
| OIDC role ARN hardcodes account ID | `create-infra.yml:34`, `destroy-infra.yml:27` | Move to a GitHub Actions variable/secret |

### Operational Gaps

| Issue | File | Action |
|-------|------|--------|
| No `variables.tf` / `outputs.tf` | `terraform/eks-alb-argocd-dns-cert-monitoring/` | Extract hardcoded locals into proper variables with validation; add outputs for cluster endpoint, name, VPC ID |
| No resource requests/limits | All `values/*.yaml` | Add `resources.requests` and `resources.limits` to all Helm chart values |
| Karpenter uses deprecated `v1beta1` API | `2-eks.tf` | Migrate `EC2NodeClass` and `NodePool` to `karpenter.k8s.aws/v1` / `karpenter.sh/v1` |
| Single NAT Gateway (no HA) | `1-vpc.tf` | Set `one_nat_gateway_per_az = true`, `single_nat_gateway = false` for production |
| Monitoring / DNS / cert-manager commented out | `10-monitoring.tf`, `11-*.tf` | Re-enable or remove the dead code |
| NetworkPolicy disabled in prometheus stack | `kube-prometheus-stack-values.yaml` | Set `networkPolicy.enabled: true` |
| Pre-commit tflint/trivy hooks disabled | `.pre-commit-config.yaml` | Uncomment `terraform_tflint` and `terraform_trivy` hooks |

### CI/CD Gaps

| Issue | File | Action |
|-------|------|--------|
| No scheduled drift detection | `.github/workflows/` | Add a workflow that runs `terraform plan` on a cron schedule |
| No cost estimation | `.github/workflows/` | Add [Infracost](https://www.infracost.io/) step to `create-infra.yml` |
| Trivy SARIF output not uploaded | `trivy.yml` | Fix the `output` and `upload-sarif` steps to generate and publish results to GitHub Security tab |
