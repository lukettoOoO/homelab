# Advanced Windows Administration

A comprehensive technical guide and reference manual covering Windows Server enterprise infrastructure: Roles, Role Services, and Features architecture; Domain Controllers and Active Directory Domain Services (AD DS); Domain Name System (DNS) architecture and record administration; organizational units, groups, and user management; client workstation domain joining; specialized AD management consoles; Group Policy Management (GPMC); and Internet Information Services (IIS) web hosting.

---

## Table of Contents

1. [Roles, Role Services, and Features Architecture](#1-roles-role-services-and-features-architecture)
2. [Domain Controller vs. Active Directory](#2-domain-controller-vs-active-directory)
3. [Domain Name System (DNS) Architecture & Resolution](#3-domain-name-system-dns-architecture--resolution)
4. [Prerequisites & Lab Environment Configuration](#4-prerequisites--lab-environment-configuration)
5. [Installing AD DS, DNS & Promoting a Domain Controller](#5-installing-ad-ds-dns--promoting-a-domain-controller)
6. [Post-Installation Verification & Health Checks](#6-post-installation-verification--health-checks)
7. [Active Directory Architecture & Core Components](#7-active-directory-architecture--core-components)
8. [User, Group, & Organizational Unit (OU) Management](#8-user-group--organizational-unit-ou-management)
9. [Joining Windows Clients to the Domain (Windows 7 & 10)](#9-joining-windows-clients-to-the-domain-windows-7--10)
10. [Specialized Active Directory Management Consoles](#10-specialized-active-directory-management-consoles)
11. [Group Policy Management (GPMC vs. Local GPO)](#11-group-policy-management-gpmc-vs-local-gpo)
12. [DNS Administration & Resource Records](#12-dns-administration--resource-records)
13. [Internet Information Services (IIS) Web Server](#13-internet-information-services-iis-web-server)
14. [Quick Reference & MMC Shortcuts](#14-quick-reference--mmc-shortcuts)

---

## 1. Roles, Role Services, and Features Architecture

In Windows Server, functionality is modularized into three architectural tiers: **Roles**, **Role Services**, and **Features**.

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Server Role (Primary identity / enterprise purpose)                     │
│   │  Example: Web Server (IIS), Active Directory Domain Services        │
│   │                                                                     │
│   ├── Role Service (Specific functionality component of a role)         │
│   │     Example: World Wide Web Publishing, Directory Services          │
│   │                                                                     │
│   └── Dependent Features (Supporting utilities & protocol stacks)       │
│         Example: .NET Framework, RSAT Administration Tools              │
└─────────────────────────────────────────────────────────────────────────┘
```

### Definitions & Dependencies

| Tier             | Definition                                                                                                                                      | Dependency Rules                                                                                            | Examples                                                                             |
| :--------------- | :---------------------------------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------- |
| **Server Role**  | A comprehensive collection of software programs that enables a server to perform a designated enterprise function for multiple network clients. | Can be installed independently or may require specific supporting features and role services.               | Active Directory Domain Services (AD DS), DNS Server, DHCP Server, Web Server (IIS). |
| **Role Service** | Individual software programs that provide granular sub-functions of a role.                                                                     | Directly tied to a parent role; **cannot** be installed without the parent role.                            | Web Management Tools, Static Content, HTTP Redirection.                              |
| **Feature**      | Auxiliary software programs that support or augment roles or improve operating system capabilities independently.                               | Can be installed **independently** of server roles. Roles often require specific features as prerequisites. | Group Policy Management, Remote Server Administration Tools (RSAT), BitLocker.       |

### Conceptual Analogy: The Simpsons Household

To simplify the dependency relationship:

- **The Role (Primary Function)**: Homer and Marge as household leaders / providers.
- **Role Services (Specific Duties)**:
  - Dropping children off at school.
  - Mowing the lawn.
  - Cooking meals.
  - Nurturing the children.
- **Features (Enabling Tools & Resources)**:
  - _Car_: Required to drive children to school (Role Service), but can also be used independently for groceries or holidays (Feature independence).
  - _Lawnmower_: Required to cut the lawn, but can also be used to prune bushes or help neighbors.
  - _Pots, pans, and spices_: Required to prepare dinner, but exist as independent tools in the kitchen.

> [!NOTE]
> **Core Rule**: A Role Service requires supporting Features to function, but a Feature does **not** require a Role Service to exist. Features remain modular and multipurpose.

---

## 2. Domain Controller vs. Active Directory

A frequent misconception in Windows systems engineering is conflating a Domain Controller with Active Directory.

```
                  ┌────────────────────────────────────────┐
                  │    Domain Controller (Physical / VM)   │
                  │  Hosts the operating system & services │
                  └───────────────────┬────────────────────┘
                                      │
          ┌───────────────────────────┼───────────────────────────┐
          ▼                           ▼                           ▼
┌───────────────────┐       ┌───────────────────┐       ┌───────────────────┐
│ Active Directory  │       │    DNS Server     │       │    DHCP / NTP     │
│  Domain Services  │       │ (Name Resolution) │       │ (IP & Time Sync)  │
│(Directory / Auth) │       └───────────────────┘       └───────────────────┘
└───────────────────┘
```

### Core Distinctions

- **Domain**: A security boundary and administrative perimeter containing network objects (computers, users, printers) managed under centralized rules and policies.
- **Domain Controller (DC)**: A physical or virtual Windows Server hosting directory service databases and handling identity authentication, group policies, replication, and network services.
- **Active Directory (AD)**: The directory service database and authentication engine running **on** the Domain Controller. Active Directory requires a Domain Controller host to run.

### The Governance Metaphor

- **Domain Controller = The Federal Government**: The overarching authority and container of enterprise resources.
- **Services = Branches of Government**:
  - _Legislative Branch_ $\approx$ Group Policy / Schema management.
  - _Executive Branch_ $\approx$ Active Directory authentication engine & user management.
  - _Judicial Branch_ $\approx$ Security auditing, event logs, access control checks.
- Under each branch reside specific agencies (Congress, Senate, Cabinet, Supreme Court), parallel to role services and worker processes running within Windows Server.

### Historical Evolution: SAM vs. Active Directory

```
Workgroup Architecture (Decentralized SAM)
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Computer 1  │     │  Computer 2  │     │ Computer 100 │
│  Local SAM   │     │  Local SAM   │ ... │  Local SAM   │
│ (User: jdoe) │     │ (User: jdoe) │     │ (User: jdoe) │
└──────────────┘     └──────────────┘     └──────────────┘
  * Password change on Computer 1 does NOT update Computer 2!

Active Directory Architecture (Centralized Directory)
                    ┌────────────────────────┐
                    │   Domain Controller    │
                    │ Active Directory (NTDS)│
                    │      (User: jdoe)      │
                    └───────────┬────────────┘
         ┌──────────────────────┼──────────────────────┐
         ▼                      ▼                      ▼
  ┌──────────────┐       ┌──────────────┐       ┌──────────────┐
  │ Client WS 1  │       │ Client WS 2  │       │ Client WS N  │
  │ Domain Join  │       │ Domain Join  │       │ Domain Join  │
  └──────────────┘       └──────────────┘       └──────────────┘
  * Single credential authentication & single password reset across all clients.
```

- **Decentralized Model (Workgroups)**: Each standalone machine stores accounts in its local Security Accounts Manager (`SAM`). In an environment with 1,000 servers, an administrator would need to create and maintain 1,000 distinct accounts. Changing a password required 1,000 manual updates.
- **Centralized Model (Active Directory)**: AD provides **Single Sign-On (SSO)**. User identity is established once in the directory. Any domain-joined client authenticates tickets against the Domain Controller via Kerberos or NTLM.

> [!IMPORTANT]
> A Windows Server cannot be designated as a Domain Controller simply by toggling a flag; it becomes a Domain Controller only after installing the **Active Directory Domain Services (AD DS)** role and executing the DC promotion process.

---

## 3. Domain Name System (DNS) Architecture & Resolution

Active Directory cannot function without DNS. DNS acts as the locator mechanism for domain controllers, kerberos authentication services, and global catalog servers via SRV records.

```
┌──────────────┐  1. "Where is mylabdc.local?"   ┌────────────────┐
│    Client    │ ──────────────────────────────> │   DNS Server   │
│ Workstation  │ <────────────────────────────── │ (Domain / NAT) │
└──────────────┘  2. "IP is 192.168.1.235"       └───────┬────────┘
       │                                                 │ 3. Forward unknown
       │ 4. HTTP / SMB / Kerberos Request                │    external lookups
       ▼                                                 ▼
┌────────────────────────────────────────┐       ┌────────────────┐
│ Domain Controller / Web Server Target  │       │  ISP / Gateway │
│           (192.168.1.235)              │       │  DNS Forwarder │
└────────────────────────────────────────┘       └────────────────┘
```

### Core Functions of DNS

1. **Forward Resolution (Hostname $\rightarrow$ IP)**: Translates human-readable names (`lab-windows.mylabdc.local`) to network layer addresses (`192.168.1.235`).
2. **Reverse Resolution (IP $\rightarrow$ Hostname)**: Resolves network IP addresses back into FQDN hostnames using Pointer (`PTR`) records.
3. **Alias Resolution (Hostname $\rightarrow$ Hostname)**: Maps alias names to canonical names via Canonical Name (`CNAME`) records.

### Resolution Hierarchy & Forwarders

- **Local Cache & Hosts File**: Checks `C:\Windows\System32\drivers\etc\hosts` and local DNS client resolver cache.
- **Authoritative DNS**: The primary DNS server holding the authoritative zone files for the domain (e.g., `mylabdc.local`).
- **DNS Forwarders**: When the local DNS server receives queries for domains outside its authoritative namespace (e.g., `google.com`), it passes the request to upstream forwarders (e.g., default gateway `192.168.1.1` or public resolvers like `8.8.8.8`).
- **Non-Authoritative Answer**: A response returned by a server that fetched the cached record from an external upstream DNS server rather than hosting the primary zone file itself.

---

## 4. Prerequisites & Lab Environment Configuration

Before promoting a server to a Domain Controller, four mandatory prerequisites must be fulfilled:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    AD DS Deployment Prerequisites                       │
├─────────────────────────────────────────────────────────────────────────┤
│ 1. Static IPv4 Configuration (DHCP prohibited on enterprise DCs)        │
│ 2. Integrated DNS Server role planned or installed alongside AD DS     │
│ 3. Fully Qualified Root Domain Name decided (e.g., mylabdc.local)       │
│ 4. Short NetBIOS Domain Name selected (e.g., LAB)                       │
└─────────────────────────────────────────────────────────────────────────┘
```

### Lab Resource Allocation (Oracle VirtualBox)

When running virtualized test labs on hardware with constrained memory (e.g., 6 GB total physical RAM):

- **Domain Controller (`lab-windows`)**: 2048 MB (2 GB) RAM.
- **Client Workstation (`Windows Client A`)**: 2048 MB (2 GB) RAM.
- **Host Operating System**: Remaining ~2 GB RAM.

> [!WARNING]
> Adjust VM RAM allocations only when the virtual machine is powered off. Overcommitting host RAM leads to memory paging, severe hypervisor disk thrashing, and OS instability.

### Configuring Static IP via GUI & Verification

```
                      Network Adapter Configuration
┌─────────────────────────────────────────────────────────────────────────┐
│ IP Address:          192.168.1.235                                      │
│ Subnet Mask:         255.255.255.0                                      │
│ Default Gateway:     192.168.1.1                                        │
│ Preferred DNS:       192.168.1.235 (Points to its own DNS instance)     │
└─────────────────────────────────────────────────────────────────────────┘
```

#### Step 1: Verify IP Availability

Open Command Prompt (`cmd.exe`) and test whether the desired static IP is free on the subnet:

```cmd
ping 192.168.1.235
```

_Expected Output_: `Destination host unreachable` indicates the IP address is currently unassigned and safe to use.

#### Step 2: Configure Network Adapter Properties

1. Open Network Connections (`Win + R` $\rightarrow$ `ncpa.cpl`).
2. Right-click the primary adapter (**Ethernet**) $\rightarrow$ **Properties**.
3. Select **Internet Protocol Version 4 (TCP/IPv4)** $\rightarrow$ **Properties**.
4. Select **Use the following IP address**:
   - **IP address**: `192.168.1.235`
   - **Subnet mask**: `255.255.255.0`
   - **Default gateway**: `192.168.1.1` (or local gateway address)
5. Select **Use the following DNS server addresses**:
   - **Preferred DNS server**: `192.168.1.235` (loopback or local static IP)
6. Click **OK** $\rightarrow$ **Close**.

---

## 5. Installing AD DS, DNS & Promoting a Domain Controller

### Phase 1: Installing the AD DS and DNS Roles

1. Open **Server Manager** (`ServerManager.exe`).
2. Click **Manage** (top right) $\rightarrow$ **Add Roles and Features**.
3. **Installation Type**: Choose **Role-based or feature-based installation** $\rightarrow$ Next.
4. **Server Selection**: Select the local server (`lab-windows`) $\rightarrow$ Next.
5. **Server Roles**:
   - Check **Active Directory Domain Services**.
   - A dialog prompts to install required dependencies (including Remote Server Administration Tools - RSAT); click **Add Features**.
   - Check **DNS Server** $\rightarrow$ click **Add Features** on confirmation popup.
6. **Features**: Keep default selections (Group Policy Management is checked automatically) $\rightarrow$ Next.
7. Click through the information screens for AD DS and DNS Server $\rightarrow$ Next.
8. **Confirmation**: Review selections, check _Restart the destination server automatically if required_, and click **Install**.

---

### Phase 2: Promoting the Server to a Domain Controller

Once role binaries are staged, the server must be promoted.

```
                      Promotion Configuration Flow
┌────────────────────────┐
│ Deployment Operation   │ ──> Select "Add a new forest"
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ Root Domain Name       │ ──> Enter "mylabdc.local"
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ Domain Capabilities    │ ──> Verify DNS & Global Catalog (GC) are checked;
└───────────┬────────────┘     Set Directory Services Restore Mode (DSRM) password
            ▼
┌────────────────────────┐
│ NetBIOS Name           │ ──> Set to "LAB" (Short domain identifier)
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ Database Paths         │ ──> NTDS database, logs, and SYSVOL folder paths
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ Prerequisites Check    │ ──> "All prerequisite checks passed successfully"
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ Final Installation     │ ──> Install, automated reboot, login as LAB\Administrator
└────────────────────────┘
```

1. In Server Manager, click the **Notification Flag** (yellow exclamation triangle) at the top menu bar.
2. Click **Promote this server to a domain controller**.
3. **Deployment Configuration**:
   - Select **Add a new forest**.
   - Specify **Root domain name**: `mylabdc.local`.
4. **Domain Controller Options**:
   - Forest and Domain Functional Level: Windows Server default.
   - Ensure **Domain Name System (DNS) server** and **Global Catalog (GC)** are checked.
   - Enter a strong password for **Directory Services Restore Mode (DSRM)**.
5. **DNS Options**:
   - A warning regarding DNS delegation will display: _"A delegation for this DNS server cannot be created because the authoritative parent zone cannot be found."_ This is normal and expected when creating a new forest root domain; proceed by clicking **Next**.
6. **Additional Options**:
   - NetBIOS domain name: Automatically calculates `MYLABDC` or customize to `LAB` for cleaner logon strings (e.g., `LAB\username`).
7. **Paths**:
   - Accept default storage locations:
     - Database folder: `C:\Windows\NTDS`
     - Log files folder: `C:\Windows\NTDS`
     - SYSVOL folder: `C:\Windows\SYSVOL`
8. **Review Options & Prerequisites**:
   - Verify all selections.
   - The installer validates system health: _"All prerequisite checks passed successfully."_
9. Click **Install**. The server automatically restarts upon completion.

---

## 6. Post-Installation Verification & Health Checks

Once rebooted, log on as the domain administrator:

- **Logon Prompt**: Press `Ctrl + Alt + Delete` (or VirtualBox `Host + Del`).
- **Credentials**: `LAB\Administrator` with the administrative password assigned during staging.

### Verification Checklist

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      Post-Promotion Verification                        │
├─────────────────────────────────────────────────────────────────────────┤
│ [x] Active Directory Users and Computers (dsa.msc) shows DC container   │
│ [x] System properties reflect Domain: mylabdc.local                     │
│ [x] DNS Manager (dnsmgmt.msc) shows forward zone and host A record      │
│ [x] nslookup resolves local hostname to 192.168.1.235                   │
│ [x] External DNS forwarding functions via nslookup www.google.com       │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 1. Verify Active Directory Console

1. Navigate to: `Start` $\rightarrow$ `Administrative Tools` $\rightarrow$ **Active Directory Users and Computers** (`dsa.msc`).
2. Expand the domain root: `mylabdc.local`.
3. Select the **Domain Controllers** Organizational Unit.
4. Verify `lab-windows` is listed with the role **Domain Controller**.

#### 2. Verify DNS Records

1. Open `DNS Manager` (`dnsmgmt.msc`).
2. Expand `lab-windows` $\rightarrow$ **Forward Lookup Zones** $\rightarrow$ `mylabdc.local`.
3. Confirm that a Host (`A`) record exists for `lab-windows` pointing to `192.168.1.235`.

#### 3. Command-Line DNS Diagnostics

Run diagnostic lookups in Command Prompt:

```cmd
:: Test local hostname resolution
nslookup lab-windows

:: Test external forwarder resolution
nslookup www.google.com
```

_Expected Local Output_:

```text
Server:  lab-windows.mylabdc.local
Address:  192.168.1.235

Name:    lab-windows.mylabdc.local
Address:  192.168.1.235
```

---

## 7. Active Directory Architecture & Core Components

Active Directory Domain Services utilizes a hierarchical framework divided into logical structures and physical components:

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Logical Structure                                                       │
│   └── Forest (Security boundary; shared schema & Global Catalog)        │
│         └── Domain Tree (Contiguous DNS namespace)                      │
│               └── Domain (Administrative boundary: mylabdc.local)       │
│                     └── Organizational Units (OUs)                      │
│                           ├── Sub-OUs                                   │
│                           └── Objects (Users, Groups, Computers)        │
│                                 └── Attributes (First Name, SID, Mail)  │
├─────────────────────────────────────────────────────────────────────────┤
│ Physical Structure                                                      │
│   ├── Domain Controllers (Servers executing AD DS & NTDS database)      │
│   ├── Active Directory Sites (Physical IP subnets / locations)          │
│   └── Database Engine: C:\Windows\NTDS\ntds.dit                         │
│   └── SYSVOL Share: C:\Windows\SYSVOL (Replicated policy scripts)       │
│   └── Directory Protocol: Lightweight Directory Access Protocol (LDAP)  │
└─────────────────────────────────────────────────────────────────────────┘
```

### Key Components Defined

| Component                    | Architecture Level | Description                                                                                                                                                                                                                           |
| :--------------------------- | :----------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Forest**                   | Logical            | The topmost container and security boundary in Active Directory. All domains within a forest share a common **Schema** (class/attribute definitions), a common **Global Catalog**, and reciprocal two-way transitive Kerberos trusts. |
| **Domain**                   | Logical            | A management and security perimeter within a forest that shares a single security database and security policies.                                                                                                                     |
| **Organizational Unit (OU)** | Logical            | A subdivision container within a domain used to organize accounts and resources. OUs are the smallest scope to which **Group Policy Objects (GPOs)** can be linked.                                                                   |
| **Object**                   | Logical            | A distinct named entity within Active Directory representing a network resource (e.g., User, Group, Computer, Shared Folder, Printer).                                                                                                |
| **Attribute**                | Logical            | Key-value pairs that define an object's characteristics (e.g., `givenName`, `mail`, `telephoneNumber`, `sAMAccountName`, `userPrincipalName`).                                                                                        |
| **LDAP**                     | Protocol           | **Lightweight Directory Access Protocol** (Port 389 / 636 LDAPS). The standard vendor-neutral protocol used to query, read, and write directory objects.                                                                              |
| **SYSVOL**                   | Physical           | A special replicated folder present on all domain controllers containing domain-wide public files, logon scripts, and Group Policy template definitions.                                                                              |
| **NTDS.DIT**                 | Physical           | The primary database file (`C:\Windows\NTDS\ntds.dit`) based on the Extensible Storage Engine (ESE / JET Blue) that stores all directory objects and schema definitions.                                                              |

---

## 8. User, Group, & Organizational Unit (OU) Management

System administrators organize directory objects logically to reflect organizational hierarchy, geographical locations, or functional departments.

### Structural Design: Departmental & Character Lab Hierarchy

```
mylabdc.local
├── IT (OU)
│   ├── systems (Sub-OU)
│   │   ├── Groups: Linux, Windows
│   │   └── Users: James Paul (jpaul), Sean Peters (speters)
│   └── network (Sub-OU)
└── Seinfeld (OU)
    └── main cast (Sub-OU)
        └── parents (Sub-OU)
            ├── Groups: Jerry parents, George parents
            └── Users: Morty Seinfeld (morty), Frank Costanza (fcostanza)
```

---

### Step-by-Step Implementation in ADUC (`dsa.msc`)

#### Step 1: Create Main OUs and Sub-OUs

1. Open **Active Directory Users and Computers** (`dsa.msc`).
2. Right-click the domain `mylabdc.local` $\rightarrow$ **New** $\rightarrow$ **Organizational Unit**.
   - **Name**: `IT`
   - _Accidental Deletion_: Uncheck _Protect container from accidental deletion_ for disposable lab environments (keep enabled in enterprise production). Click **OK**.
3. Right-click the newly created `IT` OU $\rightarrow$ **New** $\rightarrow$ **Organizational Unit**:
   - Create `systems`.
4. Repeat to create `network` inside `IT`.
5. Repeat at domain root to create `Seinfeld` $\rightarrow$ sub-OU `main cast` $\rightarrow$ sub-OU `parents`.

---

#### Step 2: Create Security Groups

Active Directory groups group user accounts to simplify assigning file permissions and policies.

```
                      Group Scope Hierarchy
┌────────────────────────┐
│ Domain Local           │ ──> Intended for resource access permissions on local domain
└────────────────────────┘
┌────────────────────────┐
│ Global                 │ ──> Gathers users of common function across the domain
└────────────────────────┘
┌────────────────────────┐
│ Universal              │ ──> Spans multiple domains across an entire forest
└────────────────────────┘
```

1. Right-click the `systems` OU $\rightarrow$ **New** $\rightarrow$ **Group**.
2. Configure group properties:
   - **Group Name**: `Linux`
   - **Group Scope**: **Global** (default)
   - **Group Type**: **Security** (used to assign permissions; _Distribution_ is for email lists only)
   - Click **OK**.
3. Repeat to create the `Windows` group inside `systems`.
4. Navigate to `Seinfeld\main cast\parents` and create groups:
   - `Jerry parents`
   - `George parents`

---

#### Step 3: Create User Accounts & Configure Attributes

1. Right-click `systems` OU $\rightarrow$ **New** $\rightarrow$ **User**.
2. Fill out identification fields:
   - **First Name**: `James`
   - **Last Name**: `Paul`
   - **User logon name**: `jpaul` (Logon format: `jpaul@mylabdc.local` or `LAB\jpaul`)
   - Click **Next**.
3. Set password parameters:
   - Enter a secure password.
   - Uncheck _User must change password at next logon_.
   - Check **Password never expires** (for lab convenience).
   - Click **Next** $\rightarrow$ **Finish**.
4. Create user `Sean Peters` (`speters`) inside `systems`.
5. Create `Morty Seinfeld` (`morty`) and `Frank Costanza` (`fcostanza`) inside `Seinfeld\main cast\parents`.

---

#### Step 4: Add Users to Groups

1. Right-click group **`Windows`** in `systems` $\rightarrow$ **Properties**.
2. Switch to the **Members** tab $\rightarrow$ click **Add...**.
3. Type `jpaul` $\rightarrow$ click **Check Names** (resolves to `James Paul`) $\rightarrow$ **OK** $\rightarrow$ **Apply**.
4. Right-click group **`Linux`** $\rightarrow$ **Properties** $\rightarrow$ **Members** $\rightarrow$ **Add...** $\rightarrow$ add `speters`.
5. In `parents`, add `morty` to `Jerry parents` and `fcostanza` to `George parents`.
6. **Verify**: Open `James Paul` properties $\rightarrow$ **Member Of** tab. Confirm memberships in both `Domain Users` (primary built-in group) and `Windows`.

---

## 9. Joining Windows Clients to the Domain (Windows 7 & 10)

Joining a client machine to an Active Directory domain transfers local authentication control to the Domain Controller and applies domain policies.

```
                      Client Domain Join Workflow
┌────────────────────────┐
│ 1. IP / DNS Check      │ ──> Set client IPv4 DNS strictly to DC IP (192.168.1.235)
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ 2. Name Resolution     │ ──> ping mylabdc.local (must return 192.168.1.235)
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ 3. Domain Join Wizard  │ ──> System Properties -> Change -> Domain: mylabdc.local
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ 4. Authentication      │ ──> Provide domain admin credentials (LAB\Administrator)
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ 5. Welcome & Reboot    │ ──> "Welcome to mylabdc.local domain" -> Restart OS
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ 6. First Domain Logon  │ ──> Login as LAB\jpaul -> Windows creates C:\Users\jpaul
└────────────────────────┘
```

### Joining a Windows 10 Virtual Machine

#### Step 1: Configure Client DNS Settings

1. On the Windows 10 workstation, open Network Connections (`ncpa.cpl`).
2. Right-click the network adapter $\rightarrow$ **Properties** $\rightarrow$ **IPv4 Properties**.
3. Set **Preferred DNS server** to the Domain Controller's static IP: `192.168.1.235`.
4. Click **OK** $\rightarrow$ **Close**.

#### Step 2: Validate Connectivity and SRV Locator

Open Command Prompt on the client:

```cmd
:: Ping domain controller IP
ping 192.168.1.235

:: Verify DNS resolution of the domain FQDN
ping mylabdc.local

:: Query DC SRV record
nslookup mylabdc.local
```

> [!CAUTION]
> If `ping mylabdc.local` fails or times out, the client cannot locate the Active Directory Domain Controller. Do **not** attempt to join the domain until name resolution succeeds.

#### Step 3: Execute Domain Join

1. Press `Win + Pause/Break` or open `Run` $\rightarrow$ `sysdm.cpl` (System Properties).
2. Under the **Computer Name** tab, click **Change...**.
3. Under **Member of**, select **Domain** and enter: `mylabdc.local`.
4. Click **OK**.
5. When prompted for credentials, supply domain administrative authorization:
   - **Username**: `Administrator` (or `LAB\Administrator`)
   - **Password**: `<Admin Password>`
6. A dialog appears: _"Welcome to the mylabdc.local domain."_
7. Click **OK** $\rightarrow$ **Close** $\rightarrow$ **Restart Now**.

---

### Logging On with a Domain User Account

1. At the Windows 10 lock screen, press `Ctrl + Alt + Delete`.
2. Click **Other user**.
3. Verify the screen reads: `Sign in to: LAB`.
4. Enter credentials:
   - **Username**: `jpaul` (or `LAB\jpaul`)
   - **Password**: Assigned user password.
5. Windows contacts the Domain Controller, validates Kerberos credentials, downloads policies, and initializes a fresh local user profile directory at `C:\Users\jpaul`.
6. Open Command Prompt and execute `whoami` to verify:
   ```cmd
   whoami
   :: Output: lab\jpaul
   ```

> [!TIP]
> **Host Cleanup Note**: If you temporarily modified your physical host adapter's DNS to point to the virtual Domain Controller, remember to revert it to **Obtain DNS server address automatically** (DHCP) when testing concludes, otherwise normal internet browsing will fail when the VM is powered down.

---

## 10. Specialized Active Directory Management Consoles

When the Active Directory role is installed, Windows Server registers four dedicated administrative consoles under Administrative Tools:

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Active Directory Administrative Tools Suite                             │
├────────────────────────────────┬────────────────────────────────────────┤
│ Console                        │ Primary Administrative Function        │
├────────────────────────────────┼────────────────────────────────────────┤
│ AD Users & Computers           │ Core day-to-day object administration  │
│ (dsa.msc)                      │ (users, groups, OUs, computer resets)  │
├────────────────────────────────┼────────────────────────────────────────┤
│ AD Administrative Center       │ Modern PowerShell-backed GUI, Global   │
│ (dsac.exe)                     │ Search, Fine-Grained Password Policies │
├────────────────────────────────┼────────────────────────────────────────┤
│ AD Domains & Trusts            │ Forest functional levels, UPN suffixes,│
│ (domain.msc)                   │ inter-forest / external domain trusts  │
├────────────────────────────────┼────────────────────────────────────────┤
│ AD Sites & Services            │ Physical topology, replication subnets,│
│ (dssite.msc)                   │ intersite RPC / SMTP transport links   │
└────────────────────────────────┴────────────────────────────────────────┘
```

---

### 1. Active Directory Administrative Center (`dsac.exe`)

Built on top of Windows PowerShell, ADAC provides an enhanced management interface for enterprise administration:

- **Global Search**: Instantly locates users, OUs, and security groups across deep tree structures without manually browsing containers.
- **Quick Password Reset**: Reset account credentials directly from the home dashboard.
- **Fine-Grained Password Policies**: Create specific Password Settings Objects (PSOs) for sensitive groups without modifying domain-wide policies.
- **PowerShell History Viewer**: Displays the exact underlying PowerShell cmdlets generated by GUI actions, useful for script development.

---

### 2. Active Directory Domains and Trusts (`domain.msc`)

Manages logical relationships and trust boundaries between different Active Directory namespaces:

- **Trust Management**: Establishes one-way or two-way transitive or non-transitive trusts (Forest Trusts, External Trusts, Realm Trusts, Shortcut Trusts).
- **Alternative UPN Suffixes**: Adds custom email-style logon suffixes (e.g., allowing users to log on as `user@company.com` instead of `user@mylabdc.local`).
- **Functional Levels**: Manages domain and forest functional levels to unlock newer Active Directory feature sets.

---

### 3. Active Directory Sites and Services (`dssite.msc`)

Manages the physical replication network and Active Directory authentication traffic:

```
                      Intersite Transport Topology
┌─────────────────────────┐                     ┌─────────────────────────┐
│ Site: New York (HQ)     │                     │ Site: Tokyo (Branch)    │
│ Subnet: 192.168.1.0/24  │                     │ Subnet: 10.10.0.0/24    │
│ DC1 (Domain Controller) │                     │ DC2 (Domain Controller) │
└────────────┬────────────┘                     └────────────┬────────────┘
             │                                               │
             └───────────────[ IP Site Link ]────────────────┘
                      Replication Cost: 100
                      Schedule: Every 15 minutes
```

- **Sites**: Represent geographic or physical office locations linked by IP subnets.
- **Subnets**: Maps IP subnets (e.g., `192.168.1.0/24`) to specific sites, ensuring clients authenticate against their closest local DC rather than querying across high-latency WAN links.
- **Intersite Transports**:
  - **IP (RPC over IP)**: Standard synchronous replication protocol for fast, reliable LAN/WAN connections.
  - **SMTP (Asynchronous Mail)**: Legacy replication protocol used exclusively for slow, unreliable, or intermittently connected links (does not replicate domain partition data, only configuration and schema).

---

### 4. Active Directory Module for Windows PowerShell

Interacts directly with Active Directory Web Services (ADWS) running on Domain Controllers.

To inspect all available AD cmdlets:

```powershell
Get-Command -Module ActiveDirectory
```

#### Essential AD PowerShell Cmdlets

```powershell
# Query all domain users
Get-ADUser -Filter * -Properties DisplayName, EmailAddress

# Find specific user details
Get-ADUser -Identity "jpaul" -Properties MemberOf

# Create a new Organizational Unit
New-ADOrganizationalUnit -Name "DevOps" -Path "DC=mylabdc,DC=local"

# Create a new User Account
New-ADUser -Name "Alice Smith" -SamAccountName "asmith" -UserPrincipalName "asmith@mylabdc.local" -AccountPassword (ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force) -Enabled $true

# Add a user to a security group
Add-ADGroupMember -Identity "Windows" -Members "asmith"

# Unlock an Active Directory user account
Unlock-ADAccount -Identity "jpaul"
```

---

## 11. Group Policy Management (GPMC vs. Local GPO)

Group Policy allows administrators to define, deploy, and enforce system security, user desktop restrictions, software installations, and OS configurations centrally.

```
                      Group Policy Execution Models
┌──────────────────────────────────────┐  ┌──────────────────────────────────────┐
│ Local Group Policy (gpedit.msc)      │  │ Domain Group Policy (gpmc.msc)       │
├──────────────────────────────────────┤  ├──────────────────────────────────────┤
│ * Affects only the single local host │  │ * Linked to Domain, Sites, or OUs    │
│ * Configured manually machine-by-    │  │ * Created once; pushes to 1,000s of  │
│   machine (doesn't scale)            │  │   systems automatically via SYSVOL   │
│ * Overridden by domain GPOs          │  │ * Precedence: Local -> Site ->       │
│                                      │  │   Domain -> Organizational Unit      │
└──────────────────────────────────────┘  └──────────────────────────────────────┘
```

### The Scalability Problem

- **Scenario**: Enforce a policy across 1,000 servers requiring passwords to be at least 12 characters long and rotated every 60 days.
  - **Option A (Manual)**: Run `gpedit.msc` locally on all 1,000 servers individually. Labor-intensive and prone to configuration drift.
  - **Option B (Enterprise GPO)**: Define the policy once in `Default Domain Policy` within `gpmc.msc`. Active Directory pushes the change to all domain members automatically within minutes.

---

### Step-by-Step GPO Configuration

#### Step 1: Open Group Policy Management Console

1. Click `Start` $\rightarrow$ `Windows Administrative Tools` $\rightarrow$ **Group Policy Management** (`gpmc.msc`).
2. Expand: `Forest: mylabdc.local` $\rightarrow$ `Domains` $\rightarrow$ `mylabdc.local`.

#### Step 2: Edit the Default Domain Policy

1. Right-click **Default Domain Policy** $\rightarrow$ click **Edit...**.
2. This launches the **Group Policy Management Editor**.

```
Default Domain Policy
├── Computer Configuration (Applies to machines regardless of logged-in user)
│   ├── Policies
│   │   ├── Software Settings
│   │   ├── Windows Settings
│   │   │   └── Security Settings
│   │   │       └── Account Policies
│   │   │           ├── Password Policy (Complexity, length, history)
│   │   │           └── Account Lockout Policy (Lock threshold, duration)
│   │   └── Administrative Templates (Registry-based settings, updates, services)
└── User Configuration (Applies to users regardless of machine accessed)
    ├── Policies
    │   ├── Software Settings
    │   ├── Windows Settings (Folder redirection, scripts)
    │   └── Administrative Templates (Control panel, desktop, start menu)
```

#### Step 3: Modify Account Password Policies

1. Navigate to: `Computer Configuration` $\rightarrow$ `Policies` $\rightarrow$ `Windows Settings` $\rightarrow$ `Security Settings` $\rightarrow$ `Account Policies` $\rightarrow$ **Password Policy**.
2. Configure corporate security baselines:
   - **Enforce password history**: `24 passwords remembered`.
   - **Maximum password age**: `60 days`.
   - **Minimum password length**: `12 characters`.
   - **Password must meet complexity requirements**: `Enabled`.

#### Step 4: Force Policy Refresh

By default, Windows background refresh occurs every 90 minutes with a random 30-minute offset. To force an immediate update on any client or server:

```cmd
gpupdate /force
```

To audit active policies applied to the current machine and session:

```cmd
gpresult /r
```

---

## 12. DNS Administration & Resource Records

The DNS Management console (`dnsmgmt.msc`) provides full lifecycle management of DNS zones, resource records, and resolver forwarders.

```
                      DNS Zone & Record Structure
Forward Lookup Zones
└── mylabdc.local
    ├── lab-windows       [A]     192.168.1.235
    ├── WindowsClientA    [A]     192.168.1.11
    └── test-computer     [CNAME] WindowsClientA.mylabdc.local
Reverse Lookup Zones
└── 1.168.192.in-addr.arpa
    └── 235               [PTR]   lab-windows.mylabdc.local
```

### DNS Resource Record Types

| Record Type | Full Name       | Purpose                                                          | Example Syntax                                                        |
| :---------- | :-------------- | :--------------------------------------------------------------- | :-------------------------------------------------------------------- |
| **A**       | Host IPv4       | Maps an FQDN to a 32-bit IPv4 address.                           | `lab-windows.mylabdc.local. IN A 192.168.1.235`                       |
| **AAAA**    | Host IPv6       | Maps an FQDN to a 128-bit IPv6 address.                          | `server.mylabdc.local. IN AAAA 2001:db8::1`                           |
| **PTR**     | Pointer         | Maps an IP address to a hostname for reverse lookups.            | `235.1.168.192.in-addr.arpa. IN PTR lab-windows.mylabdc.local.`       |
| **CNAME**   | Canonical Name  | Creates an alias pointing to an existing canonical hostname.     | `test-computer.mylabdc.local. IN CNAME WindowsClientA.mylabdc.local.` |
| **MX**      | Mail Exchanger  | Specifies mail servers responsible for accepting incoming email. | `mylabdc.local. IN MX 10 mail.mylabdc.local.`                         |
| **SRV**     | Service Locator | Identifies servers hosting specific services (LDAP, Kerberos).   | `_ldap._tcp.dc._msdcs.mylabdc.local.`                                 |

---

### Step-by-Step DNS Management Tasks

#### 1. Creating a Static Host (`A`) Record with PTR

1. In `dnsmgmt.msc`, expand **Forward Lookup Zones** $\rightarrow$ right-click `mylabdc.local`.
2. Select **New Host (A or AAAA)...**.
3. Enter details:
   - **Name**: `WindowsClientB`
   - **IP address**: `192.168.1.245`
   - Check **Create associated pointer (PTR) record**.
4. Click **Add Host**.

#### 2. Creating an Alias (`CNAME`) Record

1. Right-click `mylabdc.local` $\rightarrow$ select **New Alias (CNAME)...**.
2. Configure alias properties:
   - **Alias name**: `test-computer`
   - **Fully qualified domain name (FQDN) for target host**: `WindowsClientA.mylabdc.local` (or click **Browse...** to select).
3. Click **OK**.

#### 3. Testing Resolution with `nslookup`

Open Command Prompt:

```cmd
:: Lookup CNAME alias record
nslookup test-computer

:: Reverse lookup IP to verify PTR
nslookup 192.168.1.235
```

---

## 13. Internet Information Services (IIS) Web Server

Internet Information Services (IIS) is Microsoft's modular, high-performance web server platform for hosting websites, RESTful APIs, and intranet applications.

```
                      IIS Request Processing Flow
┌───────────────────┐        HTTP Port 80 / 443         ┌───────────────────┐
│ Web Browser / API │ ────────────────────────────────> │ HTTP.sys (Kernel) │
└───────────────────┘                                   └─────────┬─────────┘
                                                                  │
                                   Routing to Worker Process      ▼
┌───────────────────┐         Managed Handler /         ┌───────────────────┐
│ Document Root     │ <──────────────────────────────── │ w3wp.exe (IIS App │
│ C:\web\index.html │        Static File Module         │      Pool)        │
└───────────────────┘                                   └───────────────────┘
```

### Supported Protocols

- **HTTP / HTTP/2**: Core World Wide Web hypertext transfer.
- **HTTPS**: SSL/TLS cryptographic transport layer security.
- **FTP / FTPS**: File Transfer Protocol for staging assets.
- **SMTP**: Simple Mail Transfer Protocol for relaying messages.

---

### Installing IIS via Server Manager

1. Open **Server Manager** $\rightarrow$ **Manage** $\rightarrow$ **Add Roles and Features**.
2. Proceed to **Server Roles** $\rightarrow$ check **Web Server (IIS)**.
3. On the prompt to add management tools, click **Add Features**.
4. In **Role Services**, verify essential defaults:
   - Common HTTP Features: _Static Content_, _Default Document_, _HTTP Errors_, _Directory Browsing_.
   - Management Tools: _IIS Management Console_ (`inetmgr`).
5. Complete the wizard and click **Install**.

---

### Staging a Custom Web Page

#### Step 1: Verify Default Installation

Open Internet Explorer or Edge on the server and navigate to:

```text
http://localhost
```

_Result_: The default blue Microsoft IIS welcome splash page confirms the service is operational.

#### Step 2: Create Custom Web Root

Open Command Prompt or PowerShell:

```cmd
mkdir C:\web
```

Create a custom landing page at `C:\web\index.html`:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Enterprise Internal Portal</title>
    <style>
      body {
        font-family:
          Segoe UI,
          Tahoma,
          sans-serif;
        margin: 40px;
        background: #f4f4f9;
      }
      .card {
        background: white;
        padding: 25px;
        border-radius: 8px;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
      }
      h1 {
        color: #0078d7;
      }
    </style>
  </head>
  <body>
    <div class="card">
      <h1>Welcome to mylabdc.local Internal Web Server</h1>
      <p>This web server is powered by Windows Server IIS & Active Directory Domain Services.</p>
    </div>
  </body>
</html>
```

#### Step 3: Configure IIS Manager (`inetmgr`)

1. Launch **Internet Information Services (IIS) Manager** (`Win + R` $\rightarrow$ `inetmgr`).
2. Expand the server node $\rightarrow$ expand **Sites** $\rightarrow$ click **Default Web Site**.
3. In the right-hand **Actions** pane, click **Basic Settings...**.
4. Change **Physical path** from `C:\inetpub\wwwroot` to `C:\web`.
5. Click **OK**.
6. Under the central pane, double-click **Default Document** and verify `index.html` is at the top of the priority list.
7. Refresh your web browser at `http://localhost` or `http://192.168.1.235` to view your new custom website.

---

## 14. Quick Reference & MMC Shortcuts

Use these administrative commands to access management snap-ins quickly:

| Management Tool                            | Executable / MMC Snap-in | Command Line                           |
| :----------------------------------------- | :----------------------- | :------------------------------------- |
| **Active Directory Users and Computers**   | `dsa.msc`                | `Win + R` $\rightarrow$ `dsa.msc`      |
| **Active Directory Administrative Center** | `dsac.exe`               | `Win + R` $\rightarrow$ `dsac.exe`     |
| **Active Directory Domains and Trusts**    | `domain.msc`             | `Win + R` $\rightarrow$ `domain.msc`   |
| **Active Directory Sites and Services**    | `dssite.msc`             | `Win + R` $\rightarrow$ `dssite.msc`   |
| **Group Policy Management Console**        | `gpmc.msc`               | `Win + R` $\rightarrow$ `gpmc.msc`     |
| **Local Group Policy Editor**              | `gpedit.msc`             | `Win + R` $\rightarrow$ `gpedit.msc`   |
| **DNS Management Console**                 | `dnsmgmt.msc`            | `Win + R` $\rightarrow$ `dnsmgmt.msc`  |
| **Internet Information Services (IIS)**    | `inetmgr.exe`            | `Win + R` $\rightarrow$ `inetmgr`      |
| **Network Connections Manager**            | `ncpa.cpl`               | `Win + R` $\rightarrow$ `ncpa.cpl`     |
| **System Properties (Domain Join)**        | `sysdm.cpl`              | `Win + R` $\rightarrow$ `sysdm.cpl`    |
| **Services Management Console**            | `services.msc`           | `Win + R` $\rightarrow$ `services.msc` |

### Core CLI Diagnostic Commands

```cmd
:: Network & IP Configuration
ipconfig /all
ipconfig /flushdns

:: Domain & DNS Diagnostics
nslookup mylabdc.local
nslookup lab-windows
ping -a 192.168.1.235

:: Group Policy Diagnostics
gpupdate /force
gpresult /r /v

:: Identity & Token Inspection
whoami /all
net user jpaul /domain
```
