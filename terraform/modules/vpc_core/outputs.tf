output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "route_table_ids" {
  value = [aws_route_table.private_a.id, aws_route_table.private_b.id]
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}
