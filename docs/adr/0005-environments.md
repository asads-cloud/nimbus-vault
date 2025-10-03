# ADR-0005: Environments (dev & prod)
- **Status:** Accepted
- **Date:** 2025-10-03

## Context
To balance agility in development with compliance and operational safety in production, our infrastructure needs clear environment separation.  
Both HIPAA and PII considerations demand strict controls, with synthetic-only data in early phases. Using distinct environments also ensures that changes can be tested safely before impacting production workloads.  

## Decision
We will use **two separate environments**: `dev` and `prod`.  
These will map to separate AWS accounts (`nimbus-dev`, `nimbus-prod`) under an AWS Organization, both running in **eu-west-1**.  

- **dev**: fast iteration, infrastructure changes trialed first, synthetic data only.  
- **prod**: stable, change-controlled, synthetic data only (no real PHI/PII in Phase 0–1).  

**Controls & Conventions:**  
- **Region:** eu-west-1 (see ADR-0002).  
- **Naming:** `nimbus-<component>-<env>-eu-west-1` (see ADR-0004).  
- **Default tags:** `Project=nimbus-vault`, `Environment=<env>`.  
- **Lake Formation:** separate permissions per environment, no cross-env sharing by default.  
- **Athena:** per-environment workgroups (`nimbus_dev_wg`, `nimbus_prod_wg`) and result buckets.  
- **Glue:** per-environment databases (`nimbus_transcripts_dev`, etc.).  
- **KMS:** distinct keys and aliases (e.g., `alias/nimbus-data-dev`, `alias/nimbus-data-prod`).  

**Data Policy (Phase 0 scope):**  
- Only **synthetic data** in both environments.  
- **Published views** contain no `High` sensitivity fields (see ADR-0003).  

## Consequences
**Positive:**  
- Strong blast-radius isolation between dev and prod.  
- Compliance alignment: avoids risk of regulated PHI/PII in non-production environments.  
- Predictable naming and tagging improve governance and auditing.  

**Negative / Risks:**  
- Cross-account deployment requires CI/CD pipelines bootstrapped per account.  
- Monitoring and auditing need to aggregate across accounts (to be defined in a future ADR).  
- Slightly higher operational overhead to manage multiple AWS accounts.  

## Alternatives considered
1. **Single account with role-based isolation**  
   - Simpler to bootstrap, fewer accounts to manage.  
   - Rejected because of weaker isolation; account-level separation is preferred for compliance and security blast-radius reduction.  
   - Acceptable only as a short-term fallback if multiple accounts cannot be provisioned immediately.  

