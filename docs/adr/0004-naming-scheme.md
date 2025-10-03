# ADR-0004: Resource Naming
- **Status:** Accepted
- **Date:** 2025-10-03

## Context
Our cloud resources need a clear, consistent, and predictable naming convention to support governance, auditing, and compliance requirements (HIPAA/PII).  
Without a structured pattern, it becomes difficult to filter logs, avoid collisions, and maintain visibility across environments and regions.  

## Decision
We will use a **consistent, lowercase, hyphenated naming pattern**:  

`nimbus-<component>-<env>-<region>`  

**Initial buckets**  
- Raw ingest:         **nimbus-raw-<env>-eu-west-1**  
- Curated (Iceberg):  **nimbus-curated-<env>-eu-west-1**  
- Published (masked): **nimbus-published-<env>-eu-west-1**  
- Logs/audits:        **nimbus-logs-<env>-eu-west-1**  
- Athena results:     **nimbus-athena-<env>-eu-west-1**  
- Temp/scratch:       **nimbus-tmp-<env>-eu-west-1**  

**Other examples**  
- KMS key alias: `alias/nimbus-<component>-<env>`  
- Glue DBs: `nimbus_<domain>_<env>` (e.g., `nimbus_transcripts_dev`)  
- Athena workgroup: `nimbus_<env>_wg`  
- Lake Formation LF-tag key: `Sensitivity` (values: High | Medium | Low)  

## Consequences
**Positive:**  
- Consistent structure simplifies resource discovery, filtering, and auditing (e.g., S3, CloudTrail).  
- Embeds environment and region, reducing the risk of naming collisions.  
- Easier onboarding for engineers due to predictable naming rules.  
- Aligns with compliance needs by supporting resource traceability.  

**Negative / Risks:**  
- Slightly longer resource names, which may be cumbersome in some contexts.  
- May need future extension for global services or cross-region resources.  
- Glue DBs use underscores instead of hyphens due to service constraints, which introduces minor inconsistency.  

## Alternatives considered
1. **Unstructured / Ad hoc naming**  
   - Would allow faster resource creation with fewer constraints.  
   - Rejected due to governance risks, lack of traceability, and potential compliance gaps.  

2. **CamelCase or MixedCase conventions**  
   - Improves readability for some engineers.  
   - Rejected because many cloud services enforce or normalize to lowercase, leading to inconsistency.  

3. **Prefix-only naming (e.g., `nimbus-raw`, `nimbus-curated`)**  
   - Shorter and simpler, but omits environment/region context.  
   - Rejected due to higher collision risk and difficulty in managing multi-env/multi-region deployments.  

