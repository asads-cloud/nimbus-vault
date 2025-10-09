# ADR-0009: GuardDuty Threat Detection (S3 Anomaly Monitoring)
- **Status:** Accepted  
- **Date:** 2025-10-09  

## Context
To maintain continuous visibility into potential security threats affecting S3 and IAM activity, Nimbus Vault requires an automated anomaly detection capability.  
AWS GuardDuty provides a managed, continuously learning service that detects malicious activity and unauthorized behavior by analyzing CloudTrail, VPC Flow Logs, DNS logs, and S3 data events.  

For compliance and audit reasons (HIPAA/PII context), GuardDuty must operate with encryption-aware controls, minimal footprint, and strict cost governance.  
The objective is to surface actionable findings (e.g., anomalous S3 reads or unusual IAM API activity) while keeping runtime overhead low.

Currently, GuardDuty is deployed in the **dev** environment only, with configuration modularized for later production rollout.

## Decision
Enable **AWS GuardDuty** in `eu-west-1` with the following configuration:
- A single **account-level detector** per environment (no delegated admin or organization master at this stage).  
- **S3 Protection** enabled to monitor data-plane access patterns and detect suspicious reads, uploads, or enumerations.  
- **Finding publishing frequency:** `FIFTEEN_MINUTES` — providing near-real-time alerts at reasonable cost.  
- Outputs expose the detector ID for future integration with AWS Security Hub and centralized alerting.  

Findings are retained within the GuardDuty service and can later be routed to Security Hub or EventBridge for automated incident workflows.

## Consequences
**Positive**
- Continuous anomaly detection without manual rule maintenance.  
- Early detection of credential misuse, S3 exfiltration attempts, and anomalous data access.  
- Fully managed service with no persistent infrastructure overhead.  
- Minimal configuration complexity and low-cost operation (<$5/month for current workload).  
- Compliant with HIPAA/PII monitoring requirements through AWS-managed detection logic and regional isolation.

**Negative / Risks**
- Findings currently stored in the GuardDuty console only; not yet exported to a centralized audit store.  
- Additional costs may increase if data-plane activity or account resources expand significantly.  
- Limited scope — single-region, single-account — requires future expansion for production and multi-account visibility.

## Alternatives considered
1. **Manual CloudTrail pattern analysis (Athena-based queries)**  
   - Would require maintaining SQL queries and schedules.  
   - Rejected in favor of GuardDuty’s managed, continuously updated detection models.

2. **Third-party anomaly detection (SIEM integration)**  
   - Adds licensing, complexity, and additional data transfer of PII-related logs.  
   - Rejected for early-stage build; GuardDuty provides adequate native coverage.
