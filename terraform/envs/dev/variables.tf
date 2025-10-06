variable "env" {
  description = "Deployment environment (dev|prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "vault-admin"
}