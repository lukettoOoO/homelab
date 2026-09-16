# Chapter 3: Managing Variables and Facts

> **Course:** Red Hat Enterprise Linux Automation with Ansible (RH294)  
> **Topic:** Variables, Variable Scopes & Precedence, Host & Group Variables, Ansible Vault & Secrets, System Facts, Custom Facts (`facts.d`), Magic Variables, and End-to-End Secure Web Server Automation.

---

## 1. Ansible Variables & Syntax Standards

Variables store values that can be reused throughout an Ansible project. They simplify configuration management, make playbooks dynamic and modular across different environments (development, staging, production), and prevent hard-coding system-specific values.

### Variable Naming Rules

Variable names must adhere to strict naming conventions:

- Must begin with a letter (e.g., `web_port`, not `1st_port`).
- May contain letters, numbers, and underscores (`_`).
- Cannot contain spaces, hyphens (`-`), periods (`.`), or special characters.
- Must not collide with reserved Python keywords or Ansible built-in playbook keywords (such as `name`, `hosts`, `tasks`, `vars`, `environment`).

```yaml
# Valid variable names
web_package: httpd
db_port_3306: 3306
firewall_rules_enabled: true

# Invalid variable names
web-package: httpd # Hyphens are not allowed
1st_service: mariadb # Cannot start with a number
db.port: 3306 # Dots are reserved for dictionary traversal
```

---

### Defining Variables in Playbooks

#### 1. In-Play Variables (`vars`)

Variables can be placed directly at the play level within a `vars:` block:

```yaml
- name: Deploy Apache Web Server
  hosts: webserver
  vars:
    web_pkg: httpd
    web_service: httpd
    web_port: 80
  tasks:
    - name: Ensure Apache is installed
      ansible.builtin.dnf:
        name: '{{ web_pkg }}'
        state: present
```

#### 2. External Variable Files (`vars_files`)

To decouple data from execution logic, define variables in external YAML files and import them using `vars_files`:

```yaml
# vars/main.yml
web_pkg: httpd
web_service: httpd
doc_root: /var/www/html
```

```yaml
# playbook.yml
- name: Deploy Apache Web Server
  hosts: webserver
  vars_files:
    - vars/main.yml
  tasks:
    - name: Ensure Apache is running
      ansible.builtin.service:
        name: '{{ web_service }}'
        state: started
        enabled: true
```

---

### The Mandatory Quote Rule for Jinja2

In YAML, curly brackets (`{` and `}`) denote in-line dictionaries. If a YAML value starts with a Jinja2 delimiter (`{{ ... }}`), the YAML parser interprets it as an unclosed mapping and fails with a syntax error.

> [!IMPORTANT]
> **Always enclose the entire string in quotes whenever a YAML value starts with `{{`:**
>
> ```yaml
> # WRONG - Causes fatal YAML syntax error:
> content: {{ ansible_facts['fqdn'] }} has been configured.
>
> # CORRECT - Quoted string:
> content: "{{ ansible_facts['fqdn'] }} has been configured."
> ```

---

### Variable Data Structures: Lists & Dictionaries

#### 1. Lists (Arrays)

Ordered sequences of items referenced by index (`0`-indexed):

```yaml
users:
  - alice
  - bob
  - charlie

# Accessing elements:
# "{{ users[0] }}" -> alice
```

#### 2. Dictionaries (Key-Value Maps)

Key-value structures referenced using **Bracket Notation** or **Dot Notation**:

```yaml
users:
  bjones:
    first_name: Bob
    last_name: Jones
    uid: 1001
  asmith:
    first_name: Alice
    last_name: Smith
    uid: 1002
```

| Syntax Style                       | Example                               | Notes                                                                                     |
| :--------------------------------- | :------------------------------------ | :---------------------------------------------------------------------------------------- |
| **Bracket Notation (Recommended)** | `{{ users['bjones']['first_name'] }}` | Safe from collision with Python dictionary methods (`copy`, `keys`, `values`, `discard`). |
| **Dot Notation**                   | `{{ users.bjones.first_name }}`       | Shorter, but risks throwing errors if a key name collides with a Python method.           |

---

### Capturing Task Output with Registered Variables (`register:`)

Use the `register` directive on any task to save its return dictionary into a variable. The captured output can be inspected or used in downstream tasks:

```yaml
- name: Check status of custom configuration
  ansible.builtin.command: cat /etc/custom_build.id
  register: build_info
  changed_when: false

- name: Display captured output
  ansible.builtin.debug:
    msg: 'Build ID is {{ build_info.stdout }} (Return Code: {{ build_info.rc }})'
```

---

## 2. Variable Scopes & Precedence Hierarchy

Ansible supports variables at three primary scopes:

1. **Global Scope:** Set from the command line (`-e` / `--extra-vars`) or Ansible configuration. Applies to all plays and all hosts.
2. **Play Scope:** Set in play headers (`vars`, `vars_files`, roles). Applies only to tasks within that specific play.
3. **Host Scope:** Associated with specific managed nodes or inventory groups (`host_vars/`, `group_vars/`, inventory files, facts).

### Variable Precedence Hierarchy

When a variable with the same name is defined in multiple locations, Ansible resolves the conflict using a strict order of precedence. The simplified practical order (from **lowest** to **highest** priority) is:

```
[1] Inventory Group Variables (inventory file)
 └─► [2] group_vars/ files (group_vars/all, group_vars/<groupname>)
      └─► [3] Inventory Host Variables (inventory file)
           └─► [4] host_vars/ files (host_vars/<hostname>)
                └─► [5] Host Facts (gathered at runtime by setup module)
                     └─► [6] Play vars and vars_files
                          └─► [7] Task vars (vars: block on an individual task)
                               └─► [8] Extra vars (-e / --extra-vars CLI)  ◄── HIGHEST PRIORITY
```

> [!TIP]
> Extra variables passed on the command line (`ansible-navigator run playbook.yml -e "web_port=8080"`) override **all** other variable definitions in the project.

---

## 3. Organizing Host and Group Variables

While variables can be written directly inside INI/YAML inventory files, the official Red Hat best practice is to separate variables into dedicated directories alongside the inventory.

### Recommended Directory Layout

```
project/
├── ansible.cfg
├── inventory
├── playbook.yml
├── group_vars/
│   ├── all.yml                 # Variables applied to every host
│   ├── webservers.yml          # Variables applied to [webservers] group
│   └── databases.yml           # Variables applied to [databases] group
└── host_vars/
    ├── servera.lab.example.com.yml  # Variables specific to servera
    └── serverb.lab.example.com.yml  # Variables specific to serverb
```

### Single File vs. Directory of Files

Both `group_vars/` and `host_vars/` accept either single files matching the group/host name or subdirectories:

```
# Option A: Single file per group
group_vars/webservers.yml

# Option B: Subdirectory per group (useful for organizing large variable sets)
group_vars/webservers/
├── packages.yml
├── network.yml
└── users.yml
```

### Precedence Between Group Variables

If a host belongs to multiple groups that define the same variable:

1. `group_vars/all` has the **lowest** group precedence.
2. Parent group variables are overridden by **child group** variables.
3. If two sibling groups define the same variable, Ansible resolves them alphabetically or by the last loaded file. Use `host_vars/` to explicitly eliminate ambiguity.

---

## 4. Managing Secrets with Ansible Vault

Ansible Vault provides symmetric AES-256 encryption to protect sensitive data (passwords, API keys, private keys, SSL certificates) within playbooks and variable files.

### Core Ansible Vault Commands

| Action                       | Native Command                     | `ansible-navigator` Command        |
| :--------------------------- | :--------------------------------- | :--------------------------------- |
| **Create encrypted file**    | `ansible-vault create secret.yml`  | `ansible-vault create secret.yml`  |
| **View encrypted file**      | `ansible-vault view secret.yml`    | `ansible-vault view secret.yml`    |
| **Edit encrypted file**      | `ansible-vault edit secret.yml`    | `ansible-vault edit secret.yml`    |
| **Encrypt existing file**    | `ansible-vault encrypt secret.yml` | `ansible-vault encrypt secret.yml` |
| **Decrypt file permanently** | `ansible-vault decrypt secret.yml` | `ansible-vault decrypt secret.yml` |
| **Change vault password**    | `ansible-vault rekey secret.yml`   | `ansible-vault rekey secret.yml`   |

---

### Supplying Vault Passwords for Playbook Execution

#### Method 1: Interactive Prompt

Prompt for the vault password interactively:

```bash
ansible-navigator run playbook.yml -m stdout --vault-id @prompt
```

#### Method 2: Vault Password File

Provide a plain-text file containing the vault password (must be secured with permissions `0600`):

```bash
ansible-navigator run playbook.yml -m stdout --vault-password-file=~/vault-pass
```

#### Method 3: Default Configuration (`ansible.cfg`)

Configure the password file path inside `ansible.cfg` so no CLI flags are needed:

```ini
[defaults]
inventory = ./inventory
vault_password_file = ./vault-pass
```

> [!WARNING]
> If `vault_password_file` is already specified in `ansible.cfg`, passing `--vault-password-file` on the CLI causes a duplicate vault ID conflict error. Use either the config file or the CLI flag, not both.

---

### Terminal Artifacts and Interactive Passwords

When executing playbooks that prompt for passwords (`become_ask_pass = true` or `--vault-id @prompt`), `ansible-navigator` will hang if artifact creation is enabled.

Always disable playbook artifacts in `ansible-navigator.yml` or via the CLI flag `--pae false`:

```yaml
# ansible-navigator.yml
---
ansible-navigator:
  execution-environment:
    enabled: false
  playbook-artifact:
    enable: false
  mode: stdout
```

---

### Generating Linux Password Hashes for `ansible.builtin.user`

Linux passwords stored in `/etc/shadow` require cryptographic hashing. Plain-text strings must **never** be passed directly to the `password` parameter of `ansible.builtin.user`.

Generate a SHA-512 hashed password using OpenSSL or Python:

```bash
# Using OpenSSL (Standard SHA-512 / $6$ format):
openssl passwd -6 'RedHatPassword123!'

# Output:
# $6$8bL61N0m5kX4v7hE$wK...
```

Store the hashed string in your vault-encrypted variable file:

```yaml
# secret.yml (encrypted with ansible-vault)
username: developer1
pwhash: '$6$8bL61N0m5kX4v7hE$wK5X0G...'
```

---

## 5. Ansible Facts & Host Inspection

Ansible facts are system properties and hardware details automatically discovered from managed hosts prior to running tasks.

### The Fact Gathering Lifecycle

By default, every play begins with an implicit task: `TASK [Gathering Facts]`. This executes the `ansible.builtin.setup` module on each target host and populates the `ansible_facts` dictionary.

```
Playbook Start
   │
   ├─► TASK [Gathering Facts] (ansible.builtin.setup)
   │     ├─ Queries kernel, network interfaces, IP addresses
   │     ├─ Queries CPUs, total RAM, disks, mounted filesystems
   │     ├─ Queries OS distribution, release version, architecture
   │     └─ Reads /etc/ansible/facts.d/*.fact custom facts
   │
   └─► Downstream Tasks can reference ansible_facts['<key>']
```

#### Disabling Fact Gathering

If a play does not use facts, disable gathering to significantly improve execution speed:

```yaml
- name: Rapid package installation
  hosts: all
  gather_facts: false
  tasks:
    - name: Install vim
      ansible.builtin.dnf:
        name: vim
        state: present
```

#### Filtering Fact Subsets

Gather only specific subsets of facts to reduce payload and execution time:

```yaml
- name: Network audit
  hosts: all
  gather_subset:
    - '!all'
    - 'network'
```

---

### Modern vs. Legacy Fact Syntax

In modern Ansible, facts are nested inside the `ansible_facts` namespace. Legacy versions injected facts directly as individual variables prefixed with `ansible_`.

| Property                        | Modern Syntax (Recommended)                         | Legacy Syntax (Deprecated)                 |
| :------------------------------ | :-------------------------------------------------- | :----------------------------------------- |
| **Fully Qualified Domain Name** | `{{ ansible_facts['fqdn'] }}`                       | `{{ ansible_fqdn }}`                       |
| **Host Short Name**             | `{{ ansible_facts['hostname'] }}`                   | `{{ ansible_hostname }}`                   |
| **Default IPv4 Address**        | `{{ ansible_facts['default_ipv4']['address'] }}`    | `{{ ansible_default_ipv4.address }}`       |
| **Operating System**            | `{{ ansible_facts['distribution'] }}`               | `{{ ansible_distribution }}`               |
| **Major OS Version**            | `{{ ansible_facts['distribution_major_version'] }}` | `{{ ansible_distribution_major_version }}` |
| **CPU Architecture**            | `{{ ansible_facts['architecture'] }}`               | `{{ ansible_architecture }}`               |
| **Total Memory (MiB)**          | `{{ ansible_facts['memtotal_mb'] }}`                | `{{ ansible_memtotal_mb }}`                |
| **BIOS Date**                   | `{{ ansible_facts['bios_date'] }}`                  | `{{ ansible_bios_date }}`                  |

---

### Custom Local Facts (`/etc/ansible/facts.d/`)

Administrators can supply custom static facts or dynamic fact-generating scripts on managed nodes by placing files in `/etc/ansible/facts.d/` with the `.fact` extension.

#### 1. INI Format (`/etc/ansible/facts.d/custom.fact`)

```ini
[general]
package = httpd
service = httpd
state = started
enabled = true
```

#### 2. JSON Format (`/etc/ansible/facts.d/environment.fact`)

```json
{
  "datacenter": {
    "location": "Bucharest",
    "tier": 3
  }
}
```

#### 3. Executable Script Fact

Any executable file (`chmod +x script.fact`) that prints valid JSON to standard output will have its JSON parsed dynamically during fact gathering.

#### Accessing Custom Facts

Custom facts are exposed under `ansible_facts['ansible_local']['<filename_without_extension>']`:

```yaml
- name: Set custom variable from local fact
  ansible.builtin.set_fact:
    web_config: "{{ ansible_facts['ansible_local']['custom']['general'] }}"

- name: Install package using custom fact
  ansible.builtin.dnf:
    name: "{{ web_config['package'] }}"
    state: present
```

---

### Dynamic Fact Creation with `ansible.builtin.set_fact`

The `ansible.builtin.set_fact` module allows plays to define or transform variables dynamically on a per-host basis during execution:

```yaml
- name: Determine environment classification
  ansible.builtin.set_fact:
    env_tier: "{{ 'production' if ansible_facts['hostname'].startswith('prod') else 'staging' }}"
```

---

### Magic Variables Reference

Magic variables are automatically populated by Ansible and are not discovered by the `setup` module:

| Magic Variable           | Description                                                            | Example Usage                                                                           |
| :----------------------- | :--------------------------------------------------------------------- | :-------------------------------------------------------------------------------------- |
| **`hostvars`**           | Dictionary containing all variables and facts for all known hosts.     | `{{ hostvars['servera.lab.example.com']['ansible_facts']['default_ipv4']['address'] }}` |
| **`inventory_hostname`** | The inventory name of the currently targeted host.                     | `{{ inventory_hostname }}`                                                              |
| **`groups`**             | Dictionary mapping all inventory group names to lists of member hosts. | `{{ groups['webserver'] }}`                                                             |
| **`group_names`**        | List of groups to which the currently targeted host belongs.           | `{% if 'database' in group_names %}...{% endif %}`                                      |

---

## 6. Hands-on Exercises & Complete Solutions

### Exercise 1: Managing Variables (`data-variables`)

**Objective:** Install and configure Apache HTTP Server and Firewall dynamically using variables, and verify connectivity from the control node.

#### Playbook: `playbook.yml`

```yaml
---
- name: Deploy and start Apache HTTPD service
  hosts: webserver
  vars:
    web_pkg: httpd
    firewall_pkg: firewalld
    web_service: httpd
    firewall_service: firewalld
    rule: http

  tasks:
    - name: Required packages are installed and up to date
      ansible.builtin.dnf:
        name:
          - '{{ web_pkg }}'
          - '{{ firewall_pkg }}'
        state: present
        cacheonly: true

    - name: The {{ firewall_service }} service is started and enabled
      ansible.builtin.service:
        name: '{{ firewall_service }}'
        enabled: true
        state: started

    - name: The {{ web_service }} service is started and enabled
      ansible.builtin.service:
        name: '{{ web_service }}'
        enabled: true
        state: started

    - name: Web content is in place
      ansible.builtin.copy:
        content: "Example web content\n"
        dest: /var/www/html/index.html

    - name: The firewall port for {{ rule }} is open
      ansible.posix.firewalld:
        service: '{{ rule }}'
        permanent: true
        immediate: true
        state: enabled

- name: Verify the Apache service
  hosts: workstation
  become: false
  tasks:
    - name: Ensure the webserver is reachable
      ansible.builtin.uri:
        url: http://servera.lab.example.com
        status_code: 200
```

---

### Exercise 2: Managing Secrets (`data-secret`)

**Objective:** Create user accounts across target hosts using credentials stored in an encrypted Ansible Vault file.

#### 1. Generate Vault File

```bash
# Hash password:
openssl passwd -6 'redhat'

# Create and encrypt secret.yml:
ansible-vault create secret.yml --vault-password-file=vault-pass
```

#### Vault Content: `secret.yml`

```yaml
username: ansibleuser1
pwhash: '$6$rounds=656000$8L7zG9k.PqU8vJ6T$O7fE2...'
```

#### Playbook: `create_users.yml`

```yaml
---
- name: Create user accounts for all our servers
  hosts: devservers
  become: true
  remote_user: devops
  vars_files:
    - secret.yml
  tasks:
    - name: Creating user from secret.yml
      ansible.builtin.user:
        name: '{{ username }}'
        password: '{{ pwhash }}'
```

---

### Exercise 3: Managing Facts (`data-facts`)

**Objective:** Inspect discovered system facts, install custom fact files on managed nodes, and consume custom facts using `set_fact`.

#### Custom Fact File: `/etc/ansible/facts.d/custom.fact`

```ini
[general]
package = httpd
service = httpd
state = started
enabled = true
```

#### Playbook: `playbook.yml`

```yaml
---
- name: Install Apache and start the service
  hosts: webserver
  tasks:
    - name: Set custom variable
      ansible.builtin.set_fact:
        custom: "{{ ansible_facts['ansible_local']['custom']['general'] }}"

    - name: Install the required package
      ansible.builtin.dnf:
        name: "{{ custom['package'] }}"
        state: latest

    - name: Start the service
      ansible.builtin.service:
        name: "{{ custom['service'] }}"
        state: "{{ custom['state'] }}"
        enabled: "{{ custom['enabled'] }}"
```

---

### Comprehensive Lab: Managing Variables and Facts (`data-review`)

**Objective:** Build an end-to-end automated deployment of Apache HTTP Server with Basic Authentication and SSL enabled on `serverb.lab.example.com`. Use Ansible facts to customize index content, protect credentials using Ansible Vault, and verify service behavior with `ansible.builtin.uri`.

#### 1. Project Files Structure

```
data-review/
├── ansible.cfg
├── inventory
├── vault-pass
├── playbook.yml
├── vars/
│   └── secret.yml       # Encrypted with ansible-vault
└── files/
    ├── httpd.conf       # Apache configuration with AllowOverride AuthConfig
    ├── .htaccess        # Restricts access to valid users
    └── htpasswd         # Generated password file
```

#### 2. Encrypted Vault File: `vars/secret.yml`

```yaml
web_user: guest
web_pass: relbook
```

#### 3. Complete Solution Playbook: `playbook.yml`

```yaml
---
- name: Install and configure web server hosts with Apache and Basic Auth
  hosts: webserver
  become: true
  vars_files:
    - vars/secret.yml
  vars:
    web_packages:
      - httpd
      - mod_ssl
      - firewalld
    web_services:
      - httpd
      - firewalld
    firewall_rules:
      - http
      - https
    secrets_dir: /etc/httpd/secrets
    secrets_file: /etc/httpd/secrets/htpasswd

  tasks:
    - name: Install required packages
      ansible.builtin.dnf:
        name: '{{ web_packages }}'
        state: latest

    - name: Copy Apache main configuration
      ansible.builtin.copy:
        src: files/httpd.conf
        dest: /etc/httpd/conf/httpd.conf
        owner: root
        group: root
        mode: '0644'

    - name: Create secrets directory
      ansible.builtin.file:
        path: '{{ secrets_dir }}'
        state: directory
        owner: apache
        group: apache
        mode: '0500'

    - name: Copy htpasswd file to secrets directory
      ansible.builtin.copy:
        src: files/htpasswd
        dest: '{{ secrets_file }}'
        owner: apache
        group: apache
        mode: '0400'

    - name: Deploy .htaccess to web root
      ansible.builtin.copy:
        src: files/.htaccess
        dest: /var/www/html/.htaccess
        owner: apache
        group: apache
        mode: '0444'

    - name: Deploy customized index.html using facts
      ansible.builtin.copy:
        content: "{{ ansible_facts['fqdn'] }} ({{ ansible_facts['default_ipv4']['address'] }}) has been customized by Ansible.\n"
        dest: /var/www/html/index.html
        owner: apache
        group: apache
        mode: '0644'

    - name: Open firewall rules
      ansible.posix.firewalld:
        service: '{{ item }}'
        permanent: true
        immediate: true
        state: enabled
      loop: '{{ firewall_rules }}'

    - name: Start and enable services
      ansible.builtin.service:
        name: '{{ item }}'
        state: started
        enabled: true
      loop: '{{ web_services }}'

- name: Verify Web Service from Workstation
  hosts: workstation
  become: false
  vars_files:
    - vars/secret.yml
  tasks:
    - name: Verify 401 Unauthorized without credentials
      ansible.builtin.uri:
        url: http://serverb.lab.example.com
        status_code: 401

    - name: Verify 200 OK with valid credentials
      ansible.builtin.uri:
        url: http://serverb.lab.example.com
        url_username: '{{ web_user }}'
        url_password: '{{ web_pass }}'
        status_code: 200
        return_content: true
```
