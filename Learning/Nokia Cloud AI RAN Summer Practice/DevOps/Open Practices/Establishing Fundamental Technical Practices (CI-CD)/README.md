# Establishing Fundamental Technical Practices

> Red Hat TL250 — Chapter 3 | Open Practice Library

---

## Overview

Technical foundation practices that **improve lead time and quality** of delivered value. All four topics covered are **technical foundation practices** in the Mobius Loop, most often applied during the **Delivery Loop**.

| Practice            | OPL Category         | Primary Mobius Phase |
| ------------------- | -------------------- | -------------------- |
| CI/CD               | Technical Foundation | Delivery Loop        |
| Everything as Code  | Technical Foundation | Delivery Loop        |
| Security Automation | Technical Foundation | Delivery Loop        |
| The Big Picture     | Technical Foundation | All phases           |

---

## 3.1 Continuous Integration and Delivery (CI/CD)

### Core Concepts

| Term                            | Definition                                                                                                             |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Continuous Integration (CI)** | Integrating code changes often — several times per day — to reduce integration problems                                |
| **Continuous Delivery (CD)**    | Making each change a potential release; enables deployment at any time; implies automation of QA and release processes |
| **Continuous Deployment**       | A variant of CD where automation **releases and deploys all changes** automatically; maximizes release frequency       |

> **Key insight:** The longer a branch lives in isolation, the harder integration becomes. Frequency reduces risk.

### CI vs CD vs Continuous Deployment — Comparison

```
Continuous Integration:
  Commit → Build → Integration Tests → [Manual Release Decision]

Continuous Delivery:
  Commit → Build → Tests → Create Release → Test Release → [Manual Deploy]

Continuous Deployment:
  Commit → Build → Tests → Create Release → Test Release → Auto-Deploy
```

### Why Problems Grow Without CI

- Version control can detect some conflicts (e.g., file deleted vs. file modified)
- Compilers catch some errors (e.g., renamed function called by old name)
- But **behavior differences** from dependency changes only surface after integration
- Scale and complexity **grow as changes accumulate** without integration

### Benefits

- Reduces **lead time** for delivering new features
- Enables **small-batch changes** → better A/B testing, easier rollbacks
- Provides **fail-fast feedback** — defects identified early when they're cheaper to fix
- Supports **security automation** and **test automation** in the pipeline
- Enables **more experiments** to validate feature value

### Four Key Metrics (State of DevOps Report)

| Metric                      | CI/CD Relevance                                                            |
| --------------------------- | -------------------------------------------------------------------------- |
| **Deployment Frequency**    | Low frequency → indicates manual, labor-intensive deployment               |
| **Lead Time for Changes**   | Long lead times → delivery bottlenecks (use Metrics-based Process Mapping) |
| **Time to Restore Service** | Long restore times → quality issues                                        |
| **Change Failure Rate**     | High rate → quality issues                                                 |

### When to Adopt CI/CD

- **Immediately** for new projects — delay increases implementation cost
- Signs you need it:
  - Big-bang releases every few months followed by hot-fix periods
  - Manual, error-prone deployment processes
  - Delayed defect identification
  - Customers discover unused features (indicates need for shorter feedback cycles)

### Implementation Approach

1. Identify bottlenecks from Metrics-based Process Mapping
2. Product owners assess quality, security, and feedback frequency requirements
3. Work **incrementally** on addressing bottlenecks
4. CI/CD tool integrates with version control; runs processes on change events
5. Define policies around CI/CD process outcomes (e.g., failed test blocks merge)

### Critical Success Factor

> **Team agreement is essential.** The team must treat CI/CD as a critical component of development and dedicate necessary resources. Problems like slowness or unreliability cause developers to abandon it.

### Chaining with Other Practices

- **Metrics-based Process Mapping** → identifies bottlenecks CI/CD should address
- **The Big Picture** → visualizes the CI/CD system
- **Security Automation** → embedded in the CI/CD pipeline
- **Everything as Code** → enables CI/CD to apply to all artifacts

---

## 3.2 Everything as Code (EaC)

### Core Concept

Originating from **Infrastructure as Code**, the Everything as Code practice extends software development processes (version control, code review, static analysis, CI/CD) to **all components** of the software delivery system — not just application source code.

> Any component defined as **plain text files** is a candidate for Everything as Code.

### Components That Benefit from EaC

| Component            | Example                                       |
| -------------------- | --------------------------------------------- |
| Infrastructure       | Ansible Playbooks, Terraform configs          |
| Pipeline definitions | Jenkinsfiles, `.gitlab-ci.yml`, shell scripts |
| Configuration files  | YAML configs, environment settings            |
| Documentation        | Markdown files in version control             |
| Security rules       | Policy-as-code, compliance checks             |

### Benefits of Applying Software Development Practices to All Artifacts

| Practice                                | Benefit                                                                                                                     |
| --------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Source Control**                      | Tracks and logs all changes; enables traceability; meets audit requirements                                                 |
| **Code Review**                         | Finds issues before release; improves maintainability; reduces silos; supports compliance                                   |
| **Static Analysis / Linting**           | Detects issues beyond basic validation (e.g., unused config, security misconfigs)                                           |
| **CI/CD**                               | Extends deployment frequency and lead time benefits to infrastructure and config                                            |
| **Automated Testing & Reproducibility** | Infrastructure can be rebuilt quickly; enables recovery from failures; test new changes against a freshly built environment |

### When to Adopt EaC

Signs you need it:

- Team members fear updating or rebuilding systems (lack of reproducibility)
- Frequent issues from not knowing **what changed and why**
- Audit and compliance requirements
- High change failure rates
- Manual, error-prone processes

### Implementation Approach

1. Identify artifacts with the **most manual processes** — highest need for EaC
2. Implement **incrementally** (not all at once) to maximize benefit-to-cost ratio
3. Implement **new artifacts as code from the start** to avoid future migration costs
4. After treating an artifact as code, **disallow changes outside agreed procedures** (e.g., no console changes — only version-controlled changes)

> **Anti-pattern:** Using a web GUI (e.g., OpenStack Dashboard) to create VMs instead of Ansible Playbooks — changes cannot be tracked, rolled back, or automated.

### Practical Example

**Ansible Playbook for VM creation:**

```yaml
- name: create a VM
  hosts: localhost
  tasks:
    - name: launch an instance
      openstack.cloud.server:
        state: present
        auth:
          auth_url: https://identity.example.com
          username: admin
          password: '{{ openstack_password }}' # variable, NOT hardcoded
          project_name: admin
        name: application-vm
        image: base-image
        flavor: 101
```

With this in version control the team can:

- Auto-create a new VM for each playbook version
- Auto-run smoke tests on the new VM
- Roll back to a previous playbook version if smoke tests fail

**Pipeline as shell script:**

```sh
#!/bin/sh
set -e
make unit_tests
make setup_integration_environment
make integration_tests
make deploy
```

Code review now tracks **any removal of test steps** — who changed it, why, who approved.

### Chaining with Other Practices

- **Impact and Effort Prioritization** → decide where to apply EaC first
- **Test Automation** → apply to EaC artifacts
- **CI/CD** → apply to EaC artifacts to reduce lead times and integration problems
- **Code Review** → apply to EaC artifacts to improve quality
- **Definition of Done** → require that artifacts are reproducible

---

## 3.3 Security Automation

### The Problem with Traditional Security

Traditional security teams are responsible for:

- Ensuring architectural standards are met
- Assessing risks of changes
- Reviewing proposed changes
- Reviewing security incidents post-deployment

> Security evaluated **late** in the pipeline = expensive, slow feedback. Issues can go undetected for long periods with significant business impact.

### DevSecOps Mindset

Extend the DevOps philosophy to security:

| Team         | Incentive                          | DevOps Solution                     |
| ------------ | ---------------------------------- | ----------------------------------- |
| Dev          | Deploy new capabilities            | Automate quality checks in pipeline |
| Ops          | Maintain stable, reliable services | Automate reliability testing        |
| **Security** | Prevent increased business risk    | **Automate security evaluations**   |

> Security automation **rejects or accepts software for deployment** after evaluating against known security criteria.

### Signs an Organization Needs Security Automation

- Infrequent deployments due to monthly security evaluations
- Software frequently rejected by security/QA teams late in the cycle
- Repeated security incidents from inconsistent config verification
- Difficulty passing compliance audits
- Change Advisory Board (CAB) has become an approval bottleneck rather than advice

### Benefits

- **Built-in security** from the start of development
- **Consistent evaluation** of security policies
- **Shorter feedback loops** → lower cost and impact of security issues

### Security Test Types (in Pipeline Order)

| Test Type                                           | When It Runs        | What It Does                                                                             |
| --------------------------------------------------- | ------------------- | ---------------------------------------------------------------------------------------- |
| **Pre-commit Checks**                               | Before commit       | Prevents secrets/passwords from being committed to version control                       |
| **SAST** (Static Application Security Testing)      | Before/during build | Analyzes source code for common security vulnerabilities; runs in IDE or CI              |
| **SCA** (Software Composition Analysis)             | During build        | Identifies vulnerabilities in third-party components and libraries                       |
| **DAST** (Dynamic Application Security Testing)     | Against running app | Tests vulnerabilities by interacting with the running application; no source code access |
| **IAST** (Interactive Application Security Testing) | Against running app | Hybrid SAST + DAST; uses internal app telemetry + runtime interactions                   |
| **Fuzz Testing**                                    | Against running app | Sends invalid/random data to the app; monitors for stability/reliability changes         |
| **Application Monitoring & Alerting**               | Post-deployment     | Monitors telemetry; alerts on specific conditions before issues affect many customers    |
| **Penetration Testing**                             | Post-deployment     | Authorized attempts to exploit the system; may include a "Red Team" of ethical hackers   |

> **Principle:** Place **fast, cheap** security tests **early** in the pipeline. Reserve expensive tests (DAST, pen testing) for later stages.

### Fail-Fast Approach to Security

```
Pre-commit → SAST → SCA → Build → DAST/IAST → Fuzz → Deploy → Monitor
    ↑           ↑       ↑                ↑          ↑        ↑
  Cheap &                                        Expensive &
  Instant                                         Thorough
```

### Chaining with Other Practices

- **Metrics-based Process Mapping** → identify security process bottlenecks
- **Everything as Code** → security rules and compliance tests stored in version control
- **CI/CD** → incorporate security tests into the pipeline; fast tests go first
- **The Big Picture** → visualize where security automation fits in the delivery pipeline

---

## 3.4 The Big Picture

### Core Concept

A **physical or digital display** of all steps in a software delivery pipeline. Shows how code moves from source control through compilation, testing, and into users' hands.

> The Big Picture is a **language bridge** between technical and non-technical people. It is a **living information radiator**.

### Benefits

- Enables team members to **physically point at** system components when explaining
- Describes how components **fit together** and the **purpose of each component**
- Reduces **cognitive load** in rapidly changing environments
- Helps achieve **team alignment** on the software delivery system
- Guides **technical strategy discussions** and stakeholder demos

### When to Use It

- **Any team** benefits — not just those with mature CI/CD
- Even without full automation, helps track:
  - Developer tooling
  - Application software stack
  - Runtime environments

### Time Required

| Starting Point                                   | Time Estimate   |
| ------------------------------------------------ | --------------- |
| Visualizing an existing, well-understood system  | ~1 hour or less |
| Designing a new system (design decisions needed) | Several hours   |

### Facilitation Steps

1. **Create rectangular areas** on a wall using masking tape — one per environment
   - Examples: developer workstations, CI/CD, test/staging, production
   - Reserve a **center rectangle** for the conceptual CI/CD process flow
   - Use a single large rectangle labeled "OpenShift" for container-based environments
2. **Add a legend** — define color-coding and sticky note shapes
3. **Workstations environment:** add sticky notes for dev tools (IDEs, languages, frameworks)
4. **CI/CD environment:** add sticky notes for each CI/CD tool
5. **Downstream environments:** add sticky notes for test, integration, production outputs and container deployments
6. **Conceptual process section:** arrange CI/CD steps left-to-right in chronological order; parallel steps vertically
7. **Beneath each tool:** add sticky notes describing each step it performs (compile, unit test, integration test, build container, deploy)
8. **Review with the entire team** — ensure every component is justified; walk the pipeline left-to-right
9. **Refine continuously** — anyone should be able to describe the pipeline using the Big Picture

### Tip for Decision Making

Place competing options on the Big Picture side by side (e.g., Jenkins vs. Tekton, Quay vs. Nexus). Rearrange and visualize how each decision affects the pipeline. Remove excluded options; document the reason in a separate "Decisions" artifact.

### Big Picture Components

| Environment Rectangle  | Contents                                  |
| ---------------------- | ----------------------------------------- |
| Developer Workstations | IDE, language runtimes, local test tools  |
| CI/CD                  | CI server, build tools, artifact registry |
| Test / Staging         | Deployed app versions, test runners       |
| Production             | Live deployments, monitoring tools        |
| Center (Process Flow)  | Ordered pipeline steps from left to right |

### Example Pipeline Steps (Sticky Notes)

```
[Commit] → [Build] → [Unit Test] → [SAST] → [Bake Image] → [Deploy to Test]
         → [Integration Test] → [Security Scan] → [Deploy to Prod]
```

### Chaining with Other Practices

- **CI/CD** → showcasing the CI/CD system is the primary goal of the Big Picture
- **Test-Driven Development** → illustrate where and how tests execute in the pipeline
- **Blue/Green Deployments** → visualize environment split and traffic routing
- **Canary Releases** → illustrate gradual rollout environments
- **Security Automation** → show where each security test type is embedded

> The Big Picture is a **foundation practice** because it is used **throughout all parts** of the Mobius Loop.

---

## Summary

| Practice                | Key Takeaway                                                                                                                |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **CI/CD**               | Integrate often, automate quality gates — reduces lead time and integration risk; fail-fast feedback                        |
| **Everything as Code**  | Apply version control, code review, and CI/CD to all artifacts (infra, pipelines, config, docs)                             |
| **Security Automation** | Embed security tests throughout the pipeline — fast tests early, thorough tests later; never delay security to end          |
| **The Big Picture**     | A living visual map of the software delivery pipeline; bridges technical and non-technical; used throughout the Mobius Loop |

### How These Practices Interlock

```
Everything as Code
        ↓ (stores all artifacts as text)
      CI/CD
        ↓ (runs automated processes on every change)
  Security Automation         ←── embedded inside CI/CD pipeline
        ↓
   The Big Picture  ←── visualizes the entire system for alignment
```

> **Common thread:** All four practices aim to make software delivery **faster, safer, more transparent, and reproducible**.
