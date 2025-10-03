# ADR-0003: Sensitivity Taxonomy
- **Status:** Accepted
- **Date:** 2025-10-03

## Context
To ensure compliance with HIPAA and other PII regulations, data stored and processed in our environment requires a clear and enforceable sensitivity classification.  
Without a consistent taxonomy, it is difficult to enforce access control, apply masking/tokenisation, and ensure that published datasets exclude regulated or high-risk data.  

## Decision
We will use a **single LF-tag key `Sensitivity`** with three possible values: **High**, **Medium**, and **Low**.  

- **High**: Direct identifiers or regulated data (e.g., names + contact, national IDs, health terms, diagnoses, medication, payment tokens). Strongest controls; restricted to least-privileged roles; masked/tokenised by default in published views.  
- **Medium**: Indirect identifiers or derived features that could re-identify when combined (timestamps, coarse locations, speaker roles). Governed access; may appear unmasked to approved analysts.  
- **Low**: Non-sensitive operational metadata, synthetic samples, system logs without user content.  

Enforcement:  
- LF-tags with key `Sensitivity` applied to tables/columns and used in row/column-level filters.  
- Default AWS resource tags include `Project=nimbus-vault`, `Environment`, and eventually `Sensitivity` where appropriate.  
- Published views guarantee **no High** data; High data is masked/tokenised or excluded.  

## Consequences
**Positive:**  
- Clear and simple sensitivity taxonomy that aligns with HIPAA/PII compliance requirements.  
- Centralized enforcement mechanism using AWS Lake Formation LF-tags.  
- Reduced risk of accidental disclosure in published datasets.  
- Scalability: easy to extend enforcement to new datasets and resources.  

**Negative / Risks:**  
- May be overly simplistic in edge cases where finer granularity is needed (e.g., differentiating between health identifiers vs. financial identifiers).  
- Enforcement depends heavily on correct and consistent tagging; misclassified data may lead to compliance gaps.  
- Requires future refinement for masking, tokenisation strategies, and retention rules.  

## Alternatives considered
1. **Multiple Tag Keys (e.g., `PHI`, `PII`, `PCI`)**  
   - Would provide more granular classification aligned with regulatory categories.  
   - Rejected due to operational overhead and risk of inconsistent application across datasets.  

2. **Separate Classification System (e.g., NIST data classes or HIPAA-specific schema)**  
   - Would align with external standards and support audits more directly.  
   - Rejected due to added complexity and slower time-to-enforcement. A simpler taxonomy allows quicker implementation while still supporting compliance.  

3. **No Tagging / Manual Access Controls**  
   - Would rely entirely on manual governance, IAM policies, or ad hoc decisions.  
   - Rejected due to high risk of human error, poor scalability, and lack of visibility for compliance teams.  

