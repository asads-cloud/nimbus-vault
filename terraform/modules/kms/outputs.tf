output "key_arns" {
  value = { for k, v in aws_kms_key.cmk : k => v.arn }
}

output "alias_arns" {
  value = { for k, v in aws_kms_alias.this : k => v.arn }
}
