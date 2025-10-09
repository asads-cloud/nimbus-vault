data "aws_region" "current" {}

# Enable Security Hub for this account/region
resource "aws_securityhub_account" "this" {}

# Build ARNs for standards in the current region
locals {
  fsbp_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
  cis_arn  = "arn:aws:securityhub:${data.aws_region.current.name}::standards/cis-aws-foundations-benchmark/v/${var.cis_version}"
}

# Subscribe to FSBP (recommended)
resource "aws_securityhub_standards_subscription" "fsbp" {
  count        = var.enable_fsbp ? 1 : 0
  standards_arn = local.fsbp_arn
  depends_on    = [aws_securityhub_account.this]
}

# Subscribe to CIS
resource "aws_securityhub_standards_subscription" "cis" {
  count        = var.enable_cis ? 1 : 0
  standards_arn = local.cis_arn
  depends_on    = [aws_securityhub_account.this]
}

output "enabled_standards" {
  value = compact([
    var.enable_fsbp ? local.fsbp_arn : "",
    var.enable_cis  ? local.cis_arn  : ""
  ])
}
