locals {
  name_prefix = "nimbus"
  region      = var.region
  env         = var.env

  # Standardized names
  buckets = {
    raw       = "${local.name_prefix}-raw-${local.env}-${local.region}"
    curated   = "${local.name_prefix}-curated-${local.env}-${local.region}"
    published = "${local.name_prefix}-published-${local.env}-${local.region}"
    audit     = "${local.name_prefix}-audit-${local.env}-${local.region}"
  }

  # KMS aliases per brief
  kms_alias_data  = "alias/nimbus-data-${local.env}"
  kms_alias_token = "alias/nimbus-token-${local.env}"
}
