# Architecture Decision Records (ADR) — Index

## Current ADRs

- [ADR-0001: Separate env stacks (dev/prod) vs workspaces](0001-env-stacks-vs-workspaces.md)
- [ADR-0002: Primary Region (eu-west-1)](0002-primary-region.md)
- [ADR-0003: Sensitivity Taxonomy](0003-sensitivity-taxonomy.md)
- [ADR-0004: Naming Scheme](0004-naming-scheme.md)
- [ADR-0005: Environments (dev & prod)](0005-environments.md)
- [ADR-0006: Custom KMS Key Policy & Modular Management](0006-kms-key-management.md)
- [ADR-0007: CloudTrail Audit Logging & Integrity Controls](0007-cloudtrail-audit-logging.md)
- [ADR-0008: AWS Config Baseline (Encryption, Public-Block, MFA Delete)](0008-config-baseline.md)
- [ADR-0009: GuardDuty Continuous Threat Detection](0009-guardduty-threat-detection.md)
- [ADR-0010: Security Hub Standards Enablement](0010-securityhub-standards.md)
- [ADR-0011: VPC Core Network Baseline (Private Subnets, Routes, CIDRs)](0011-vpc-core-network-baseline.md)
- [ADR-0012: VPC Endpoints for Private AWS Service Access](0012-vpc-endpoints-private-access.md)

---

## Conventions

- **One ADR per decision.** Never edit history — add *superseding ADRs* if decisions change.  
- **Status flow:** Proposed → Accepted → Superseded.  
- **Scope:** Each ADR should be concise but complete, capturing **Context, Decision, Consequences, and Alternatives**.  
- **Reference linkage:** Later ADRs (e.g., ADR-0012) may build upon earlier ones (e.g., ADR-0011).  
- **Language:** Use clear, declarative, and implementation-focused phrasing.

---

_Last updated: 2025-10-11_
