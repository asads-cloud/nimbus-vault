# ADR-0011: VPC Core — Private-Only Network (dev)
- **Status:** Accepted  
- **Date:** 2025-10-11  

## Context
Nimbus Vault needs a minimal, controlled network boundary that keeps data-plane traffic private and enables tighter IAM/KMS conditions (e.g., `aws:sourceVpce`, `aws:ViaAWSService`).  
Using the default VPC (public subnets, IGW) increases attack surface and complicates HIPAA/PII controls. We want a reproducible, private-first VPC that later supports VPC endpoints for S3, STS, KMS, Macie, and CloudWatch Logs.

## Decision
Create a **dedicated VPC in eu-west-1** for the **dev** environment with:
- **DNS support/hostnames enabled**.
- **Two private subnets** in separate AZs (no public IP mapping).
- **One private route table per private subnet** (no Internet Gateway, no NAT).
- No public subnets or egress paths by default.
- Delivered as a small Terraform module (`vpc_core`) exposing `vpc_id`, `private_subnet_ids`, and `route_table_ids` for downstream modules (e.g., VPC Endpoints).

This VPC is the foundation for private service access and will host interface/gateway endpoints in a later step.

## Consequences
**Positive**
- Removes default public egress; smaller attack surface.  
- Enables strict IAM/KMS conditions tied to VPC endpoints for HIPAA/PII alignment.  
- Clear separation of concerns: network baseline is modular and reusable.  
- Predictable, reproducible networking for future services.

**Negative / Risks**
- No outbound Internet by default (intentional); components needing egress will require NAT or specific endpoints later.  
- Additional baseline to maintain (VPC + subnets + RTBs).  
- Migration from default VPC resources (if any) may be required later.

## Alternatives considered
1. **Use the default VPC**
   - Faster to start but public by default and harder to harden.
   - Rejected due to weaker security posture and inconsistent reproducibility.

2. **Public/private VPC with NAT from day one**
   - More flexible but increases cost/complexity now.
   - Deferred; we’ll add NAT only if a specific workload requires outbound Internet.
