# ADR-0012: VPC Endpoints for Private AWS Service Access
- **Status:** Accepted  
- **Date:** 2025-10-11

## Context
Nimbus Vault must ensure that data-plane operations (S3, KMS, STS, Macie, CloudWatch Logs) remain entirely within the AWS network, avoiding exposure to public internet routes.  
This is a foundational control for HIPAA and PII-compliant architectures — it reduces egress risks, enables conditional IAM enforcement (`aws:sourceVpce`, `aws:ViaAWSService`), and ensures encrypted service calls stay private.

In the `dev` environment, no prior VPC endpoints existed. The platform needed a consistent baseline for secure, private connectivity between its data lake components and AWS services.

## Decision
A new **`vpc_endpoints`** Terraform module was introduced to deploy:

- **1 Gateway endpoint** for **S3**  
- **4 Interface endpoints** for **STS**, **KMS**, **Macie2**, and **CloudWatch Logs**  

All endpoints are deployed into the Nimbus Vault **VPC** created by `vpc_core`, using **private subnets** across multiple AZs in `eu-west-1`.  
Private DNS is enabled for seamless service resolution, and an optional security group restricts HTTPS (443) ingress to trusted internal CIDRs.

Outputs include:
- Gateway and Interface endpoint IDs  
- Optional dedicated Security Group ID  

This configuration was applied via `tfplan.vpcep`, ensuring auditable, versioned infrastructure changes.

## Consequences
**Positive:**
- Eliminates public egress for AWS API calls.
- Enables tighter IAM and KMS conditions for internal service use.
- Improves compliance posture for HIPAA/PII workloads.
- Simplifies encryption context validation (`aws:ViaAWSService`).

**Risks / Considerations:**
- Interface endpoints incur additional hourly + data processing costs.
- Endpoint maintenance must be replicated in `prod` and across future regions.
- Must coordinate with VPC routing to avoid duplicate Gateway attachments.

## Alternatives Considered
- **Public AWS service access:** Rejected due to HIPAA non-compliance and higher data exposure risk.  
- **PrivateLink via centralized shared VPC:** Deferred; current focus is single-account simplicity.  
- **Per-service endpoint creation on demand:** Rejected for manageability — opted for consolidated module.

---

_Last updated: 2025-10-11_
