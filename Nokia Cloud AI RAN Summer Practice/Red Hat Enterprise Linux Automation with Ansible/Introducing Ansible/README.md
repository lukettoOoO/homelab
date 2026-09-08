# Chapter 1: Introducing Ansible

> **Course:** Red Hat Enterprise Linux Automation with Ansible (RH294)  
> **Topic:** Introduction to Ansible, Architecture, and Control Node Setup

---

## 1. Motivation for Automation & Infrastructure as Code (IaC)

### The Problem with Manual Administration

- **Error-prone:** System administrators following manual checklists or memory can easily skip steps or introduce typos.
- **Configuration Drift:** When servers are individually configured, subtle differences creep in over time, resulting in non-identical environments that cause stability and maintenance issues.
- **Limited Verification:** Manual steps rarely provide instant verification that the system is in the exact intended state.

### Infrastructure as Code (IaC) & The Ansible Way

- **Definition:** Defining and describing the desired state of IT infrastructure using a human- and machine-readable automation language.
- **Version Control Integration:** Automation scripts stored as plain text files in Git allow tracking change history, code reviews, pull requests, and rollback to known-good configurations.
- **Declarative / Desired-State Thinking:**
  - Ansible is **declarative**, not procedural. You specify _what the final state should be_ (e.g., "service `httpd` must be running"), and Ansible determines how to achieve it.
  - **Idempotence:** Running a playbook repeatedly produces the same result. If the system is already in the desired state, Ansible makes no changes.
- **Simplicity & Readability:** "Complexity kills productivity." Playbooks are human-readable YAML documents designed so that developers, operators, and security teams can easily read and audit them.

---

## 2. Core Architecture & Concepts

Ansible uses a lightweight, **agentless** architecture consisting of two roles:

```
+------------------------------------+
|            Control Node            |
|   (Ansible Core, Playbooks,        |
|    ansible-navigator, Podman)      |
+-----------------+------------------+
                  |
         SSH (Linux) / WinRM (Windows) / APIs (Network)
                  |
       +----------+----------+
       |                     |
       v                     v
+--------------+      +--------------+
| Managed Node |      | Managed Node |
|  (Linux/UNIX)|      |  (Windows)   |
| Python 3.x   |      | PowerShell   |
+--------------+      +--------------+
```

### Key Components

1. **Control Node:**
   - The machine from which automation is run.
   - Houses playbooks, inventories, and configuration files.
   - Requires Linux/UNIX with Python (Windows cannot be a control node).
2. **Managed Hosts:**
   - The destination systems managed by Ansible.
   - **Agentless:** No persistent background daemon or proprietary agent is installed on the host. Ansible connects over SSH (or WinRM), pushes small ephemeral module scripts, executes them, and removes them when complete.
3. **Inventory:**
   - A file or dynamic script defining the hosts and groups that Ansible manages (e.g., INI or YAML format).
4. **Playbooks & Plays:**
   - **Playbook:** A YAML file containing one or more plays.
   - **Play:** Maps a set of hosts to a series of ordered tasks.
5. **Modules:**
   - Small, discrete tools that perform specific tasks (e.g., `ansible.builtin.dnf`, `ansible.builtin.service`, `ansible.builtin.copy`).
6. **Plug-ins:**
   - Code that extends Ansible's core functionality (connection plugins, lookup plugins, filter plugins).

---

## 3. Managed Host Requirements

| Platform              | Connection Protocol                    | Host Requirements                                                                      | Note                                                                       |
| :-------------------- | :------------------------------------- | :------------------------------------------------------------------------------------- | :------------------------------------------------------------------------- |
| **Linux / UNIX**      | SSH (default)                          | Python 3.8+; `python3-libselinux` (if SELinux is enforcing); sudo/superuser privileges | Modules run remotely on the managed host.                                  |
| **Microsoft Windows** | WinRM                                  | PowerShell 3.0+; .NET Framework 4.0+; WinRM configured                                 | Uses `ansible.windows` collection modules.                                 |
| **Network Devices**   | SSH (CLI/XML) or HTTP/HTTPS (REST API) | Device-specific APIs/credentials                                                       | **Modules execute locally on the Control Node**, not on the switch/router. |

---

## 4. Community Ansible vs. Red Hat Ansible Automation Platform (AAP)

| Component / Feature               | Community Ansible                                                                           | Red Hat AAP (Enterprise)                                                                                                    |
| :-------------------------------- | :------------------------------------------------------------------------------------------ | :-------------------------------------------------------------------------------------------------------------------------- |
| **Ansible Core (`ansible-core`)** | Upstream runtime engine + `ansible.builtin` modules. Distributed via PyPI or Linux distros. | Included with limited scope in RHEL AppStream; fully supported with AAP subscription.                                       |
| **Content Collections**           | Community collections available on [Ansible Galaxy](https://galaxy.ansible.com).            | Red Hat Certified & Supported Collections on Automation Hub.                                                                |
| **Primary CLI Tool**              | Traditional `ansible`, `ansible-playbook`, `ansible-doc`.                                   | `ansible-navigator` (container-based TUI/CLI).                                                                              |
| **Execution Environment**         | Control node acts as runtime environment directly.                                          | **Automation Execution Environments (EE)**: Container images (via Podman) packaging Ansible, collections, and dependencies. |
| **Web UI & Orchestration**        | Upstream AWX.                                                                               | **Automation Controller** (formerly Red Hat Ansible Tower).                                                                 |
| **Private Registry**              | Upstream Galaxy / Container Registries.                                                     | **Private Automation Hub**.                                                                                                 |

---

## 5. Automation Content Navigator (`ansible-navigator`) & Execution Environments (EE)

### What is an Execution Environment (EE)?

- A standardized **container image** (built on Podman/Docker) that packages:
  - `ansible-core`
  - Python runtime and dependencies
  - Pre-installed Ansible Collections and modules
- Eliminates dependency drift ("works on my machine" issues across teams).

### Role of `ansible-navigator`

- Acts as a wrapper and top-level terminal interface (TUI) replacing individual utilities:
  - `ansible-playbook` &rarr; `ansible-navigator run <playbook.yml>`
  - `ansible-doc` &rarr; `ansible-navigator doc <module>`
  - `ansible-inventory` &rarr; `ansible-navigator inventory`
- Runs tasks inside an Execution Environment container transparently.

---

## 6. Practical Setup Guide (Rocky Linux / Homelab)

Red Hat classroom labs rely on subscription-locked RPMs and internal lab networks (`lab start`, `utility.lab.example.com`). Below is how to set up and run the same environment for free on **Rocky Linux**:

### Approach A: Standalone CLI (Direct & Lightweight)

```bash
# 1. Install Ansible Core
sudo dnf install -y ansible-core

# 2. Verify installation
ansible --version

# 3. Test local execution
ansible localhost -m ansible.builtin.ping
```

### Approach B: Full `ansible-navigator` + Community Execution Environment

```bash
# 1. Install build dependencies and Podman (needed on aarch64/x86_64)
sudo dnf install -y podman pipx python3-devel gcc oniguruma-devel

# 2. Install ansible-navigator via pipx
pipx install --force ansible-navigator
pipx ensurepath
source ~/.bashrc

# 3. Pull the official open-source multi-arch Execution Environment
podman pull quay.io/ansible/creator-ee:latest

# 4. Configure ansible-navigator defaults (~/.ansible-navigator.yml)
cat << 'EOF' > ~/.ansible-navigator.yml
---
ansible-navigator:
  execution-environment:
    container-engine: podman
    enabled: true
    image: quay.io/ansible/creator-ee:latest
    pull:
      policy: missing
EOF

# 5. Inspect available EE images (Interactive TUI)
ansible-navigator images
```

### Quick Command Mapping

| Red Hat Lab Command                             | Standard Ansible Equivalent                | Purpose                              |
| :---------------------------------------------- | :----------------------------------------- | :----------------------------------- |
| `ansible-navigator run site.yml -m stdout`      | `ansible-playbook site.yml`                | Execute a playbook                   |
| `ansible-navigator run site.yml --syntax-check` | `ansible-playbook --syntax-check site.yml` | Syntax check                         |
| `ansible-navigator doc dnf`                     | `ansible-doc dnf`                          | View module documentation & examples |
| `ansible-navigator inventory --graph`           | `ansible-inventory --graph`                | Show host grouping tree              |
