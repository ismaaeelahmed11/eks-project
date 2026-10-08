variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name used as a prefix"
  type        = string
  default     = "eks-project"
}

variable "domain_name" {
  description = "Domain for the application"
  type        = string
  default     = "eks.ismaaeelahmed.co.uk"
}