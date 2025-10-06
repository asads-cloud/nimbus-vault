data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  # --- Build statements safely (skip empty admin list) ---
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
        "kms:Encrypt","kms:Decrypt","kms:ReEncrypt*",
        "kms:GenerateDataKey*","kms:DescribeKey"
      ]
      Resource = "*"
    }
  ]

  # Only include this statement when there are principals to add
  additional_admin_statement = length(var.additional_admin_arns) > 0 ? [{
    Sid      = "EnableAdditionalAdmins"
    Effect   = "Allow"
    Principal = { AWS = var.additional_admin_arns }
    Action   = "kms:*"
    Resource = "*"
    # Correct condition operator/key
    Condition = {
      ArnLike = { "aws:PrincipalArn" = "arn:aws:iam::*:role/*" }
    }
  }] : []

  statements = concat(local.base_statements, local.additional_admin_statement)
}

resource "aws_kms_key" "cmk" {
  for_each                = var.key_map
  description             = each.value.description
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.statements
  })
}

resource "aws_kms_alias" "this" {
  for_each      = var.key_map
  name          = each.value.alias        # ensure this already starts with "alias/"
  target_key_id = aws_kms_key.cmk[each.key].key_id
}
