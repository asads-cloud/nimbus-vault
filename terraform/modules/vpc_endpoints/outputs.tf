output "s3_gateway_endpoint_id" { value = aws_vpc_endpoint.s3.id }

output "interface_endpoint_ids" { value = { for k, v in aws_vpc_endpoint.interface : k => v.id } }

output "security_group_id"      { value = length(local.sg_ids) > 0 ? local.sg_ids[0] : null }
