provider "aws" {
  region = "ap-south-1"
  alias  = "mumbai"

  default_tags {
    tags = {
      "type"    = "Terraform"
      "Project" = "aws-test"
      "purpose" = "Automation"
    }
  }
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
}

terraform {
  backend "s3" {
    bucket = "terraform-statefiles-oct-ap-south1"
    key    = "dev/terraform.tfstate"
    region = "ap-south-1"
  }

  required_version = ">= 1.5.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.44"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.default.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.default.token
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.default.token
  apply_retry_count      = 5
  load_config_file       = false
}