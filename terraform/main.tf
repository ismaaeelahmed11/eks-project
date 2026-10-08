module "vpc" {
  source   = "./modules/vpc"
  name     = var.project_name
  vpc_cidr = "10.0.0.0/16"
}

module "eks" {
  source             = "./modules/eks"
  name               = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "oidc" {
  source      = "./modules/oidc"
  name        = var.project_name
  github_repo = "ismaaeelahmed11/eks-project"
}