locals {
  cluster_name = "cluster"
  az_count     = length(data.aws_availability_zones.available.zone_ids)
  cluster_sbunet_cidr_size = local.az_count > 3 ? 22 :21
  domain = "durgadevops.online"
  name   = "EKS-DNS-setup"
  region = "ap-south-1"
  environment = "dev"

  tags = {
    Environment = "sandbox"
    Project     = "EKS-DNS-setup"
    terraform   = "true"
    Owner       = "Durgaprasad"
  }
}   
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "main"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b",]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery" = "${local.cluster_name}-${local.environment}"
  }

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}