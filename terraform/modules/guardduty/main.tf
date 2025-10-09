# Single-account detector in region
resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency

  dynamic "datasources" {
    for_each = var.enable_s3_protection ? [1] : []
    content {
      s3_logs {
        enable = true
      }
    }
  }
}

output "detector_id" {
  value = aws_guardduty_detector.this.id
}
