# vpc_core module
- Creates a dedicated **private-only VPC** (DNS enabled) for dev.
- Creates **two private subnets** in separate AZs (no public IPs).
- Creates **one private route table per subnet** (no IGW/NAT).
- Outputs: `vpc_id`, `private_subnet_ids`, `route_table_ids` for use by VPC Endpoints and workloads.
