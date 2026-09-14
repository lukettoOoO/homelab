# Chapter 2: Implementing an Ansible Playbook

> **Course:** Red Hat Enterprise Linux Automation with Ansible (RH294)  
> **Topic:** Host Inventories, Configuration Files, Playbook Architecture, Multiple Plays, and LAMP Stack Automation

---

## 1. Building an Ansible Inventory

An inventory defines the collection of target systems (managed nodes) that Ansible automates.

### Static vs. Dynamic Inventories

- **Static Inventory:** A plain-text file (typically INI or YAML format) explicitly defining hosts, IP addresses, and groups.
- **Dynamic Inventory:** Generated on-the-fly using plug-ins or scripts that pull live infrastructure data from external cloud/enterprise systems (e.g., AWS EC2, OpenStack, Red Hat Satellite).

---

### INI-Style Inventory Syntax & Grouping

#### 1. Basic Groups and Hosts

```ini
[webservers]
web1.example.com
web2.example.com
192.168.1.50

[dbservers]
db1.example.com
db2.example.com
```

#### 2. Multiple Group Membership

A single host can belong to multiple groups organized by function, environment, or location:

```ini
[production]
web1.example.com
db1.example.com

[development]
web2.example.com
db2.example.com

[datacenter-east]
web1.example.com
web2.example.com
```

#### 3. Default Built-in Groups

Two groups always exist automatically:

- **`all`:** Contains every explicitly defined host in the inventory.
- **`ungrouped`:** Contains any host that does not belong to any user-defined group.

#### 4. Nested (Parent/Child) Groups (`:children`)

Use the `:children` suffix to define a parent group consisting of other groups:

```ini
[usa]
washington1.example.com
washington2.example.com

[canada]
ontario01.example.com
ontario02.example.com

[north-america:children]
usa
canada
```

#### 5. Simplifying Host Specifications with Ranges

You can specify alphanumeric ranges with `[START:END]` (inclusive):

- **Numeric ranges:** `server[01:20].example.com` (note: leading zeros are preserved).
- **IP ranges:** `192.168.[4:7].[0:255]`
- **Alphabetic ranges:** `server[a:d].lab.example.com` &rarr; `servera`, `serverb`, `serverc`, `serverd`.

> [!WARNING]
> Never name a host and a host group with the exact same name (e.g., a host named `web` inside a group named `[web]`), as Ansible will print a warning and produce ambiguous target selections.

---

### Verifying and Inspecting Inventories

| Action                           | Standard CLI Command                               | `ansible-navigator` Command                                            |
| :------------------------------- | :------------------------------------------------- | :--------------------------------------------------------------------- |
| **List all hosts/groups (JSON)** | `ansible-inventory -i inventory --list`            | `ansible-navigator inventory -i inventory -m stdout --list`            |
| **Graph entire inventory tree**  | `ansible-inventory -i inventory --graph`           | `ansible-navigator inventory -i inventory -m stdout --graph`           |
| **Graph specific group**         | `ansible-inventory -i inventory --graph web`       | `ansible-navigator inventory -i inventory -m stdout --graph web`       |
| **Graph ungrouped hosts**        | `ansible-inventory -i inventory --graph ungrouped` | `ansible-navigator inventory -i inventory -m stdout --graph ungrouped` |
| **Inspect specific host vars**   | `ansible-inventory -i inventory --host servera`    | `ansible-navigator inventory -i inventory -m stdout --host servera`    |
| **Interactive TUI Mode**         | _N/A_                                              | `ansible-navigator inventory -i inventory`                             |

---

## 2. Managing Ansible Configuration Files

Ansible behavior is controlled primarily through two configuration files:

1. **`ansible.cfg`:** Configures core Ansible runtime settings.
2. **`ansible-navigator.yml`:** Configures the automation content navigator TUI/runner.

### Configuration File Precedence (`ansible.cfg`)

Ansible searches for `ansible.cfg` in the following order and uses the **first** file it finds:

1. **`$ANSIBLE_CONFIG`** (environment variable)
2. **`./ansible.cfg`** (current working directory — **recommended project practice**)
3. **`~/.ansible.cfg`** (user's home directory — _ignored by `ansible-navigator`_)
4. **`/etc/ansible/ansible.cfg`** (global system default)

---

### Core Sections of `ansible.cfg`

```ini
[defaults]
inventory = ./inventory      # Path to the default inventory file or directory
remote_user = luca           # Default user to log in as over SSH
ask_pass = false             # Prompt for SSH password (false if using SSH keys)

[privilege_escalation]
become = true                # Automatically elevate privileges (sudo)
become_method = sudo         # Privilege escalation tool (sudo, su, etc.)
become_user = root           # Target user for privilege escalation
become_ask_pass = true       # Prompt for the sudo password
```

> [!NOTE]
> In `ansible.cfg`, comments can begin with `#` (comments the entire line) or `;` (inline comments).

---

### `ansible-navigator.yml` Settings

Placed in the project directory or `~/.ansible-navigator.yml`:

```yaml
---
ansible-navigator:
  execution-environment:
    image: quay.io/ansible/creator-ee:latest # Container EE image
    pull:
      policy: missing # Only pull if not locally cached
    enabled: true # Set to false to run directly on host
  playbook-artifact:
    enable: false # Disable JSON artifact files (REQUIRED if passwords prompt)
  mode: stdout # Default CLI mode ('stdout' or 'interactive')
```

> [!IMPORTANT]
> When `become_ask_pass = true` or `ask_pass = true` is used, `ansible-navigator` **must** have `playbook-artifact: enable: false` (or CLI flag `--pae false`) and use `-m stdout`, otherwise the interactive runner will hang waiting for terminal input.

---

## 3. Playbook Architecture & YAML Standards

- **Task:** The application of an Ansible module with arguments to perform a unit of work.
- **Play:** An ordered list of tasks mapped to a specific set of target hosts.
- **Playbook:** A plain-text YAML file containing one or more plays.

### YAML Rules for Ansible

- Begins with three dashes (`---`) and optionally ends with three dots (`...`).
- **Indentation:** Uses **spaces only** (never tabs). Standard convention is **2 spaces per indentation level**.
- **Lists:** Denoted by `- ` (dash followed by a space).
- **Dictionaries (Key-Value):** Denoted by `key: value` (colon followed by a space).
- **Multiline Strings:**
  - `|` (Literal block scalar): Preserves newlines.
  - `>` (Folded block scalar): Converts newlines to spaces (folds into a single sentence).

---

### Playbook Execution Lifecycle

```
$ ansible-navigator run -m stdout site.yml
  │
  ├─► 1. Syntax Check & Inventory Parsing
  │
  ├─► 2. TASK [Gathering Facts] (Runs ansible.builtin.setup unless gather_facts: false)
  │
  ├─► 3. Task 1 (e.g. Ensure package present)  --> ok / changed / failed
  │
  ├─► 4. Task 2 (e.g. Copy configuration file) --> ok / changed / failed
  │
  ├─► 5. Task 3 (e.g. Ensure service started)  --> ok / changed / failed
  │
  └─► 6. PLAY RECAP (Summary of ok, changed, unreachable, failed per host)
```

---

### Playbook CLI Options

- **Syntax check:**  
  `ansible-navigator run -m stdout site.yml --syntax-check`  
  _(Native: `ansible-playbook --syntax-check site.yml`)_
- **Dry run (Check mode):**  
  `ansible-navigator run -m stdout site.yml -C`  
  _(Native: `ansible-playbook -C site.yml`)_
- **Verbosity levels:**
  - `-v`: Shows task results.
  - `-vv`: Shows task results and configuration.
  - `-vvv`: Shows SSH connection and authentication details.
  - `-vvvv`: Maximum verbosity including connection plugins and remote scripts.

---

## 4. Implementing Multiple Plays

A single playbook can contain multiple plays. This is used to orchestrate workflows across different host groups and security tiers.

### Playbook Structure with Multiple Plays

```yaml
---
# ==========================================
# Play 1: Configure Managed Web Server
# ==========================================
- name: Enable intranet services
  hosts: servera.lab.example.com
  become: true # Privilege escalation enabled for this play
  tasks:
    - name: Ensure Apache and Firewall are installed
      ansible.builtin.dnf:
        name:
          - httpd
          - firewalld
        state: latest

    - name: Deploy index.html
      ansible.builtin.copy:
        content: "Welcome to the intranet!\n"
        dest: /var/www/html/index.html

    - name: Ensure firewalld is running and enabled
      ansible.builtin.service:
        name: firewalld
        state: started
        enabled: true

    - name: Permit HTTP service through firewall
      ansible.posix.firewalld:
        service: http
        permanent: true
        state: enabled
        immediate: true

    - name: Ensure Apache is running and enabled
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true

# ==========================================
# Play 2: Validate from Control Node / Client
# ==========================================
- name: Test intranet web server
  hosts: workstation.lab.example.com
  become: false # No sudo needed for a simple client curl/query
  tasks:
    - name: Connect to intranet web server
      ansible.builtin.uri:
        url: http://servera.lab.example.com
        return_content: true
        status_code: 200
```

---

### Remote User Precedence

Ansible selects the user account to log in as according to this strict order of precedence:

1. `ansible_user` variable set for the specific host or group in inventory/vars.
2. `remote_user` keyword specified in the play.
3. `remote_user` setting in `ansible.cfg`.
4. Default: `root` (inside Execution Environments) or the current OS user (native CLI).

---

## 5. Essential Ansible Modules Reference

Always use **Fully Qualified Collection Names (FQCN)**:

| Category     | Module (FQCN)                | Key Parameters                                                                  | Common Use Case                               |
| :----------- | :--------------------------- | :------------------------------------------------------------------------------ | :-------------------------------------------- |
| **Package**  | `ansible.builtin.dnf`        | `name`, `state` (`present`, `latest`, `absent`)                                 | Installing RPM packages via DNF               |
| **Files**    | `ansible.builtin.copy`       | `src`, `dest`, `content`, `mode`, `owner`, `group`                              | Copying files or writing raw string content   |
| **Files**    | `ansible.builtin.file`       | `path`, `state` (`directory`, `touch`, `absent`), `mode`                        | Managing directories, permissions, symlinks   |
| **Files**    | `ansible.builtin.lineinfile` | `path`, `line`, `regexp`, `state`                                               | Modifying single lines in configuration files |
| **Services** | `ansible.builtin.service`    | `name`, `state` (`started`, `stopped`, `restarted`), `enabled` (`true`/`false`) | Managing systemd services                     |
| **Firewall** | `ansible.posix.firewalld`    | `service`, `port`, `permanent`, `state`, `immediate`                            | Opening/closing firewalld ports and services  |
| **Network**  | `ansible.builtin.uri`        | `url`, `status_code`, `return_content`                                          | Testing web endpoints and REST APIs           |
| **User**     | `ansible.builtin.user`       | `name`, `uid`, `groups`, `state`, `remove`                                      | Managing Linux user accounts                  |

---

### Arbitrary Commands (`command` vs. `shell` vs. `raw`)

> [!CAUTION]
> Arbitrary command modules bypass Ansible's declarative state engine and are **not idempotent by default**. Use them only as a last resort when no dedicated module exists.

1. **`ansible.builtin.command`** (Safest):
   - Runs commands directly without invoking a shell.
   - Cannot use shell variables, pipes (`|`), or redirects (`>`, `<`).
   - Can achieve idempotency using `creates: /path/to/file` (only runs if file does not exist) or `removes: /path/to/file`.
2. **`ansible.builtin.shell`**:
   - Runs commands through `/bin/sh`.
   - Supports pipes, environment variables, and redirects.
3. **`ansible.builtin.raw`**:
   - Completely bypasses the Python module subsystem; executes raw commands over SSH.
   - Useful for bootstrapping Python on minimal hosts or managing network switches.

---

## 6. Practical Homelab / Rocky Linux Key Learnings

1. **Simulating Lab Nodes Locally:**  
   Map hostnames to `localhost` in `inventory` using `ansible_host=localhost ansible_connection=local` so you can test complete playbooks without needing multi-VM classroom networks.
2. **Local Host Resolution:**  
   Add entries like `127.0.0.1 servera.lab.example.com serverb.lab.example.com` to `/etc/hosts` so `curl` and `ansible.builtin.uri` work identically to the classroom.
3. **Managing Host Systemd Services:**  
   When managing local host services (`systemctl start httpd`, `firewalld`), set `execution-environment.enabled: false` in `ansible-navigator.yml` so Ansible runs natively against the host's systemd rather than inside a rootless container.
