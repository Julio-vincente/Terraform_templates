provider "aws" {
    region = var.aws_region
}

module "networking" {
  source = "./modules/networking"
}

module "security" {
  source = "./modules/security"
}

module "dns" {
  source = "./modules/dns"
}

module "compute" {
  source = "./modules/compute"
}

module "APIs" {
  source = "./modules/APIs"
}