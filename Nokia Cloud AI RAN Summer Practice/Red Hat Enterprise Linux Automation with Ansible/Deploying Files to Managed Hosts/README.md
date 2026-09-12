# Chapter 4: Deploying Files to Managed Hosts

> **Course:** Red Hat Enterprise Linux Automation with Ansible (RH294)  
> **Topic:** File Management Modules, File Attributes & SELinux Contexts, Line & Block Manipulation, Jinja2 Templating, Control Structures (Loops & Conditionals), and Variable Filters.

---

## 1. Overview of File Management in Ansible

File management is a foundational capability in infrastructure automation. In Red Hat Enterprise Linux, configuration files, system banners, application assets, and authorization keys must be installed, verified, updated, and secured with correct file modes, ownership, and SELinux contexts.

Ansible provides specialized modules for file manipulation within two collections:

- **`ansible.builtin`:** Core modules packaged with `ansible-core` for file creation, templating, line/block editing, status querying, and attribute enforcement.
- **`ansible.posix`:** POSIX-compliant modules designed for Linux/Unix tasks, including differential synchronization (`synchronize`) and patching (`patch`).

---

## 2. Core File Management Modules (`ansible.builtin`)

| Module Name       | Primary Function                                                                                                | Common Use Cases                                                                                        |
| :---------------- | :-------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------ |
| **`file`**        | Sets attributes (permissions, ownership, SELinux context) or manages state (file, directory, symlink, absent).  | Creating directories, creating symlinks, touching files, removing files recursively.                    |
| **`copy`**        | Transfers files from the control node (or remote) to managed hosts; can also write raw string content.          | Distributing static configuration files, deploying license keys, copying local scripts.                 |
| **`fetch`**       | Retrieves files from managed hosts to the control node, organizing them by hostname.                            | Collecting remote logs (`/var/log/secure`), retrieving public keys, backup consolidation.               |
| **`lineinfile`**  | Ensures a single line exists in an existing file, or replaces a line matched by a regex pattern.                | Toggling single settings (e.g. `SELINUX=enforcing`), adding single authorized users.                    |
| **`blockinfile`** | Injects, updates, or removes a block of multiple lines surrounded by marker comments.                           | Adding multi-line environment variables, configuring virtual host blocks.                               |
| **`stat`**        | Retrieves file/directory metadata and attributes (similar to Linux `stat` command).                             | Checking if a file exists, validating file size/permissions, verifying checksums.                       |
| **`template`**    | Processes a local Jinja2 template file, rendering dynamic variables and facts, and deploys it to managed hosts. | Deploying dynamic service configs (`sshd_config`, `httpd.conf`), generating `/etc/hosts`, dynamic MOTD. |

---

### Additional POSIX File Modules (`ansible.posix`)

| Module Name       | Primary Function                                                                                         | Common Use Cases                                                                       |
| :---------------- | :------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------- |
| **`synchronize`** | Wrapper around the Linux `rsync` utility for optimized, differential file and directory synchronization. | Synchronizing large directories, deploying web docroots, mirror syncing between nodes. |
| **`patch`**       | Applies diff/patch files using GNU `patch`.                                                              | Applying localized source code patches or configuration delta files.                   |

> [!NOTE]
> When using `ansible.posix.synchronize`, `rsync` must be installed on both the control node and the target managed host.

---

## 3. Working with File Attributes & Security Contexts

All file-modifying modules (`file`, `copy`, `template`, `lineinfile`, `blockinfile`) support standard file attribute parameters:

### Standard File Attributes

```yaml
- name: Set standard file attributes
  ansible.builtin.file:
    path: /etc/security/limits.d/custom.conf
    owner: root
    group: root
    mode: '0644'
    state: touch
```

- **`owner`:** The target username or UID owning the file.
- **`group`:** The target group name or GID owning the file.
- **`mode`:** Permissions mode in octal notation. **Always quote octal values** (e.g. `'0644'`, `'0755'`, `'0500'`) to prevent YAML from interpreting them as decimal integers.

---

### Managing SELinux Contexts

When SELinux is enforcing, files placed in non-standard locations or shared by services (such as Samba, NFS, or Apache) require specific SELinux type contexts.

| Parameter     | Equivalent Linux Command | Description                                                                           |
| :------------ | :----------------------- | :------------------------------------------------------------------------------------ |
| **`setype`**  | `chcon -t <type>`        | SELinux type attribute (e.g., `samba_share_t`, `httpd_sys_content_t`, `user_home_t`). |
| **`seuser`**  | `chcon -u <user>`        | SELinux user context (e.g., `system_u`, `unconfined_u`).                              |
| **`serole`**  | `chcon -r <role>`        | SELinux role context (e.g., `object_r`).                                              |
| **`selevel`** | `chcon -l <level>`       | SELinux MLS/MCS level (e.g., `s0`).                                                   |

#### 1. Explicit SELinux Context Assignment

```yaml
- name: Ensure directory has samba_share_t SELinux type
  ansible.builtin.file:
    path: /home/devops/shared_files
    state: directory
    owner: devops
    group: devops
    mode: '0775'
    setype: samba_share_t
```

#### 2. Reverting to System Policy Default (`setype: _default`)

To restore a file or directory's SELinux context to the default policy defined in the system's SELinux policy database (equivalent to `restorecon`):

```yaml
- name: Restore default SELinux context
  ansible.builtin.file:
    path: /home/devops/shared_files
    state: directory
    setype: _default
```

> [!TIP]
> To set persistent SELinux file contexts that survive relabeling across the entire system, the Red Hat certified approach is using the `redhat.rhel_system_roles.selinux` system role or the `community.general.sefcontext` module.

---

## 4. Modifying, Editing, and Transferring Files

### 1. Creating and Removing Files/Directories (`file`)

The `state` parameter defines the intended object type:

```yaml
# Create an empty file (or update timestamps if it exists)
- name: Touch file
  ansible.builtin.file:
    path: /var/log/custom_audit.log
    state: touch
    owner: root
    mode: '0600'

# Create a directory (and required parent directories)
- name: Create secure secrets directory
  ansible.builtin.file:
    path: /etc/app/secrets
    state: directory
    owner: appuser
    group: appuser
    mode: '0700'

# Create a symbolic link
- name: Create symlink to issue banner
  ansible.builtin.file:
    src: /etc/issue
    dest: /etc/issue.net
    state: link
    force: true # Overwrites dest if a regular file already exists

# Recursively remove a file or directory
- name: Remove temporary files
  ansible.builtin.file:
    path: /tmp/scratch_dir
    state: absent
```

---

### 2. Copying Files to Managed Hosts (`copy`)

Transfers files from the control node's workspace to the remote host:

```yaml
- name: Deploy application configuration file
  ansible.builtin.copy:
    src: files/app.conf
    dest: /etc/app/app.conf
    owner: root
    group: root
    mode: '0644'
    force: true # Default: true (overwrites file only if content has changed)
    backup: true # Creates a timestamped backup before overwriting
```

- **`force: true` (default):** Overwrites destination file if remote contents differ from source.
- **`force: false`:** Safe copy; only copies if the destination file does not exist.
- **`backup: true`:** Generates a remote backup file (e.g., `app.conf.2026-09-12@11:00~`) whenever changes occur.

---

### 3. Retrieving Files from Remote Hosts (`fetch`)

Works like `copy` in reverse. Fetches remote files and stores them on the control node:

```yaml
- name: Fetch remote security logs to control node
  ansible.builtin.fetch:
    src: /var/log/secure
    dest: secure-backups/
```

**Directory Structure Created on Control Node:**

```
secure-backups/
├── servera.lab.example.com/
│   └── var/
│       └── log/
│           └── secure
└── serverb.lab.example.com/
    └── var/
        └── log/
            └── secure
```

> [!NOTE]
> By default, `fetch` preserves the remote path hierarchy under a folder named after the target host's inventory name. To disable this and save directly as a single file, use `flat: true`.

---

### 4. Single-Line Editing (`lineinfile`)

Ensures a single line exists, is updated, or is removed:

```yaml
# Add a single line (create file if absent)
- name: Ensure devops user line exists in users.txt
  ansible.builtin.lineinfile:
    path: /home/devops/files/users.txt
    line: 'devops:x:1001:1001:DevOps User:/home/devops:/bin/bash'
    state: present
    create: true
    owner: devops
    group: devops
    mode: '0664'

# Replace an existing line using regex
- name: Ensure SELinux is set to enforcing
  ansible.builtin.lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: 'SELINUX=enforcing'
    state: present
```

---

### 5. Multi-Line Block Editing (`blockinfile`)

Inserts, updates, or removes an entire block of text. To guarantee idempotency, `blockinfile` wraps the block in comment markers:

```yaml
- name: Inject custom environment settings into /etc/profile
  ansible.builtin.blockinfile:
    path: /etc/profile
    block: |
      export JAVA_HOME=/opt/openjdk
      export PATH=$PATH:$JAVA_HOME/bin
      export APP_ENV=production
    marker: '# {mark} ANSIBLE APP ENVIRONMENT'
    insertafter: EOF
    state: present
```

**Result in `/etc/profile`:**

```bash
# BEGIN ANSIBLE APP ENVIRONMENT
export JAVA_HOME=/opt/openjdk
export PATH=$PATH:$JAVA_HOME/bin
export APP_ENV=production
# END ANSIBLE APP ENVIRONMENT
```

- When `state: absent`, the module removes the markers and all content between them.
- `{mark}` is replaced automatically by `BEGIN` and `END`.

---

### 6. Querying File Metadata (`stat`)

Retrieves facts about a file or filesystem object:

```yaml
- name: Inspect /etc/motd status
  ansible.builtin.stat:
    path: /etc/motd
    checksum_algorithm: sha256
  register: motd_stat

- name: Display status facts
  ansible.builtin.debug:
    msg: >
      Exists: {{ motd_stat.stat.exists }}
      Size: {{ motd_stat.stat.size }} bytes
      Permissions: {{ motd_stat.stat.mode }}
      SHA256: {{ motd_stat.stat.checksum }}
```

#### Key Properties in `stat.stat`:

- `exists`: Boolean indicating presence of the file.
- `isdir`: `true` if target is a directory.
- `islnk`: `true` if target is a symbolic link.
- `lnk_target`: Target path of symlink if `islnk` is true.
- `mode`: File permission mode (in octal string format).
- `checksum`: Cryptographic hash (MD5, SHA1, SHA256).

---

## 5. Deploying Custom Files with Jinja2 Templates

While `lineinfile` and `blockinfile` are useful for quick adjustments, **templating is the industry standard for deploying complete configuration files**.

With Jinja2 templates, a single template file dynamically generates tailored configuration files for each managed host using variables, facts, loops, and conditions.

### Jinja2 Delimiter Standards

| Delimiter           | Purpose                                                                               | Example                     |
| :------------------ | :------------------------------------------------------------------------------------ | :-------------------------- |
| **`{{ EXPR }}`**    | **Expressions:** Evaluated and replaced with the resulting variable/fact value.       | `Port {{ ssh_port }}`       |
| **`{% EXPR %}`**    | **Control Structures:** Logic loops (`for`), conditions (`if`), variable assignments. | `{% if env == 'prod' %}`    |
| **`{# COMMENT #}`** | **Comments:** Stripped during rendering; never appears in destination file.           | `{# Internal audit note #}` |

---

### Template Conventions & File Layout

- **Location:** Saved inside the `templates/` directory of the project.
- **Extension:** Suffixed with `.j2` (e.g. `motd.j2`, `sshd_config.j2`).
- **Header notice (`ansible_managed`):** It is best practice to include `{{ ansible_managed }}` at the top of templates to warn administrators against manual editing:
  ```jinja2
  # {{ ansible_managed }}
  # Manual edits will be overwritten by Ansible automation.
  ```

---

### Deploying Templates with `ansible.builtin.template`

```yaml
- name: Deploy customized SSH daemon configuration
  ansible.builtin.template:
    src: templates/sshd_config.j2
    dest: /etc/ssh/sshd_config
    owner: root
    group: root
    mode: '0600'
    validate: '/usr/sbin/sshd -t -f %s'
  notify: Restart sshd
```

> [!IMPORTANT]
> The **`validate`** parameter specifies an executable command to check the syntax of the rendered configuration before copying it to the final destination (with `%s` representing the temporary rendered file). If validation fails, the task aborts and the destination file remains unchanged.

---

## 6. Jinja2 Control Structures

### 1. Conditionals (`if` Statements)

Conditionals allow text blocks to be rendered only when specific criteria are met:

```jinja2
This is system {{ ansible_facts['fqdn'] }}.
OS: {{ ansible_facts['distribution'] }} {{ ansible_facts['distribution_version'] }}

{% if 'workstations' in group_names %}
As a workstation user, submit a ticket to receive help with any issues.
{% elif 'webservers' in group_names %}
Please report web service incidents to: {{ system_owner }}
{% else %}
Standard managed server.
{% endif %}
```

> [!TIP]
> In templates, check group membership using the magic variable `group_names` (list of groups the current host belongs to) or test membership against `groups['<group>']`.

---

### 2. Loops (`for` Statements)

Loops iterate over lists, dictionaries, or inventory groups:

#### Iterating Over a List of Strings

```jinja2
{% for user in authorized_users %}
AllowUser {{ user }}
{% endfor %}
```

#### Loop Filtering (`if` within `for`)

```jinja2
{% for user in system_users if user != 'root' %}
User {{ loop.index }}: {{ user }}
{% endfor %}
```

#### Loop Index Variables

| Variable      | Description                                     |
| :------------ | :---------------------------------------------- |
| `loop.index`  | 1-based current iteration index (`1, 2, 3...`). |
| `loop.index0` | 0-based current iteration index (`0, 1, 2...`). |
| `loop.first`  | `true` if current iteration is the first.       |
| `loop.last`   | `true` if current iteration is the last.        |
| `loop.length` | Total number of items in the sequence.          |

---

### 3. Dynamic `/etc/hosts` Generation with `hostvars` & Loops

A classic enterprise Ansible pattern is dynamically generating `/etc/hosts` by iterating over all inventory hosts:

#### Playbook: `update_hosts.yml`

```yaml
---
- name: Maintain /etc/hosts across all infrastructure
  hosts: all
  become: true
  tasks:
    - name: Deploy dynamic /etc/hosts file
      ansible.builtin.template:
        src: templates/hosts.j2
        dest: /etc/hosts
        owner: root
        group: root
        mode: '0644'
```

#### Template: `templates/hosts.j2`

```jinja2
127.0.0.1   localhost localhost.localdomain
::1         localhost localhost.localdomain

# The following entries are dynamically generated by Ansible:
{% for host in groups['all'] %}
{{ hostvars[host]['ansible_facts']['default_ipv4']['address'] }}    {{ hostvars[host]['ansible_facts']['fqdn'] }}    {{ hostvars[host]['ansible_facts']['hostname'] }}
{% endfor %}
```

---

## 7. Jinja2 Data Formatting Filters

Jinja2 filters transform data from one representation into another using the pipe (`|`) operator.

| Filter             | Description                                              | Example Usage     |
| :----------------- | :------------------------------------------------------- | :---------------- | -------------------------- |
| **`to_json`**      | Formats data structure as a JSON string.                 | `{{ server_config | to_json }}`                |
| **`to_nice_json`** | Formats data structure as human-readable, indented JSON. | `{{ server_config | to_nice_json(indent=2) }}` |
| **`to_yaml`**      | Formats data structure as a YAML string.                 | `{{ server_config | to_yaml }}`                |
| **`to_nice_yaml`** | Formats data structure as human-readable, indented YAML. | `{{ server_config | to_nice_yaml(indent=2) }}` |
| **`from_json`**    | Parses a JSON string into an Ansible data structure.     | `{{ json_string   | from_json }}`              |
| **`from_yaml`**    | Parses a YAML string into an Ansible data structure.     | `{{ yaml_string   | from_yaml }}`              |
| **`default`**      | Provides a fallback value if a variable is undefined.    | `{{ http_port     | default(80) }}`            |
| **`join`**         | Joins elements of a list into a delimited string.        | `{{ allowed_hosts | join(', ') }}`             |

---

## 8. Reference Architectures & Complete Playbook Examples

### Architecture 1: Comprehensive File & Directory Lifecycle Management

Demonstrates fetching remote logs, creating directories with SELinux contexts, line/block editing, copying files, and clean teardown.

```yaml
---
- name: Comprehensive File and Directory Management
  hosts: servers
  become: true
  tasks:
    - name: Fetch remote security log to control node
      ansible.builtin.fetch:
        src: /var/log/secure
        dest: secure-backups/

    - name: Ensure target directory exists with default SELinux context
      ansible.builtin.file:
        path: /home/devops/files
        state: directory
        owner: devops
        group: devops
        mode: '0775'
        setype: _default

    - name: Append single entry to file
      ansible.builtin.lineinfile:
        path: /home/devops/files/users.txt
        line: 'devops-admin: Administrative Operator'
        state: present
        create: true
        owner: devops
        group: devops
        mode: '0664'

    - name: Deploy static system file
      ansible.builtin.copy:
        src: files/system
        dest: /home/devops/files/system
        owner: devops
        group: devops
        mode: '0664'

    - name: Append managed block of text
      ansible.builtin.blockinfile:
        path: /home/devops/files/users.txt
        block: |
          # Department: Cloud AI Infrastructure
          # Policy: Security Compliance Tier 1
        marker: '# {mark} ANSIBLE POLICY BLOCK'
        state: present
```

---

### Architecture 2: Dynamic MOTD Generation with Jinja2 Templating

Demonstrates deploying customized Message of the Day banners using host facts and inventory group conditions.

#### Template: `templates/motd.j2`

```jinja2
===================================================================
 System FQDN    : {{ ansible_facts['fqdn'] }}
 Distribution   : {{ ansible_facts['distribution'] }} {{ ansible_facts['distribution_version'] }}
 Total Memory   : {{ ansible_facts['memtotal_mb'] }} MiB
 CPU Cores      : {{ ansible_facts['processor_count'] }}
===================================================================
{% if 'workstations' in group_names %}
 NOTICE: As a workstation user, submit a ticket for technical support.
{% elif 'webservers' in group_names %}
 NOTICE: Production Web Service. Please report incidents to: {{ system_owner }}
{% else %}
 NOTICE: Authorized access only. All activities are monitored.
{% endif %}
===================================================================
```

#### Playbook: `deploy_motd.yml`

```yaml
---
- name: Configure System Banners via Jinja2
  hosts: all
  become: true
  vars:
    system_owner: sysadmin@example.com
  tasks:
    - name: Deploy dynamic /etc/motd
      ansible.builtin.template:
        src: templates/motd.j2
        dest: /etc/motd
        owner: root
        group: root
        mode: '0644'
```

---

### Architecture 3: File Inspection and Pre-Login Banner Management

Demonstrates `stat` verification, variable registration, pre-login banner deployment, and symbolic links with `force: true`.

```yaml
---
- name: Manage Login Banners and Symbolic Links
  hosts: servers
  become: true
  tasks:
    - name: Deploy /etc/issue pre-login banner
      ansible.builtin.copy:
        src: files/issue
        dest: /etc/issue
        owner: root
        group: root
        mode: '0644'

    - name: Ensure /etc/issue.net is a symbolic link to /etc/issue
      ansible.builtin.file:
        src: /etc/issue
        dest: /etc/issue.net
        state: link
        force: true # Overwrites pre-existing regular /etc/issue.net file

    - name: Query file attributes of /etc/motd
      ansible.builtin.stat:
        path: /etc/motd
      register: motd_stat

    - name: Display /etc/motd metadata
      ansible.builtin.debug:
        var: motd_stat.stat
```
