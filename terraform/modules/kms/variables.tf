variable "env" {
  description = "Deployment environment (dev|prod)"
  type        = string
}

variable "key_map" {
  description = "Map of key_id => { description, alias }"
  type = map(object({
    description = string
    alias       = string # must include the 'alias/' prefix, e.g., alias/nimbus-raw-dev
  }))
}

variable "additional_admin_arns" {
  description = "Extra principals with admin on the keys (e.g., break-glass role). If empty, statement is omitted."
  type        = list(string)
  default     = []
}
