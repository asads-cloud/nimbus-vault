variable "name_prefix" {
  description = "Global name prefix, usually 'nimbus'"
  type        = string
  default     = "nimbus"
}
variable "env" {
  description = "Environment (dev|prod)"
  type        = string
  validation {
    condition     = contains(["dev","prod"], var.env)
    error_message = "env must be one of: dev, prod."
  }
}
variable "region" {
  description = "AWS region (e.g., eu-west-2)"
  type        = string
}

locals {
  suffix = "${var.env}-${var.region}"

  buckets = {
    raw       = "${var.name_prefix}-raw-${local.suffix}"
    curated   = "${var.name_prefix}-curated-${local.suffix}"
    published = "${var.name_prefix}-published-${local.suffix}"
    logs      = "${var.name_prefix}-logs-${local.suffix}"
    athena    = "${var.name_prefix}-athena-${local.suffix}"
    tmp       = "${var.name_prefix}-tmp-${local.suffix}"
  }

  glue_dbs = {
    transcripts = "${var.name_prefix}_transcripts_${var.env}"
    entities    = "${var.name_prefix}_entities_${var.env}"
    segments    = "${var.name_prefix}_segments_${var.env}"
  }

  kms_alias        = "alias/${var.name_prefix}-data-${var.env}"
  athena_workgroup = "${var.name_prefix}_${var.env}_wg"
}

output "bucket_names"     { value = local.buckets }
output "glue_databases"   { value = local.glue_dbs }
output "kms_alias"        { value = local.kms_alias }
output "athena_workgroup" { value = local.athena_workgroup }
