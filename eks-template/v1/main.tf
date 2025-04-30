provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/Networking"
}

module "iam" {
  source = "./modules/IAM"
  
}

module "eks" {
  source        = "./modules/EKS"
  subnet_pub1a  = module.networking.subnet_pub1a
  subnet_pub1b  = module.networking.subnet_pub1b
  subnet_priv1b = module.networking.subnet_priv1b
  subnet_priv1a = module.networking.subnet_priv1a
  k8s_role_arn  = module.iam.k8s_role_arn
  node-role-arn = module.iam.node-role-arn
}
