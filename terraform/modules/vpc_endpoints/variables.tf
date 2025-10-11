variable "env" { type = string }

variable "vpc_id" {
  description = "Target VPC for endpoints"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnets for Interface endpoints (ENIs). Use private subnets."
  type        = list(string)
}

variable "route_table_ids" {
  description = "Route tables to attach for S3 Gateway endpoint"
  type        = list(string)
}

variable "create_security_group" {
  description = "Create a dedicated SG for interface endpoints"
  type        = bool
  default     = true
}

variable "allowed_cidrs" {
  description = "CIDRs allowed to connect to the interface endpoints (port 443)"
  type        = list(string)
  default     = ["10.0.0.0/8","172.16.0.0/12","192.168.0.0/16"] # adjust to your VPCs
}
