# ADR-0006: Custom KMS Key Policy & Modular Management
- **Status:** Accepted  
- **Date:** 2025-10-06  

## Context
Nimbus Vault requires encryption at rest for all transcript data buckets (raw, curated, published, audit, token).  
ADR-0005 established separate `dev` and `prod` environments (and accounts), each needing isolated KMS keys for compliance with HIPAA-like and PII data controls.  
AWS KMS supports this via customer-managed keys (CMKs), but the default key policy grants broad permissions to the account root and implicitly trusts IAM permissions.  
We need explicit, auditable control over which principals can administer and use each key, consistent across environments.

## Decision
We created a reusable Terraform module (`terraform/modules/kms`) that:
- Provisions one CMK per data domain (raw, curated, published, audit, token).  
- Applies a **minimal, explicit key policy** granting:
  - Full admin rights to the account root.  
  - additional admin roles via `additional_admin_arns`.  
  - Controlled data-plane permissions to in-account principals.  
- Omits any statements with empty principals to avoid malformed policies.  
- Enforces key rotation (`enable_key_rotation = true`).  
- Creates predictable aliases (`alias/nimbus-<tier>-<env>`).  

The module is referenced from environment code (`terraform/envs/dev`), and its outputs (`key_arns`, `alias_arns`) feed into later modules (S3, CloudTrail, etc.).

## Consequences
**Positive:**
- Consistent, least-privilege KMS policy model across all environments.  
- Avoids malformed policy errors.  
- Easier auditing and traceability.  
- Clear separation of admin vs. user permissions.

**Negative / Risks:**
- Slightly higher complexity vs. AWS default policy.  
- Must maintain the module as IAM patterns evolve.  
- Misconfigured admin lists could block access to keys.

## Alternatives Considered
1. **Use AWS default KMS policy** — rejected because it’s too permissive and not audit-friendly.  
2. **Inline policies per service (S3, CloudTrail)** — rejected for duplication and lack of centralized governance.  
3. **Single shared CMK for all buckets** — rejected for least-privilege and data-domain isolation reasons.
