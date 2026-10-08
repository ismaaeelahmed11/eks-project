terraform {
  backend "s3" {
    bucket       = "eks-project-tfstate-777285773915"
    key          = "eks-project/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true
  }
}