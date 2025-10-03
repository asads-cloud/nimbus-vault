# Nimbus Vault

Security-first AWS data lakehouse for transcript data produced by **Nimbus Transcribe**.

## Goals
- Store, govern, and serve transcript data safely for regulated use (HIPAA/PII-like).
- Enforce encryption, PII/PHI detection, tokenisation/masking, tag-based governance, audited access.
- Terraform-only IaC (modular, least-privilege, policy-as-code).

## Scope (Phase 0)
- Foundations & planning: repo skeleton, taxonomy draft, environment definitions (dev/prod), initial architecture diagram.

## Disclaimer
This project uses **synthetic data only** in all environments. Do not upload real PHI/PII.

## Environments & Region
- Environments: `dev`, `prod` (see ADR-0005)
- Primary AWS Region: `eu-west-1`

## Directories
- `/terraform` — Terraform modules and env stacks
- `/pipelines` — ingestion/processing helpers (Lambda/Glue/python)
- `/docs` — architecture, decisions, runbooks

