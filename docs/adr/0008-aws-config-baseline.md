# ADR-0008: AWS Config Baseline (S3 Compliance & Encrypted Evidence Storage)
- **Status:** Accepted  
- **Date:** 2025-10-09  

## Context
To maintain verifiable evidence of S3 compliance and encryption posture, Nimbus Vault requires continuous evaluation of its storage layer.  
AWS Config provides a managed compliance engine that records configuration changes and evaluates resources against defined rules.  

The goal is to:
- Detect violations of baseline S3 security controls.  
- Store all compliance data centrally and immutably in the audit bucket.  
- Keep costs minimal while ensuring auditability for HIPAA/PII compliance.  

At this stage, Config is deployed in the **dev** environment only, using modular Terraform code designed for future expansion to prod.

## Decision
Enable **AWS Config** in `eu-west-1`, configured to:
- Record **all supported resource types** (continuous mode).  
- Deliver snapshots and compliance history to the **audit bucket** (`nimbus-audit-<env>-eu-west-1`), under a dedicated prefix (`config/`).  
- Encrypt all Config data using the **audit CMK** (alias: `alias/nimbus-audit-<env>`).  
- Use a **least-privilege IAM role** that allows only delivery, describe, and read actions required for Config operation.  
- Enforce **four AWS-managed S3 compliance rules**:
  - `s3-bucket-server-side-encryption-enabled`
  - `s3-bucket-public-read-prohibited`
  - `s3-bucket-public-write-prohibited`
  - `s3-bucket-mfa-delete-enabled`

Snapshots and evaluations are stored alongside CloudTrail logs for unified evidence management.

## Consequences
**Positive**
- Continuous visibility into S3 security posture.  
- Immutable audit evidence stored with encryption-at-rest (SSE-KMS).  
- Least-privilege IAM model aligns with HIPAA/PII security expectations.  
- Terraform-managed configuration ensures reproducibility and traceability.  
- Cost kept below **$5/month per environment** by limiting scope to essential S3 rules.  

**Negative / Risks**
- Config currently records only S3 controls; additional resource types may require more permissions and incur extra cost.  
- Recorder must be extended and redeployed for prod later.  
- Overly broad recording scopes (if expanded) could increase costs over time.  

## Alternatives considered
1. **AWS Config Aggregator (multi-account centralized view)**  
   - Provides cross-account visibility but introduces cost and complexity.  
   - Rejected for initial deployment to maintain simplicity and low cost.

2. **Third-party compliance scanners (e.g., Security Hub only)**  
   - Less granular for S3 policy-level checks; limited configuration history retention.  
   - Rejected in favor of native Config + CloudTrail integration for full traceability.
