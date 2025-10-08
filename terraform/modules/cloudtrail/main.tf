data "aws_caller_identity" "me" {}
data "aws_region" "current" {}

# --- S3: audit bucket (bucket-owner enforced, blocked public, versioned, SSE-KMS)
resource "aws_s3_bucket" "audit" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "audit" {
  bucket = aws_s3_bucket.audit.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_ownership_controls" "audit" {
  bucket = aws_s3_bucket.audit.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

resource "aws_s3_bucket_public_access_block" "audit" {
  bucket                  = aws_s3_bucket.audit.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_alias_for_bucket
    }
    bucket_key_enabled = true
  }
}

# --- CloudTrail: multi-region, S3 data events (read + write), KMS-encrypted logs
resource "aws_cloudtrail" "trail" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.audit.id
  s3_key_prefix                 = "cloudtrail/${data.aws_caller_identity.me.account_id}"
  kms_key_id                    = var.kms_key_alias_for_bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  is_organization_trail         = false

  # Log ALL S3 Data events (read + write) across the account using Advanced Event Selectors
  advanced_event_selector {
    name = "S3DataEventsAll"

    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }
  }

  depends_on = [
  aws_s3_bucket_policy.audit,
  aws_s3_bucket_server_side_encryption_configuration.audit,
  aws_s3_bucket_public_access_block.audit,
  aws_s3_bucket_ownership_controls.audit
  ]
}

# Bucket policy to allow CloudTrail to write (works with BucketOwnerEnforced)
data "aws_iam_policy_document" "audit_bucket" {
  statement {
    sid     = "AllowCloudTrailWrite"
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.audit.arn}/cloudtrail/${data.aws_caller_identity.me.account_id}/*"]

    # Restrict to trails in this account, any region (prevents circular dependency)
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.me.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.me.account_id}:trail/*"]
    }
  }

  statement {
    sid     = "AllowCloudTrailListBucket"
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl", "s3:ListBucket", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.audit.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.me.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.me.account_id}:trail/*"]
    }
  }
}


resource "aws_s3_bucket_policy" "audit" {
  bucket = aws_s3_bucket.audit.id
  policy = data.aws_iam_policy_document.audit_bucket.json
}

