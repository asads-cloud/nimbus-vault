variable "env" { type = string }

variable "finding_publishing_frequency" {
  description = "How often to publish findings (FIFTEEN_MINUTES | ONE_HOUR | SIX_HOURS)"
  type        = string
  default     = "FIFTEEN_MINUTES"
}
variable "enable_s3_protection" {
  description = "Enable S3 protection data source"
  type        = bool
  default     = true
}
