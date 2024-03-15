locals {
  domain = "durgadevops.online"
  name   = "EKS-DNS-setup"
  region = "ap-south-1"

  tags = {
    Environment = "sandbox"
    Project     = "EKS-DNS-setup"
    terraform   = "true"
    Owner       = "Durgaprasad"
  }
}
