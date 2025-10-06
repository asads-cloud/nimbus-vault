variable "name_prefix" {
  type        = string
  description = "Naming prefix for resources"
  default     = "vault"
}

provider "aws" {
  region  = var.region
  profile = var.profile

  default_tags {
    tags = {
      Project     = "nimbus-vault"
      Environment = var.env
    }
  }
}
