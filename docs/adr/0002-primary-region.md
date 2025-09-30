# ADR-0002: Primary Region
- **Status:** Accepted
- **Date:** 2025-09-30

## Context
Nimbus Vault needs HIPAA-eligible services and full Lake Formation/Athena/Iceberg support.
We want EU data residency and to avoid cross-region pitfalls (KMS keys, LF-tags, Macie jobs).

## Decision
Use **eu-west-1 (Ireland)** as the primary region for all environments (`dev`, `prod`).
All KMS keys, Lake Formation governance, and data stores are provisioned in eu-west-1.

## Consequences
- Region isolation by default; any cross-region use requires explicit design.
- IAM policies and LF-tags assume `eu-west-1`.
- Operational tooling (CloudTrail/GuardDuty/Security Hub) anchored in `eu-west-1`.

## Alternatives considered
- **eu-west-2 (London):** also HIPAA-eligible, but prefer EU residency and maturity of services in Ireland.
