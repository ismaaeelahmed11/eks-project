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

module "irsa" {
  source            = "./modules/irsa"
  name              = var.project_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
}

module "oidc" {
  source      = "./modules/oidc"
  name        = var.project_name
  github_repo = "ismaaeelahmed11/eks-project"
}

