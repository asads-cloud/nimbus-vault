resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "nimbus-dev-vpc" }
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_cidr_a
  availability_zone       = var.az_a
  map_public_ip_on_launch = false
  tags = { Name = "nimbus-dev-private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_cidr_b
  availability_zone       = var.az_b
  map_public_ip_on_launch = false
  tags = { Name = "nimbus-dev-private-b" }
}

# Private route tables (one per private subnet)
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "nimbus-dev-rtb-private-a" }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "nimbus-dev-rtb-private-b" }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}
