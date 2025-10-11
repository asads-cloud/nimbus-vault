# 🌩️ Nimbus Vault  
**A HIPAA/PII-aware, security-first AWS lakehouse for transcript intelligence**

Nimbus Vault is a **compliance-ready data lakehouse** engineered to securely store, govern, and analyze transcript data produced by *Nimbus Transcribe*.  
It demonstrates cloud security excellence, modular Terraform design, and data-governance best practices across AWS’ native ecosystem.

---

## 🚀 Overview

Nimbus Vault is built as a **zero-trust, auditable, and fully encrypted data platform**.  
It showcases how regulated workloads (HIPAA / PII-sensitive) can be implemented with end-to-end compliance controls using **AWS native services only**.

**Core design principles**
- **Security-first:** Encryption, key isolation, audit trails, private endpoints, and least privilege everywhere.  
- **Governance-driven:** Automated PII/PHI detection, tokenisation/masking, and LF-tag-based access.  
- **IaC-only:** 100% Terraform — modular, version-controlled, and environment-isolated.  
- **Observability-ready:** All actions and anomalies are logged, classified, and reportable.  
- **Synthetic-safe:** No real data is ever processed; all datasets are synthetic or anonymised.

---

## 🧠 Architecture Summary

```
                ┌────────────────────────────┐
                │       Nimbus Transcribe     │
                │   (data ingestion source)   │
                └────────────┬────────────────┘
                             │
                   Encrypted transcript data
                             ▼
     ┌──────────────────────────────────────────────┐
     │               AWS Data Lakehouse             │
     │                                              │
     │  S3 (raw / curated / published / audit)      │
     │  ├── KMS (per-bucket CMKs)                   │
     │  ├── Macie (PII detection & tagging)         │
     │  ├── Glue (catalog / transformations)        │
     │  ├── Iceberg tables via Athena               │
     │  ├── Lake Formation (RBAC + LF-Tags)         │
     │  └── Tokenisation / Masking layer            │
     └──────────────────────────────────────────────┘
                             │
                 Auditing, Threat Detection & Compliance
                             ▼
     ┌──────────────────────────────────────────────┐
     │  CloudTrail | Config | GuardDuty | SecurityHub │
     │  + S3 audit bucket (immutable, KMS encrypted)  │
     └──────────────────────────────────────────────┘
                             │
                     Private network control plane
                             ▼
     ┌──────────────────────────────────────────────┐
     │  VPC (private subnets, endpoints, no egress) │
     │  S3, KMS, STS, Macie, CloudWatch Logs        │
     └──────────────────────────────────────────────┘
```

---

## 🧩 Key Components

| Category | Service / Module | Purpose |
|-----------|------------------|----------|
| **Encryption & Key Mgmt** | AWS KMS | Dedicated CMKs per data tier (raw, curated, published, audit, token). |
| **Audit & Logging** | CloudTrail | Multi-region trails with S3 data events and KMS encryption. |
| **Compliance & Config** | AWS Config | Enforces S3 encryption, MFA delete, and no public access. |
| **Threat Detection** | GuardDuty | Continuous anomaly detection and threat insights. |
| **Security Posture** | Security Hub | Aggregated compliance view (CIS + FSBP standards). |
| **Network Hardening** | VPC + Endpoints | All service calls restricted via private DNS and endpoints. |
| **Governance** | Lake Formation | Fine-grained RBAC and LF-tag based governance (planned). |
| **IaC** | Terraform | Modular, auditable, and environment-aware deployment (dev / prod). |

---

## 🛠️ Repository Structure

```
.
├── terraform/
│   ├── modules/         # Modular IaC building blocks
│   └── envs/
│       ├── dev/         # Dev environment stack
│       └── prod/        # Production-ready configuration (future)
│
├── docs/
│   ├── adr/             # Architecture Decision Records (traceable design history)
│   └── Architecture.md  # High-level architecture overview
│
├── pipelines/           # (Planned) Glue/Lambda data processing
└── .env.ps1             # Local environment variables for AWS profiles
```

---

## 🧾 Governance & Compliance Features

- ✅ **KMS Encryption Everywhere** — separate CMKs per data domain.  
- ✅ **S3 Data Event Logging** — full visibility via CloudTrail.  
- ✅ **AWS Config Rules** — real-time compliance checks (SSE, MFA delete, no public access).  
- ✅ **GuardDuty & SecurityHub** — continuous threat and posture monitoring.  
- ✅ **Private Connectivity** — S3, STS, KMS, Macie, and Logs via VPC Endpoints only.  
- ✅ **Terraform-native auditing** — all plans stored (`tfplan.*`) for change traceability.  
- ✅ **HIPAA-ready isolation model** — dev and prod accounts under AWS Organization.

---

## 🌍 Environments

| Environment | Purpose | Data | Notes |
|--------------|----------|------|-------|
| **dev** | Rapid iteration and validation | Synthetic only | Mirrors production controls. |
| **prod** | Controlled and auditable deployment | Synthetic only (for demo) | Ready for regulated data once approved. |

Region: **eu-west-1 (London)**

---

## ⚡ Getting Started (Developer View)

```bash
# Initialise environment
cd terraform/envs/dev
terraform init

# Validate and format
terraform fmt -recursive
terraform validate

# Plan and apply securely
terraform plan -out "tfplan.vpc"
terraform apply "tfplan.vpc"
```

> Each change is applied via named plans (`tfplan.*`) to maintain full audit history.

---

## 📚 Documentation

All architectural decisions are recorded in  
[`/docs/adr`](./docs/adr)  
(see ADR-0012 for private VPC endpoints, ADR-0006 for KMS policies, ADR-0007 for CloudTrail integrity, etc.)

---

## ⚠️ Disclaimer

Nimbus Vault processes **synthetic or anonymised data only**.  
It is designed as a demonstration of secure architecture patterns for regulated industries — **no PHI/PII or real transcript data** should ever be uploaded.

---

## 💡 Summary

Nimbus Vault is more than a demo — it’s a **reference blueprint** for how to build a **compliant data lakehouse on AWS** using native services, Terraform IaC, and zero-trust design.

> “If it’s not auditable, it’s not secure.” — guiding principle of Nimbus Vault.
