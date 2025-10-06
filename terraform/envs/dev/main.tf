module "naming" {
  source      = "../../modules/naming"
  name_prefix = var.name_prefix
  env         = var.env
  region      = var.region
}

# Expose for visibility (after apply)
output "bucket_names" { value = module.naming.bucket_names }
output "glue_databases" { value = module.naming.glue_databases }
output "kms_alias" { value = module.naming.kms_alias }
output "athena_workgroup" { value = module.naming.athena_workgroup }



#------------ KMS MODULE -----------------------------

module "kms" {
  source = "../../modules/kms"
  env    = var.env

  key_map = {
    raw = {
      description = "Nimbus Vault raw bucket CMK (${var.env})"
      alias       = "alias/nimbus-raw-${var.env}"
    }
    curated = {
      description = "Nimbus Vault curated bucket CMK (${var.env})"
      alias       = "alias/nimbus-curated-${var.env}"
    }
    published = {
      description = "Nimbus Vault published bucket CMK (${var.env})"
      alias       = "alias/nimbus-published-${var.env}"
    }
    audit = {
      description = "Nimbus Vault audit/logs CMK (${var.env})"
      alias       = "alias/nimbus-audit-${var.env}"
    }
    token = {
      description = "Nimbus Vault tokenisation CMK (${var.env})"
      alias       = "alias/nimbus-token-${var.env}"
    }
  }

  # add a break-glass or security-admin role once created in IAM
  additional_admin_arns = []
}








# Placeholder root; modules will be wired here in next steps.

# Example: we’ll add child modules like:
# module "kms" { source = "../../modules/kms"; environment = var.environment; aws_region = var.aws_region }
# module "cloudtrail" { ... }
# module "config" { ... }
# module "guardduty" { ... }
# module "securityhub" { ... }
# module "vpc_endpoints" { ... }
