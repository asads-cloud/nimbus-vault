output "recorder_name" { value = aws_config_configuration_recorder.this.name }

output "rules" {
  value = {
    encryption  = aws_config_config_rule.s3_encryption.name
    public_read = aws_config_config_rule.s3_public_read_block.name
    public_write= aws_config_config_rule.s3_public_write_block.name
    mfa_delete  = aws_config_config_rule.s3_mfa_delete.name
  }
}
