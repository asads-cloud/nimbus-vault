module "naming" {
  source    = "../../modules/naming"
  name_prefix = var.name_prefix
  env       = var.env
  region = var.region
}

# Expose for visibility (after apply)
output "bucket_names"   { value = module.naming.bucket_names }
output "glue_databases" { value = module.naming.glue_databases }
output "kms_alias"      { value = module.naming.kms_alias }
output "athena_workgroup" { value = module.naming.athena_workgroup }
