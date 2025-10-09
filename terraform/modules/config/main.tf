data "aws_caller_identity" "me" {}
data "aws_region" "current" {}

# Allow AWS Config to write to the chosen bucket/prefix.
data "aws_iam_policy_document" "config_bucket_policy" {
  statement {
    sid     = "AWSConfigBucketPermissionsCheck"
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl", "s3:ListBucket", "s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::${var.delivery_bucket_name}"]
  }

  statement {
    sid     = "AWSConfigDeliveryWrite"
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.delivery_bucket_name}/${var.delivery_prefix}/AWSLogs/${data.aws_caller_identity.me.account_id}/*"]

    # Require SSE-KMS with our CMK (BucketOwnerEnforced -> no ACL condition)
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [var.delivery_bucket_kms_alias] # pass a KEY ARN from env
    }
  }
}

# Attach/merge with existing bucket policy if needed; here we manage it directly.
resource "aws_s3_bucket_policy" "audit_append_config" {
  bucket = var.delivery_bucket_name
  policy = data.aws_iam_policy_document.config_bucket_policy.json
}

# IAM role for AWS Config recorder
data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "config_role" {
  name               = "nimbus-config-recorder-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# Inline policy granting AWS Config the minimum it needs
data "aws_iam_policy_document" "config_inline" {
  # Allow Config to record/describe configuration
  statement {
    effect  = "Allow"
    actions = [
      "config:Put*",
      "config:Get*",
      "config:List*",
      "config:Describe*"
    ]
    resources = ["*"]
  }

  # Allow reads on the delivery bucket itself
  statement {
    effect  = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = ["arn:aws:s3:::${var.delivery_bucket_name}"]
  }

  # Allow AWS Config to read IAM resource metadata (needed for IAM resource recording)
  statement {
    effect = "Allow"
    actions = [
      "iam:Get*",
      "iam:List*",
      "iam:GenerateCredentialReport"
    ]
    resources = ["*"]
  }

  # Allow writes to our specific prefix, requiring SSE-KMS with our CMK
  statement {
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${var.delivery_bucket_name}/${var.delivery_prefix}/AWSLogs/${data.aws_caller_identity.me.account_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [var.delivery_bucket_kms_alias] # key ARN from env
    }
  }
}

resource "aws_iam_role_policy" "config_inline" {
  name   = "nimbus-config-inline"
  role   = aws_iam_role.config_role.id
  policy = data.aws_iam_policy_document.config_inline.json
}


# Configuration Recorder
resource "aws_config_configuration_recorder" "this" {
  name     = "nimbus-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

# Delivery Channel (to audit bucket, under our prefix)
resource "aws_config_delivery_channel" "this" {
  name           = "nimbus-delivery"
  s3_bucket_name = var.delivery_bucket_name
  s3_key_prefix  = var.delivery_prefix
  s3_kms_key_arn = var.delivery_bucket_kms_alias

  depends_on = [
    aws_s3_bucket_policy.audit_append_config,
    aws_config_configuration_recorder.this
  ]
}

# Turn it on
resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

# ----- Managed Rules (S3 baseline)

# 1) Encryption at rest
resource "aws_config_config_rule" "s3_encryption" {
  name = "s3-bucket-server-side-encryption-enabled"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder_status.this]
}

# 2) No public read
resource "aws_config_config_rule" "s3_public_read_block" {
  name = "s3-bucket-public-read-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  depends_on = [aws_config_configuration_recorder_status.this]
}

# 3) No public write
resource "aws_config_config_rule" "s3_public_write_block" {
  name = "s3-bucket-public-write-prohibited"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }
  depends_on = [aws_config_configuration_recorder_status.this]
}

# 4) MFA delete enabled (flags noncompliance when missing)
resource "aws_config_config_rule" "s3_mfa_delete" {
  name = "s3-bucket-mfa-delete-enabled"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_MFA_DELETE_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder_status.this]
}
