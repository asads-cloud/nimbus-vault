# ADR-0007: CloudTrail Audit Logging & Integrity Controls
- **Status:** Accepted  
- **Date:** 2025-10-08  

## Context
To meet HIPAA and PII governance requirements, all actions on AWS resources within Nimbus Vault must be logged, immutable, and cryptographically verifiable.  
CloudTrail provides an account-level audit trail of management and data events. To ensure compliance and traceability, logs must be:

- Collected for all regions (multi-region trail).  
- Written to a **dedicated audit S3 bucket** with versioning, KMS encryption, and public access fully blocked.  
- Protected by **BucketOwnerEnforced** ownership and **SSE-KMS** using the dedicated `nimbus-audit` key.  
- Accessible only to compliance and audit processes — not to general engineering roles.  

The S3 bucket and CloudTrail configuration must support **log integrity validation** and **encryption at rest** while maintaining minimal privileges for the CloudTrail service principal.

## Decision
We implemented a **multi-region CloudTrail** that records all management events and **S3 data events (read and write)** using advanced event selectors.  

**Configuration Highlights:**
- **Trail scope:** Multi-region, non-organizational (per environment).  
- **Log destination:** Dedicated audit bucket `nimbus-audit-<env>-<region>` (versioned, private, immutable).  
- **Encryption:** Logs are encrypted using a **customer-managed KMS key** (`alias/nimbus-audit-<env>`).  
- **KMS policy:** The audit CMK includes a minimal-use statement allowing only the CloudTrail service to perform:
  - `kms:Decrypt`
  - `kms:GenerateDataKey*`
  - `kms:DescribeKey`  
  under the condition that the encryption context matches the CloudTrail ARN for this account and region.  
- **Validation:** Log file validation is enabled to ensure integrity and tamper detection.  

This design ensures audit logs cannot be altered, deleted, or accessed without explicit authorization — satisfying HIPAA audit control (45 CFR §164.312(b)) and integrity requirements (45 CFR §164.312(c)(1)).

## Consequences
**Positive:**
- Centralised, immutable audit trail across all AWS activity.  
- Meets HIPAA audit and integrity control requirements.  
- Encrypted and versioned storage provides forensic-grade evidence.  
- Minimal exposure: CloudTrail has only scoped KMS access.  

**Negative / Risks:**
- Slight increase in operational cost due to data event logging.  
- Additional IAM and KMS policy complexity to ensure correct service access.  
- Requires periodic validation that CloudTrail remains active and unmodified.  

## Alternatives considered
1. **AWS-managed CloudTrail encryption (default SSE-S3)**  
   - Rejected: does not meet HIPAA’s encryption control standards; lacks customer-managed key control.  
2. **Single-region trail**  
   - Rejected: would omit activity in other regions, risking compliance exposure.  
3. **Organization-wide trail**  
   - Deferred to a later phase when multi-account org integration is implemented.  
