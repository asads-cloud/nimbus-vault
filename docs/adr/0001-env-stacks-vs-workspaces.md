# ADR-0001: Separate env stacks (dev/prod) instead of Terraform workspaces
- **Status:** Accepted
- **Date:** 2025-09-29

## Context
We need clear isolation between dev and prod for HIPAA-style governance, different sizing, and separate state/backends/accounts.

## Decision
Use `/terraform/envs/dev` and `/terraform/envs/prod` as entry-points with their own backend/provider config. Reuse modules from `/terraform/modules`.

## Consequences
- Safer: small blast radius per `plan/apply`.
- Simpler CI/CD: one job per folder/profile.
- Slight duplication across env files (acceptable).

## Alternatives considered
- **Terraform workspaces:** convenient but easy to misapply and hides diffs; rejected for safety/auditability.
- **Single monorepo root with var-files:** workable but harder to isolate state and review.
