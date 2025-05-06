# The module creates a Helm release for the External Secrets Operator and Reloader.
# The Helm releases are configured using values files located in the "values" directory.
# This module creates an IAM role for the External Secrets Operator to access AWS Secrets Manager.
# It uses the terraform-aws-modules/iam/aws module to create the role and attach the necessary policies.

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  version          = "0.16.1"

  values = [file("values/external-secrets-values.yaml")]

  depends_on = [module.eks, helm_release.karpenter, kubectl_manifest.karpenter_node_pool]
}

resource "helm_release" "reloader" {
  name             = "reloader"
  repository       = "https://stakater.github.io/stakater-charts"
  chart            = "stakater-charts"
  namespace        = "reloader"
  create_namespace = true

  values = [file("values/reloader-values.yaml")]
  depends_on = [module.eks, helm_release.karpenter, kubectl_manifest.karpenter_node_pool]
}

module "external_secrets_irsa_role" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.20.0"

  role_name                     = "external-secrets-irsa"
  attach_external_secrets_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:external-secrets-sa"]
    }
  }

  role_policy_arns = [
    aws_iam_policy.external_secrets.arn
  ]
}

resource "aws_iam_policy" "external_secrets" {
  name        = "external-secrets-policy"
  description = "Policy for External Secrets Operator"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = "*"
      }
    ]
  })
}

output "external_secrets_irsa_role_arn" {
  description = "ARN of IAM role for external-secrets"
  value       = module.external_secrets_irsa_role.iam_role_arn
}