# EKS Infrastructure with ArgoCD, ALB, DNS, and Monitoring

This Terraform configuration sets up a production-ready EKS cluster with essential components including ArgoCD, AWS Load Balancer Controller, External DNS, Cert Manager, and Prometheus monitoring.

## Infrastructure Components

### Core Infrastructure
- **VPC Setup** (`1-vpc.tf`)
  - Highly available VPC across multiple AZs
  - Public and private subnets
  - NAT Gateway for private subnet connectivity
  - Proper tagging for EKS and Karpenter integration

- **EKS Cluster** (`2-eks.tf`)
  - Managed EKS cluster
  - Node groups configuration
  - Cluster security groups

### IAM and Security
- **IAM Roles and Policies** (`3-iam.tf`, `4-autoscaler-iam.tf`)
  - Service accounts for various components
  - Required IAM roles for EKS operation
  - Cluster autoscaler IAM configuration

### Kubernetes Add-ons
- **Cluster Autoscaler** (`5-autoscaler-manifest.tf`)
  - Automatic node scaling based on workload
  
- **AWS Load Balancer Controller** (`15-aws-lbc.tf`)
  - Manages AWS ALB/NLB for Kubernetes services
  - Integrates with Ingress resources

- **ArgoCD** (`8-argocd.tf`)
  - GitOps continuous delivery tool
  - Image Updater for automated image updates (`9-image-updater.tf`)

- **DNS and Certificates**
  - External DNS for automatic DNS management
  - Cert Manager for SSL/TLS certificate automation
  - NGINX Ingress Controller

- **Monitoring Stack** (`10-monitoring.tf`)
  - Prometheus for metrics collection
  - Grafana for visualization
  - Metrics Server for HPA support (`13-metrics-server.tf`)

## Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- kubectl
- helm

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the planned changes:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration

The infrastructure is configured through various Terraform files:

- `0-aws-provider.tf`: AWS provider configuration
- `1-vpc.tf`: VPC and networking setup
- `2-eks.tf`: EKS cluster configuration
- `3-iam.tf` & `4-autoscaler-iam.tf`: IAM roles and policies
- `5-autoscaler-manifest.tf`: Cluster Autoscaler setup
- `8-argocd.tf`: ArgoCD installation
- `10-monitoring.tf`: Prometheus/Grafana stack
- `15-aws-lbc.tf`: AWS Load Balancer Controller

## Important Variables

The main configuration variables are defined in the `locals` block:
- `cluster_name`: Name of the EKS cluster
- `region`: AWS region for deployment
- `environment`: Environment name (e.g., dev, prod)
- `domain`: Domain name for the cluster
- Various resource tags for proper resource management

## Monitoring

The monitoring stack is configured using `kube-prometheus-stack-values.yaml` and includes:
- Prometheus for metrics collection
- Grafana for visualization
- AlertManager for alerting
- Various exporters for system and Kubernetes metrics

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
