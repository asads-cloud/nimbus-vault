variable "env" { type = string }

variable "bucket_name" { type = string }

variable "kms_key_alias_for_bucket" {
  description = "Alias or ARN for the CMK to encrypt the bucket objects (SSE-KMS)"
  type        = string
}

variable "trail_name" {
  type    = string
  default = "nimbus-trail"
}
