# ADR-0010: Security Hub Central Compliance & Posture Management
- **Status:** Accepted  
- **Date:** 2025-10-10  

## Context
Nimbus Vault requires a unified, automated compliance and threat visibility layer that consolidates security findings from multiple AWS services.  
While CloudTrail, Config, and GuardDuty each provide critical insight into specific domains (activity, configuration, and anomalies), Security Hub serves as the central orchestration and reporting plane for continuous monitoring.  

The service aggregates and normalizes findings from integrated AWS sources and compliance standards, helping ensure ongoing adherence to HIPAA/PII security baselines.  

At this stage, Security Hub is deployed in the **dev** environment only.

## Decision
Enable **AWS Security Hub** in `eu-west-1` with the following configuration:
- Activated **Security Hub account** for the environment.  
- Subscribed to the following standards:
  - **AWS Foundational Security Best Practices (FSBP)** v1.0.0  
  - **CIS AWS Foundations Benchmark** v1.4.0  
- Integrated with existing services (current and planned):
  - **GuardDuty:** threat detection and anomaly findings.  
  - **Config:** resource compliance findings.  
  - **Macie:** future integration for data sensitivity monitoring.  
- Outputs the enabled standard ARNs for reference and auditing.  
- Deployed via Terraform (`tfplan.securityhub`) using a modular design consistent with the other baseline components.

**Cost posture:**  
Expected to remain low-cost in dev (<$5/month) given limited findings volume.  
In production, cost scales linearly with the number of findings and enabled integrations.

## Consequences
**Positive**
- Centralized visibility across AWS security services.  
- Provides a single-pane view of compliance and anomaly findings.  
- Enables continuous posture tracking for HIPAA/PII alignment.  
- Fully managed and auto-updating — minimal operational overhead.  
- Standards-based scoring (CIS + FSBP) supports audit readiness.  

**Negative / Risks**
- Findings volume directly affects cost as the environment scales.  
- Some controls overlap with Config and GuardDuty, requiring deduplication for alert noise reduction.  
- Currently enabled in dev only — production integration still pending.  

## Alternatives considered
1. **Manual cross-service dashboards (Athena or QuickSight)**
   - Would require manual ingestion and correlation of Config and GuardDuty findings.
   - Rejected due to complexity and lack of real-time normalization.

2. **Third-party SIEM (Splunk, Datadog Security Monitoring)**
   - Provides richer analytics but incurs higher cost and external data handling.
   - Rejected to maintain native, in-region, AWS-managed compliance posture.
