# Achieving Digital Sovereignty in the Cloud
> Red Hat Course: `do0042l-4.18` — Notes

---

## Table of Contents
1. [What Is Digital Sovereignty?](#1-what-is-digital-sovereignty)
2. [The Four Pillars of Sovereignty](#2-the-four-pillars-of-sovereignty)
3. [Architectural Design and Sovereign Controls](#3-architectural-design-and-sovereign-controls)
4. [European Framework: SOVs and SEALs](#4-european-framework-sovs-and-seals)
5. [Red Hat's Approach to Sovereignty](#5-red-hats-approach-to-sovereignty)
6. [Quiz Answers](#6-quiz-answers)

---

## 1. What Is Digital Sovereignty?

> **Core Definition**: The ability of an organization or nation to exercise meaningful authority and independent control over its digital infrastructure, technologies, data, and decision-making processes within its jurisdiction, **free from foreign influence or control**.

### Core Principles (Autonomy, Control, Choice, Flexibility, Portability, Assurance)

**Digital Autonomy** is the central principle — the ability to act independently and exert meaningful control over digital existence without undue external reliance.

**Autonomy** requires that all critical technology elements reside physically within the organization's/nation's borders:
- Foundational hardware (servers, storage, networking)
- Cloud infrastructure software, platforms, and control planes
- Supporting operations (admin, maintenance, support) — handled only by **approved, local personnel**

### Sovereignty Challenges

| Challenge | Description |
|---|---|
| Geopolitical Uncertainty | Conflicts between laws (e.g., GDPR vs. US CLOUD Act) |
| Regulatory Compliance | GDPR, DORA, NIS2, PIPL (China), DPDP (India) |
| Data Protection & Security | Supply chain vulnerabilities, unauthorized access |
| Artificial Intelligence | **Sovereign AI** — build/train/deploy AI using domestic data and infra |
| Costs and Control | Vendor lock-in, operational resilience, IP protection |

### Global Regulatory Examples

| Region | Framework | Key Requirement |
|---|---|---|
| EU | GDPR, DORA, NIS2 | Data protection, ICT resilience, supply chain security |
| China | CSL, DSL, PIPL | Data localization for CII, strict consent |
| India | DPDP Act 2023 | 18-month compliance timeline (ends mid-2027) |
| Japan | ESPA | 200+ infra operators screened; supplier transparency |
| Singapore | PDPA + TRM | Strict data governance for financial institutions |
| Australia | HCF + Cloud Policy | Interoperability, portability, vendor lock-in prevention |
| New Zealand | Cloud First Policy | RESTRICTED data must be hosted onshore over time |

### The Sovereign Cloud

A **sovereign cloud** is an environment designed to adhere to a nation's:
- Data residency requirements
- Operational independence
- Regulatory compliance mandates

It goes beyond simple data location — includes:
- In-country/in-region data centers
- Geo-fencing / virtual perimeter policies
- Local staffing and supply chain control
- Workload protection, access controls, auditing

### Common Misconceptions

| Misconception | Reality |
|---|---|
| Only domestic providers can be used | Global providers can offer sovereign cloud regions |
| Sovereignty is binary (all or nothing) | It's a **spectrum** based on risk tolerance |
| Must avoid all foreign software | Open source (Linux, Kubernetes) is fine — control is key |
| Sovereign clouds are expensive and less innovative | Long-term value: reduced legal risk, enhanced trust |

---

## 2. The Four Pillars of Sovereignty

> The pillars are **interdependent** — you cannot achieve full sovereignty by implementing only some of them.

```
Data ←→ Technology ←→ Operations ←→ Assurance
```

### 2.1 Data Sovereignty
- **Focus**: Control over how data is collected, classified, processed, stored
- **Scope**: Beyond data residency (geographic storage) — includes governance and jurisdictional laws
- **Key Point**: Data must be subject to the laws of the jurisdiction where it was collected or where the data subject resides
- **Customer Expectations**: Operational independence, disconnected operation capability, trusted software provenance

### 2.2 Technology Sovereignty
- **Focus**: Control over the entire technology stack (hardware, software, services)
- **Scope**: Full lifecycle — development, sourcing, deployment, operation
- **Key Requirements**:
  - Verifiable trust in the **software supply chain**
  - **Reproducible builds**
  - **Digital signing** of artifacts (e.g., Sigstore)
  - **SBOM** (Software Bill of Materials) management
- **Goal**: Technology independence + security assurance; open source preferred

### 2.3 Operational Sovereignty
- **Focus**: Control over how infrastructure is managed and run
- **Scope**: Provisioning, config, monitoring, maintenance, support; includes **air-gapped** operation
- **Key Requirement**: Vetted, local personnel with appropriate skills/clearance manage systems
- **Goal**: Operational resilience and independence

### 2.4 Assurance Sovereignty
- **Focus**: Independently verify and assure integrity, security, reliability, and resilience
- **Scope**: Comprehensive logging, immutable audit trails, IAM, verifiable supply chain integrity
- **Goal**: Confidence and accountability — prove digital assets are protected and compliant

### How Pillars Interact
- **Data** depends on Technology + Operations + Assurance
- **Technology** requires Operations + Assurance
- **Operations** relies on Technology + Assurance
- **Assurance** depends on Data + Technology + Operations

### Key Components for Achieving Sovereignty

| Component | Description |
|---|---|
| Sovereign Controls | Mechanisms/policies for data residency, access, encryption |
| Sovereign AI | Develop/deploy/control AI within own borders and ethical frameworks |
| Sovereign OS | Open source, transparent, locally maintained OS |
| Foundational Infrastructure | Physical/virtual resources in the right jurisdiction with local management |
| Software Supply Chain | Reproducible builds, digital signing, SBOM, vulnerability scanning |
| Flexible Open Scalable Platform | OpenShift — open, transparent, avoids vendor lock-in |
| Partner Ecosystem | MSPs, CSPs, SIs, ISVs for in-country expertise |

---

## 3. Architectural Design and Sovereign Controls

### Cloud Infrastructure Decisions

**Data Center Jurisdictions**:
- **Public Cloud**: Select compliant regions; verify physical location and legal jurisdiction
- **Hybrid Cloud**: On-premise for sensitive data + public cloud for less-sensitive/burst
- **Private Cloud**: Own data centers in chosen jurisdiction → highest physical/legal control

**Tenancy Models**:

| Model | Description | Pros | Cons |
|---|---|---|---|
| Single Tenancy | Dedicated physical/virtual infra | Max isolation and control | More expensive, higher operational overhead |
| Multi-tenancy | Shared infra, logical separation (namespaces, VMs) | Cost-effective, scalable | Shared infra concerns; requires strict additional controls |

### Sovereign Controls

#### Data Encryption
- **At Rest**: Disks, databases, object storage
- **In Transit**: TLS for network data
- **In Use (Confidential Computing)**: Hardware-based **Trusted Execution Environments (TEEs)** — data protected even during processing; attestation service verifies workloads run in genuine TEE

#### External Key Management
- Organization controls encryption keys **separately from the cloud provider**
- The sovereign entity — **not** the cloud provider — owns and manages keys
- Prevents third-party data access even if they control the infrastructure

#### Access and Identity Management
- Principle of **Least Privilege**
- **MFA** mandatory for all sensitive access
- **RBAC**: Precise roles and permissions
- **Jurisdictional Access Controls**: Enforce access based on user location/nationality

#### Audit Management
- Every action recorded — immutable, tamper-proof logs
- **Log forwarding** to centralized SIEM
- Retained according to regulatory requirements

#### Software Supply Chain Security
- **Reproducible Builds**: Same source → same binary
- **Digital Signing**: Cryptographic signatures for containers/packages
- **SBOM**: Full inventory of open source and third-party components
- **Geographic Signing**: Signing/attestation within trusted geographic locations

#### Data Residency Protection
- Data never leaves the sovereign territory
- Policy enforcement via automation (workloads "pinned" to approved locations)
- **Geo-fencing**: Strict geographic boundaries

### Implementation Roles

| Role | Responsibility |
|---|---|
| Compliance & Governance | Define sovereign policies, regulatory requirements, audit standards |
| InfoSec | Design/implement security controls, monitor threats, manage incidents |
| Platform Engineering | Build/operate cloud infra and platforms (OpenShift, RHEL) |
| Application Dev | Develop with sovereignty in mind, follow supply chain processes |

---

## 4. European Framework: SOVs and SEALs

> The most formalized sovereignty assessment model available. Applicable beyond the EU as a reference model.

### The 8 Sovereignty Objectives (SOVs)

| SOV | Name | Description |
|---|---|---|
| SOV-1 | Strategic Sovereignty | Depth of integration in EU legal, financial, industrial systems |
| SOV-2 | Legal & Jurisdictional Sovereignty | Legal standing, vulnerability to foreign laws, EU rights enforcement |
| SOV-3 | Data & AI Sovereignty | Data/AI controlled within EU; all storage/processing inside EU |
| SOV-4 | Operational Sovereignty | EU entities' real-world capacity to operate/maintain without non-EU reliance |
| SOV-5 | Supply Chain Sovereignty | Hardware origins, openness, robustness of full tech supply chain |
| SOV-6 | Technology Sovereignty | Open standards, transparency, freedom from proprietary lock-in |
| SOV-7 | Security & Compliance Sovereignty | Security mgmt and DORA/NIS2 compliance managed by EU personnel |
| SOV-8 | Environmental Sustainability | Long-term sustainability, energy independence |

**Pillar mapping**:
- **Data sovereignty** → SOV-2, SOV-3
- **Technology sovereignty** → SOV-5, SOV-6
- **Operational sovereignty** → SOV-1, SOV-4
- **Assurance sovereignty** → SOV-7 + SEALs

### Sovereignty Effectiveness Assurance Levels (SEALs)

| SEAL | Name | Description |
|---|---|---|
| SEAL-0 | No Sovereignty | Service entirely controlled by non-EU entities |
| SEAL-1 | Jurisdictional Sovereignty | EU law applies on paper, but practically unenforceable |
| SEAL-2 | Data Sovereignty | EU laws enforceable, but significant non-EU tech/ops dependency |
| SEAL-3 | Digital Resilience | EU law enforceable, EU has significant influence; minor non-EU control |
| SEAL-4 | Full Digital Sovereignty | Completely under EU control, no critical non-EU dependencies |

> **SEAL** = minimum pass/fail threshold to be considered in a tender
> **Sovereignty Score** = competitive differentiator that ranks providers who passed

### Sovereignty Score Computation

$$\text{Sovereignty Score} = \sum_{i=1}^{8} (\text{Objective Score}_i \times \text{Weight}_i)$$

| SOV | Weight |
|---|---|
| SOV-5: Supply Chain Sovereignty | **20%** |
| SOV-1: Strategic Sovereignty | 15% |
| SOV-4: Operational Sovereignty | 15% |
| SOV-6: Technology Sovereignty | 15% |
| SOV-2: Legal & Jurisdictional Sovereignty | 10% |
| SOV-3: Data & AI Sovereignty | 10% |
| SOV-7: Security & Compliance Sovereignty | 10% |
| SOV-8: Environmental Sustainability | **5%** |

**Example calculation** (provider with strong data controls, partial non-EU hardware):

| SOV | Weight | Score | Weighted |
|---|---|---|---|
| SOV-1 | 15% | 80 | 12.0 |
| SOV-2 | 10% | 90 | 9.0 |
| SOV-3 | 10% | 100 | 10.0 |
| SOV-4 | 15% | 70 | 10.5 |
| SOV-5 | 20% | 60 | 12.0 |
| SOV-6 | 15% | 90 | 13.5 |
| SOV-7 | 10% | 80 | 8.0 |
| SOV-8 | 5% | 100 | 5.0 |
| **Total** | | | **80** |

---

## 5. Red Hat's Approach to Sovereignty

> Red Hat is **not** a sovereign cloud provider — it's an **enabling technology partner** for local ecosystems.

### Philosophy
- Only credible path to digital sovereignty is through **open source**
- Foundation: **Open Hybrid Cloud** — consistent environment spanning on-premise, private, and public clouds
- Prevents vendor lock-in; freedom to choose where data and apps reside

### Unique Advantages

| Advantage | Description |
|---|---|
| Avoids Vendor Lock-in | Open source reduces dependency on proprietary platforms |
| Workload Portability | Migrate across clouds or back on-premise as requirements evolve |
| Transparency & Auditability | Open source is transparent by nature — critical for regulatory compliance |
| Full Control and Choice | Data within national borders, in-region service/support |
| Integrated Security | Built-in sovereign controls to meet compliance mandates |
| Partner Ecosystem | MSPs, CSPs, GSIs, ISVs for regional expertise |

### Partner Ecosystem
- 500+ EU cloud partners, many with existing sovereign solutions
- Enables local MSPs, CSPs, SIs, ISVs to build sovereign cloud offerings
- Example: **Phoenix Systems** (Switzerland) — uses Red Hat to deliver `kvant Cloud`, fully compliant with Swiss data sovereignty laws
- **Red Hat OpenShift on Google Cloud Dedicated** — for highly regulated organizations (financial services, healthcare, public sector)

### Red Hat Portfolio for Sovereignty

| Product | Role |
|---|---|
| **Red Hat Enterprise Linux (RHEL)** | Sovereign OS base — open, auditable, FIPS 140-2, Common Criteria certified; supports Confidential Computing (AMD SEV-SNP) |
| **Red Hat OpenShift** | Core platform — consistent Kubernetes across any infra; multicluster mgmt, hosted control planes, disconnected ops, confidential containers |
| **Red Hat AI** (OpenShift AI + AI Inference Server) | Sovereign AI/ML — build/deploy/govern AI without cloud lock-in |
| **Red Hat Advanced Developer Suite (RHADS)** | Trusted software supply chain — SBOM, Sigstore signing, Dev Hub golden paths |
| **Red Hat Ansible Automation Platform** | Automate sovereign controls, enforce compliance at scale, policy-as-code |
| **Red Hat Application Foundations** | 3scale (API control within sovereign boundary), AMQ (secure async messaging) |
| **Red Hat Advanced Cluster Management (RHACM)** | Single pane of glass for multi-cluster policy enforcement and data residency |
| **Red Hat Advanced Cluster Security (RHACS)** | Kubernetes-native security: vulnerability mgmt, compliance, threat detection, audit trails |
| **Red Hat OpenShift Data Foundation** | Data residency, at-rest encryption, stateful app portability |

### Key OpenShift Features for Sovereignty

- **Hosted Control Planes**: Decouple control plane from data plane → small vetted team manages control planes; customer retains physical control of compute nodes with data
- **Multicluster Management**: Centralized policy enforcement via RHACM
- **Disconnected (Air-gapped) Operation**: Fully offline installs/operations supported
- **Confidential Computing**: OpenShift Sandboxed Containers → confidential containers in TEEs (peer pods in CVMs)
- **Zero Trust / SPIFFE+SPIRE**: Cryptographic workload identity — eliminates shared secrets
- **Workload Identity Manager**: SPIRE for SVIDs (short-lived cryptographic identities)
- **External KMS/HSM Integration**: Keys managed outside the platform by the sovereign entity

### Red Hat Confirmed Sovereign Support
- As of April 2026: available in **US and EU** (expansion planned)
- Support from **senior engineers legally authorized and operating within their jurisdiction**
- Features:
  - Verified in-region staffing with background checks
  - Isolated regional data handling (logically separated from standard support infra)
  - **Mirror Case Workflow**: Global expert collaboration without exposing sensitive data outside the region
  - Localized operational control with least-privilege auditable IAM
  - 24/7 in-region availability
  - **SOS Clean AI Project**: AI-driven obfuscation of diagnostic data before sharing globally — AI stays within regional boundary

### Red Hat Digital Sovereignty Readiness Assessment
Self-service tool evaluating 7 domains: data, technical, operational, assurance sovereignty, open source awareness, executive oversight, managed services.

**Maturity Phases**:
1. **Foundation** — Early identification of requirements
2. **Developing** — Building capabilities, addressing gaps
3. **Strategic** — Strong, repeatable capabilities across most domains
4. **Advanced** — Proactive, broad control over entire digital estate

---

## 6. Quiz Answers

### Quiz 1: Defining Digital Sovereignty and the Sovereign Cloud
1. **D** — Assurance sovereignty
2. **C** — Digital autonomy
3. **C** — Technology sovereignty
4. **D** — The sovereign AI opportunity (Artificial Intelligence challenge)
5. **C** — Operational independence and data residency
6. **D** — Sovereignty means that only domestic providers can be used
7. **D** — Operational sovereignty

### Quiz 2: The Intertwined Pillars of Sovereignty
1. **B** — Data, technology, operational, and assurance sovereignty
2. **C** — Data sovereignty includes governance, control, and jurisdictional laws, whereas data residency primarily concerns the geographic storage location
3. **D** — Organizations must have verifiable trust in the software supply chain through reproducible builds and SBOMs
4. **A** — Personnel who administer and support the infrastructure must meet specific criteria, such as citizenship or residency
5. **C** — Continuously validating and auditing that data, technology, and operations comply with sovereign policies
6. **D** — Achieving control in one domain, such as Data Sovereignty, requires trusted technology and controlled operations
7. **A** — It is often open source, to enable transparency, independent audits, and localized support

### Quiz 3: Architectural Design and Sovereign Controls
1. **C** — Private Cloud
2. **B** — Single tenancy
3. **C** — Data in Use (Confidential Computing)
4. **C** — The sovereign entity owns and manages the keys separately from the cloud provider
5. **C** — A Software Bill of Materials
6. **D** — The compliance and governance team

### Quiz 4: European Framework: Cloud Sovereignty and Assurance Levels
1. **C** — The Sovereignty Effectiveness Assurance Levels
2. **A** — The Sovereignty Score
3. **D** — SOV-5: Supply Chain Sovereignty
4. **B** — SOV-8: Environmental Sustainability
5. **B** — SOV-3: Data & AI Sovereignty
6. **C** — SOV-4: Operational Sovereignty
7. **D** — SOV-7: Security & Compliance Sovereignty
8. **A** — SOV-6: Technology Sovereignty
9. **C** — SEAL-2: Data Sovereignty
10. **B** — SEAL-4: Full Digital Sovereignty

### Quiz 5: The Red Hat Approach to Sovereignty
1. **B** — A strategy for achieving compliance, control, and autonomy over digital assets
2. **D** — It provides the transparency and auditability that proprietary solutions lack
3. **B** — It ensures that you are not locked into any single vendor or platform
4. **C** — It simplifies regulatory compliance by being designed to meet stringent global standards such as FIPS 140-2
5. **A** — It provides a consistent application platform that abstracts the underlying infrastructure and runs identically anywhere
6. **C** — Red Hat Advanced Cluster Management for Kubernetes
7. **B** — Red Hat Confirmed Sovereign Support

---

*Source: Red Hat Learning — Achieving Digital Sovereignty in the Cloud (do0042l-4.18-ed3-20260430)*
