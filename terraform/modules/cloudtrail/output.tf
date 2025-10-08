output "trail_arn"  { value = aws_cloudtrail.trail.arn }

output "bucket_arn" { value = aws_s3_bucket.audit.arn }
