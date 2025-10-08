data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  # --- Base KMS policy statements ---
  base_statements = [
    {
      Sid      = "EnableRootAdmin"
      Effect   = "Allow"
      Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }
      Action   = "kms:*"
      Resource = "*"
    },
    {
      Sid    = "AllowUseWithinAccount"
      Effect = "Allow"
      Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      Resource = "*"
    }
  ]

  # --- additional admin roles ---
  additional_admin_statement = length(var.additional_admin_arns) > 0 ? [{
    Sid      = "EnableAdditionalAdmins"
    Effect   = "Allow"
    Principal = { AWS = var.additional_admin_arns }
    Action   = "kms:*"
    Resource = "*"
    Condition = {
      ArnLike = { "aws:PrincipalArn" = "arn:aws:iam::*:role/*" }
    }
  }] : []

  # --- CloudTrail permissions (only for the audit key) ---
  cloudtrail_statement = [{
    Sid      = "AllowCloudTrailUseOfKey"
    Effect   = "Allow"
    Principal = { Service = "cloudtrail.amazonaws.com" }
    Action   = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    Resource = "*"
    Condition = {
      StringLike = {
        "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:aws:cloudtrail:${data.aws_region.current.name}:${local.account_id}:trail/*"
      }
    }
  }]
}

# --- Create one CMK per key_map entry ---
resource "aws_kms_key" "cmk" {
  for_each                = var.key_map
  description             = each.value.description
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      local.base_statements,
      local.additional_admin_statement,
      each.key == "audit" ? local.cloudtrail_statement : []
    )
  })
}

# --- Create aliases for all keys ---
resource "aws_kms_alias" "this" {
  for_each      = var.key_map
  name          = each.value.alias        # ensure this already starts with "alias/"
  target_key_id = aws_kms_key.cmk[each.key].key_id
}
