data "aws_region" "current" {}
data "aws_vpc" "this" { id = var.vpc_id }


locals {
  svc = {
    sts   = "com.amazonaws.${data.aws_region.current.name}.sts"
    kms   = "com.amazonaws.${data.aws_region.current.name}.kms"
    logs  = "com.amazonaws.${data.aws_region.current.name}.logs"
    macie = "com.amazonaws.${data.aws_region.current.name}.macie2"
    s3    = "com.amazonaws.${data.aws_region.current.name}.s3"
  }
}

# SG for Interface endpoints (HTTPS from internal CIDRs)
resource "aws_security_group" "vpce" {
  count       = var.create_security_group ? 1 : 0
  name        = "nimbus-vpce-${var.env}"
  description = "Ingress 443 from internal CIDRs to Interface Endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internal"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs != null && length(var.allowed_cidrs) > 0 ? var.allowed_cidrs : [data.aws_vpc.this.cidr_block]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  sg_ids = var.create_security_group ? [aws_security_group.vpce[0].id] : []
}

# -------- GATEWAY endpoint for S3 (route-table attachments)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = local.svc.s3
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = ["s3:*"],
      Resource = "*"
    }]
  })
  tags = { Name = "nimbus-s3-${var.env}" }
}

# -------- INTERFACE endpoints (STS, KMS, Logs, Macie)
resource "aws_vpc_endpoint" "interface" {
  for_each           = {
    sts   = local.svc.sts
    kms   = local.svc.kms
    logs  = local.svc.logs
    macie = local.svc.macie
  }
  vpc_id             = var.vpc_id
  service_name       = each.value
  vpc_endpoint_type  = "Interface"
  private_dns_enabled= true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = local.sg_ids
  tags               = { Name = "nimbus-${each.key}-${var.env}" }
}
