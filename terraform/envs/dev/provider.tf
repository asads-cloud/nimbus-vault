variable "region" {
  type        = string
  description = "AWS region for this environment"
  default     = "eu-west-1"
}
variable "env" {
  type        = string
  description = "Environment name"
  default     = "dev"
}
variable "name_prefix" {
  type        = string
  description = "Naming prefix for resources"
  default     = "vault"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = "nimbus-vault"
      Environment = var.env
    }
  }
}
