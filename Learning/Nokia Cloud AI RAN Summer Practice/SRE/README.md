# TL012 – Transitional Approach to Implementing Pragmatic Site Reliability Engineering (SRE)
## Technical Overview

> **Course:** TL012 | **Provider:** Red Hat Training  
> **Category:** Free / Technical Overview  
> **Date completed:** 2026-09-16

---

## Course Overview

Site Reliability Engineering (SRE) is a **shared responsibility model** that, when executed well, improves efficiency, resiliency, and security.

Implementing SRE in an organization requires:
- Cultural shift
- Team shaping and training
- A **transitional** (pragmatic, incremental) approach — not an overnight transformation

This course provides a technical overview of how to pragmatically transition an existing organization toward SRE practices, and how SRE strategies improve system performance and time-to-market.

---

## Target Audience

- IT Managers and Leaders
- System Administrators and DevOps Engineers
- Software Engineers transitioning into reliability-focused roles

---

## 1. What is SRE?

- SRE applies **software engineering principles to operations** to build scalable, reliable, and efficient systems.
- Originated at **Google** — SREs wrote code to automate operations tasks that would otherwise require manual intervention.
- SRE is not a job title alone; it is a **discipline and practice set**.
- Core mandate: "Hope is not a strategy." Reliability must be engineered deliberately.

### SRE vs DevOps

| Aspect | SRE | DevOps |
|---|---|---|
| Focus | System reliability & performance | CI/CD pipeline & collaboration culture |
| Approach | Engineering-driven operations | Cultural movement integrating dev + ops |
| Key metric | Error budgets, SLOs | Deployment frequency, lead time |
| Roles | Dedicated SRE role | Shared responsibility across teams |

> SRE and DevOps are **complementary**, not competing. SRE can be thought of as a concrete implementation of DevOps principles.

---

## 2. Key SRE Metrics — SLIs, SLOs, and SLAs

### SLI — Service Level Indicator
- A **quantitative measure** of some aspect of the level of service being provided.
- Examples: request latency, error rate, availability (uptime %), throughput.
- SLIs are the raw signals: "What are we measuring?"

### SLO — Service Level Objective
- A **target value or range** of values for a service level measured by an SLI.
- Example: "99.9% of requests will return within 300ms over a 30-day window."
- SLOs are the reliability targets: "What level do we commit to internally?"
- SLOs should be **aspirational but achievable** — setting them too high removes the innovation budget.

### SLA — Service Level Agreement
- A **contract** between a service provider and its customers defining the expected level of service and consequences of failure (e.g., credits, penalties).
- SLA = externally-facing commitment; SLO = internal target (typically stricter than SLA).

### Relationship
```
SLI  →  measure of reality
SLO  →  internal target derived from SLIs
SLA  →  customer-facing contract derived from SLOs
```

---

## 3. Error Budgets

- An **error budget** is the maximum amount of allowable unreliability within an SLO window.
- Formula: `Error Budget = 1 − SLO`
  - Example: SLO = 99.9% availability → Error budget = 0.1% downtime allowed per period.

### Why Error Budgets Matter
- They create a **shared language** between Dev and Ops.
- If the error budget is **healthy** → Dev can ship new features aggressively.
- If the error budget is **exhausted** → Teams must pause new releases and focus on reliability improvements.
- Transforms the tension between "ship fast" and "stay reliable" into a data-driven conversation.

### Error Budget Policy
- Defines what happens when the budget is consumed (e.g., feature freeze, mandatory postmortems, SRE veto on deployments).

---

## 4. Toil — Identification and Reduction

### What is Toil?
Toil is work that is:
- **Manual** — requires a human to do it
- **Repetitive** — done over and over
- **Automatable** — could be done by a machine
- **Reactive** — triggered by events, not proactively planned
- **Devoid of long-term value** — gets the system back to the same state rather than improving it

> "If a human operator needs to touch your system during normal operations, you have a bug." — SRE principle

### Toil vs Engineering Work

| Toil | Engineering Work |
|---|---|
| Repetitive manual tasks | Automation, tooling, improvements |
| Scales with service growth | Scales sub-linearly or not at all |
| Temporary relief | Permanent improvement |

### Toil Budget
- SRE teams aim to keep toil at **< 50% of their time** — the rest is dedicated to engineering work that permanently reduces toil.

---

## 5. Incident Management

### Incident Lifecycle
1. **Detection** — Alerts fire based on SLO violations or anomaly detection
2. **Triage** — Assess severity, impact, and urgency
3. **Mitigation** — Restore service (may not fix root cause)
4. **Resolution** — Root cause fixed and confirmed
5. **Postmortem** — Learning and prevention

### Severity Levels (typical)

| Severity | Impact | Response Time |
|---|---|---|
| SEV-1 | Critical — full outage | Immediate (24/7) |
| SEV-2 | Major — significant degradation | Within minutes |
| SEV-3 | Minor — partial/small impact | Within hours |
| SEV-4 | Informational | Business hours |

### On-Call Best Practices
- Clear escalation paths and runbooks
- Limit on-call load to prevent burnout
- Incident command structure for large incidents (Incident Commander, Communications Lead, Operations Lead)

---

## 6. Blameless Postmortems

A **postmortem** (or post-incident review) is a written record of an incident that includes:

### Key Elements
- **Timeline** of events
- **Root cause analysis** (5 Whys, fishbone, etc.)
- **Impact** (user-facing and business impact)
- **Detection** — how was the incident found?
- **Response** — what actions were taken?
- **Action items** — concrete, assigned, time-bound follow-ups
- **Lessons learned**

### Blameless Culture
- The goal is to understand **what** happened, not **who** to blame.
- Assumes people act with good intentions given the information available at the time.
- Psychological safety encourages honest, thorough reporting.
- Blameless does not mean accountability-free: systems and processes are improved, not individuals punished.

> "Every system is perfectly designed to get the results it gets." — Blameless postmortem principle

---

## 7. Operational Practices & Automation

### Infrastructure as Code (IaC)
- Treat infrastructure configuration as software (versioned, reviewed, tested).
- Tools: **Terraform**, **Ansible**, **Helm**
- Benefits:
  - Eliminates configuration drift
  - Enables repeatable, auditable deployments
  - Supports rapid scaling aligned with SRE principles

### Monitoring & Observability

The three pillars of observability:

| Pillar | What it measures | Examples |
|---|---|---|
| **Metrics** | Numeric time-series data | CPU, latency, error rate |
| **Logs** | Structured/unstructured event records | Application logs, audit logs |
| **Traces** | Request flow across distributed systems | Distributed tracing (Jaeger, Zipkin) |

- **Alerting** should be tied to **SLO violations**, not just resource thresholds.
- Prefer **symptom-based alerting** (user-facing impact) over **cause-based alerting** (CPU high).

### Capacity Planning
- Proactively forecast resource needs before demand hits.
- Use auto-scaling and load balancing to handle variable traffic.
- Avoid "just add more hardware" as the only answer — optimize first.

### Cloud-Native & Kubernetes
- Container orchestration (Kubernetes) aligns with SRE's automation and resilience goals.
- Enables: self-healing deployments, rolling updates, auto-scaling, resource isolation.

---

## 8. Reliability Metrics

### MTTR — Mean Time to Recovery/Repair
- Average time to restore service after a failure.
- SRE priority: **minimize MTTR** through better alerting, runbooks, and automation.

### MTTF — Mean Time to Failure
- Average time between failures.
- SRE priority: **maximize MTTF** through robust design, testing, and change management.

### MTTD — Mean Time to Detect
- Average time to detect that a failure has occurred.
- Good monitoring and alerting directly reduces MTTD.

### Availability Formula

$$\text{Availability} = \frac{\text{MTTF}}{\text{MTTF} + \text{MTTR}} \times 100\%$$

### Availability Nines Table

| Availability | Downtime per year | Downtime per month |
|---|---|---|
| 99% ("two nines") | ~87.6 hours | ~7.3 hours |
| 99.9% ("three nines") | ~8.76 hours | ~43.8 min |
| 99.99% ("four nines") | ~52.6 min | ~4.4 min |
| 99.999% ("five nines") | ~5.26 min | ~26 sec |

---

## 9. Cultural Transformation & Team Shaping

### The Shared Responsibility Model
- SRE works only when **both development and operations share ownership** of reliability.
- Error budgets enforce this: dev cannot ship if they break reliability.

### SRE Team Models

| Model | Description |
|---|---|
| **Kitchen Sink (Pure SRE)** | Dedicated SRE team owns everything |
| **Embedded SRE** | SREs embedded within product teams |
| **Consulting SRE** | SRE team acts as advisors / center of excellence |
| **Enabling SRE** | SRE team builds platforms and tools for dev teams |

### Moving from Reactive to Proactive
- Old model: "firefighting" — ops teams react to outages
- New model: proactive reliability engineering — build reliability in from the start

### Training and Onboarding
- SREs need both software engineering skills and systems/operations knowledge.
- Invest in cross-training between dev and ops teams.
- Use game days / chaos engineering to build resilience muscle memory.

---

## 10. Transitional Approach — Pragmatic Implementation

The course emphasizes a **gradual, pragmatic transition** rather than a "big bang" SRE adoption.

### Phase 1 — Foundation
- Define your current state (what services, what reliability exists today)
- Identify the most critical services
- Start defining SLIs for those services

### Phase 2 — Measurement
- Instrument services to capture SLI data
- Set initial SLOs (can be relaxed; the goal is to start measuring)
- Identify top sources of toil

### Phase 3 — Error Budgets & Incident Process
- Introduce error budgets as a team concept
- Formalize incident management and postmortem process
- Begin reducing toil through automation

### Phase 4 — Culture & Scale
- Expand SRE practices to more services
- Build or adopt an internal SRE platform
- Foster psychological safety and blameless culture organization-wide

> **Key Insight:** Implement what is pragmatic for your organization's maturity level. Not every team needs "five nines" reliability. Match your SLO to real user needs and business requirements.

---

## Key Takeaways

1. **Reliability is a feature** — it must be engineered, not assumed.
2. **SLOs are the contract between dev and ops** — error budgets make reliability a shared problem.
3. **Toil is the enemy of progress** — automate everything automatable.
4. **Blameless postmortems build trust** — learn from failures, do not hide them.
5. **Observability is prerequisite to reliability** — you cannot fix what you cannot see.
6. **Transition gradually** — start with the most critical services, establish baselines, then scale.
7. **Culture is the hardest part** — technical practices fail without organizational buy-in.

---

## Related Resources

- [Google SRE Book (free online)](https://sre.google/sre-book/table-of-contents/)
- [Google SRE Workbook](https://sre.google/workbook/table-of-contents/)
- [Red Hat TL012 Course Page](https://www.redhat.com/en/services/training/transitional-approach-implementing-pragmatic-site-reliability-engineering-sre-technical-overview)
- [CNCF SRE Whitepaper](https://tag-app-delivery.cncf.io/)
