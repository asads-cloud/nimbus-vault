# Architecture (v1)

**High-level flow:**

```mermaid
flowchart LR
  subgraph Ingest
    A[Raw S3 Bucket (nimbus-raw-<env>-eu-west-2)]
  end

  B[Macie (PII/PHI classification)]
  C[Glue ETL + Crawlers]
  D[(Iceberg Tables in S3)]
  E[Lake Formation (LF-tags, RBAC, row/col-level)]
  F[Athena (SQL over Iceberg)]
  G[CloudTrail / GuardDuty / Security Hub / Config]
  H[EventBridge]
  I[Lambda / DynamoDB (metadata/services)]
  J[Dashboards & Alerts]

  A --> B
  A --> C
  C --> D
  D --> E --> F
  A --> G
  B --> G
  F --> J
  G --> J
  H --> I --> J

Core services: S3, KMS, IAM, Lake Formation, Glue, Athena (Iceberg), Macie, CloudTrail, GuardDuty, Security Hub, Config, EventBridge, Lambda, DynamoDB.

Region: eu-west-1
Environments: dev, prod