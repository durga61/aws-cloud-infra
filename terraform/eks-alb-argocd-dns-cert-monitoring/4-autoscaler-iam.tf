# module "cluster_autoscaler_irsa_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "5.30.0"

#   role_name                        = "cluster-autoscaler"
#   attach_cluster_autoscaler_policy = true
#   cluster_autoscaler_cluster_names = [module.eks.cluster_name]

#   oidc_providers = {
#     ex = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:cluster-autoscaler"]
#     }
#   }
# }

# # Cert Manager IRSA
# module "cert_manager_irsa_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "5.30.0"

#   role_name                     = "cert-manager"
#   attach_cert_manager_policy    = true
#   cert_manager_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z02682411LNVGL09UV93I"] # Lab HostedZone

#   oidc_providers = {
#     eks = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:cert-manager"]
#     }
#   }

#   tags = local.tags
# }

# # External DNS IRSA
# module "external_dns_irsa_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "5.30.0"

#   role_name                     = "external-dns"
#   attach_external_dns_policy    = true
#   external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/Z02682411LNVGL09UV93I"] # Lab HostedZone

#   oidc_providers = {
#     eks = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:external-dns"]
#     }
#   }

#   tags = local.tags
# }
