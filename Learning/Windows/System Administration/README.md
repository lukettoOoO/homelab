# Windows System Administration

A comprehensive guide and reference manual covering core Windows Server and workstation administration fundamentals: user and group management, privilege elevation, process and service architecture, system utilities, resource monitoring, Windows event logging, system maintenance, and task automation.

---

## 1. User Account & Group Management

Operating systems require user accounts to manage authentication, assign access rights, and track system activities.

```
                      ┌────────────────────────────────────────┐
                      │          Account Architecture          │
                      └───────────────────┬────────────────────┘
                                          │
                  ┌───────────────────────┴───────────────────────┐
                  ▼                                               ▼
     ┌─────────────────────────┐                     ┌─────────────────────────┐
     │      Local Account      │                     │ Domain Account (Active  │
     │ (Stored in local SAM db)│                     │  Directory / Kerberos)  │
     └─────────────────────────┘                     └─────────────────────────┘
```

### Account Types
1. **Local Accounts**:
   * Stored locally in the **Security Accounts Manager (SAM)** database (`C:\Windows\System32\config\SAM`).
   * Valid only on the specific host machine where created.
   * Default superuser: **`Administrator`** (Windows) / **`root`** (Linux/macOS).
2. **Directory Service Accounts (Active Directory Domain Services - AD DS)**:
   * Created and stored centrally on a Domain Controller (DC).
   * Authenticates domain-joined clients across the enterprise network via Kerberos/NTLM.

---

### Security Identifier (SID)
* Every Windows user and group account is assigned an immutable, globally unique string called a **Security Identifier (SID)** (e.g., `S-1-5-21-...-1001`).
* Windows evaluates file, registry, and service permissions against the **SID**, not the human-readable username.
* **Important**: If you delete a user account and re-create another user with the exact same username, it receives a **brand-new SID**. The new account will **not** inherit previous file permissions, group memberships, or ownership rights.

---

### Managing Local Accounts via Computer Management (`compmgmt.msc`)
* **Navigation Path**: `Server Manager` $\rightarrow$ `Tools` $\rightarrow$ `Computer Management` $\rightarrow$ `Local Users and Groups` $\rightarrow$ `Users` (or run `lusrmgr.msc`).
* **Creating a New User**: Right-click `Users` $\rightarrow$ `New User...`:
  * **User Name**: Logon identifier (e.g., `iafzal`).
  * **Full Name / Description**: Display name shown on login screens and administrative notes.
  * **Password Settings**:
    * **User must change password at next logon**: Forces credential rotation on first login (standard corporate practice).
    * **User cannot change password**: Used for shared accounts, service accounts, or kiosk environments.
    * **Password never expires**: Bypasses local password aging policies (default maximum password age is typically 42–90 days).
    * **Account is disabled**: Creates the account in an inactive state.

---

### Deactivating vs. Deleting Accounts

| Operation | Action | Impact on User Profile & SIDs | Recommended Scenario |
| :--- | :--- | :--- | :--- |
| **Disable Account** | Check **Account is disabled** in user Properties. | Locks logon capability, but keeps the SID, user profile directory (`C:\Users\<user>`), file ownership, and registry settings intact. | **Best Practice**: Employee departure, medical leave, or pending security audits. |
| **Delete Account** | Right-click user $\rightarrow$ **Delete**. | Permanently destroys the user account and SID. Cannot be undone even if recreated. | Temporary test accounts or obsolete scratch accounts. |

* **Account Lockout**: Windows automatically locks/disables an account after a set threshold of consecutive incorrect password attempts (configured via Local Security Policy `secpol.msc`). Administrators can unlock the account by unchecking **Account is locked out** in the account properties.

---

### User Groups & Elevating Privileges
* **Default Membership**: Every new user created is automatically placed into the built-in **`Users`** group.
* **Elevating Rights**:
  * To grant full system administration: Add user to the built-in **`Administrators`** group.
  * To grant limited administrative privileges: Add user to **`Power Users`** (maintained for legacy compatibility).
* **Methods of Assignment**:
  1. *From User*: Right-click user $\rightarrow$ `Properties` $\rightarrow$ `Member Of` tab $\rightarrow$ `Add...` $\rightarrow$ type `Administrators` $\rightarrow$ `Check Names` $\rightarrow$ `OK`.
  2. *From Group*: Go to `Groups` folder $\rightarrow$ double-click target group $\rightarrow$ click `Add...` $\rightarrow$ enter username.
  * *Note*: Privilege elevation takes full effect the **next time the user logs on**, as security tokens are generated at logon.

---

### File System Security (NTFS Permissions)
To grant or restrict file and folder access:
1. Right-click target file or folder $\rightarrow$ select **Properties** $\rightarrow$ **Security** tab.
2. Click **Edit...** (or **Advanced** for granular inheritance control).
3. Click **Add...** $\rightarrow$ enter username or group $\rightarrow$ specify permissions:
   * **Full Control**: Complete modification including taking ownership and changing permissions.
   * **Modify**: Read, write, and delete contents.
   * **Read & Execute**: View file contents and run executables/scripts.
   * **Read**: View file contents and attributes.
   * **Write**: Create files and append data.

---

## 2. User Session Monitoring & Task Management

System administrators in multi-user or terminal environments must continuously monitor session states and resource consumption.

```
                      ┌────────────────────────────────────────┐
                      │          User Session States           │
                      └───────────────────┬────────────────────┘
                                          │
                  ┌───────────────────────┴───────────────────────┐
                  ▼                                               ▼
     ┌─────────────────────────┐                     ┌─────────────────────────┐
     │      Active Session     │                     │   Disconnected Session  │
     │ (User interactively at  │                     │ (RDP closed / Switched; │
     │   console or via RDP)   │                     │  background apps run)   │
     └─────────────────────────┘                     └─────────────────────────┘
```

### Inspecting Sessions in Task Manager (`taskmgr.exe`)
1. Open **Task Manager** (`Ctrl + Shift + Esc` or right-click Taskbar $\rightarrow$ `Task Manager`).
2. Switch to the **Users** tab:
   * Displays all accounts currently logged in.
   * Shows individual CPU, Memory, Disk, and Network usage per user session.
   * Expanding a user row reveals all individual processes and programs active under that specific session.

### Logoff vs. Disconnect (Switch User)
* **Sign Out / Logoff**: Closes all active applications, unloads user registry keys, terminates user processes, and frees system memory.
* **Switch User / Disconnect**: Closes the interactive display view while **leaving all user background processes, jobs, and memory working sets active** on the server.

### Managing Runaway User Processes
* When a user's program consumes excessive resources (e.g., memory leak or high CPU utilization):
  1. Open Task Manager $\rightarrow$ **Users** tab $\rightarrow$ expand user session.
  2. Locate the offending process $\rightarrow$ right-click $\rightarrow$ select **End task**.
  3. Admins can also forcibly sign out an unresponsive session by right-clicking the user and choosing **Sign out**.

---

## 3. Programs, Packages, Services, & System Architecture

Understanding the precise technical distinctions between software abstractions is vital for systems engineering and troubleshooting:

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Package (.zip / .tar / installer)                                       │
│   └── Application / Program (.exe binary)                               │
│         ├── Process (allocated PID & memory space)                      │
│         │     ├── Thread 1 (execution thread)                           │
│         │     └── Thread 2 (execution thread)                           │
│         └── Service / Daemon (background continuous operation)          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Key Definitions

| Term | Technical Definition | Examples |
| :--- | :--- | :--- |
| **Package** | A compressed archive bundling executable binaries, configuration manifests, and dependencies. | `.zip`, `.tar.gz`, `.msi` installers |
| **Program / Application** | A compiled executable software file designed to perform user or system functions. | `chrome.exe`, `notepad.exe`, `VirtualBox.exe` |
| **Process** | An executing instance of an application loaded in memory with an assigned Process ID (PID). | Task Manager `Processes` / `Details` lists |
| **Thread** | The smallest sequence of programmed instructions scheduled by the operating system kernel within a process. | Chrome worker threads, render threads |
| **Service (Daemon)** | A long-running background process that operates without interactive user interface requirements. | `W32Time` (NTP sync), `wuauserv` (Windows Update) |

---

### Software Installation & Verification
* **Installing Software**:
  * Standalone executables (`.exe`) or Windows Installer packages (`.msi`).
  * Web browsers (e.g., Internet Explorer / Edge): In locked-down Windows Server environments, security settings (IE Enhanced Security Configuration) require adding download URLs to the **Trusted Sites** zone before downloads are permitted.
* **Managing Installed Applications**:
  * Open `Control Panel` $\rightarrow$ `Programs` $\rightarrow$ `Programs and Features` (`appwiz.cpl`).
  * Lists installed software, publishers, installation dates, and version numbers.
  * Allows administrators to **Uninstall**, **Change**, or **Repair** software packages.

---

### Managing Services (`services.msc`)
* **Access**: `Server Manager` $\rightarrow$ `Tools` $\rightarrow$ `Services` (or press `Win + R` $\rightarrow$ `services.msc`).
* **Service Actions**: Right-click service $\rightarrow$ `Start`, `Stop`, `Pause`, `Resume`, or `Restart`.
* **Startup Types**:
  * **Automatic**: Starts immediately during early OS kernel boot.
  * **Automatic (Delayed Start)**: Starts shortly after boot to prioritize critical system services.
  * **Manual**: Starts only when invoked by a dependent service, application, or admin.
  * **Disabled**: Prevented from running under any circumstance.
* **Critical Windows Services**:
  * **Windows Time (`W32Time`)**: Synchronizes local clock with domain controllers or upstream NTP pool servers. Time drift causes Kerberos authentication failures.
  * **Windows Update (`wuauserv`)**: Checks, downloads, and stages operating system updates.

---

## 4. Built-in Windows System Utilities & Accessories

Windows Server and workstation editions provide essential administrative utilities:

| Utility | Binary Name | Administrative Function |
| :--- | :--- | :--- |
| **Steps Recorder** | `psr.exe` | Records screen actions, mouse clicks, and application transitions into a structured MHT document with screenshots for troubleshooting documentation and SOPs. |
| **Remote Desktop Connection**| `mstsc.exe` | Standard RDP client used to initiate secure administrative sessions to remote servers over port 3389. |
| **Windows Server Backup** | `wbadmin.msc` | Enterprise feature for local and remote bare-metal backups, system state backups, and volume recovery. |
| **Task Manager** | `taskmgr.exe` | Real-time process, performance, user session, and service management. |
| **Snipping Tool** | `snippingtool.exe` | Captures screenshots of specific windows, freeform areas, or entire displays. |
| **Notepad & WordPad** | `notepad.exe`<br>`wordpad.exe` | Plain-text editing (batch scripts, config files) and formatted document editing. |
| **Calculator** | `calc.exe` | Includes Standard, Scientific, and Programmer modes (hexadecimal, decimal, octal, binary conversions). |
| **Character Map** | `charmap.exe` | Font glyph mapping and special character Unicode inspection. |
| **Math Input Panel** | `mip.exe` | Handwritten mathematical equation recognizer and clipboard converter. |

### Installing Windows Server Backup
Windows Server Backup is not installed by default on Windows Server.
* **Installation Procedure**:
  1. Open `Server Manager` $\rightarrow$ `Manage` $\rightarrow$ `Add Roles and Features`.
  2. Step through `Installation Type` and `Server Selection`.
  3. In the **Features** list, scroll down and check **Windows Server Backup**.
  4. Click **Next** $\rightarrow$ **Install**.
  5. Once complete, launch via `Server Manager` $\rightarrow$ `Tools` $\rightarrow$ `Windows Server Backup`.

---

## 5. System Resource Monitoring & Performance Analysis

Continuous performance monitoring prevents outages and identifies resource bottlenecks before they impact production workloads.

```
                      ┌────────────────────────────────────────┐
                      │        Core Hardware Resources         │
                      └───────────────────┬────────────────────┘
                                          │
         ┌──────────────────┬─────────────┴────────────┬──────────────────┐
         ▼                  ▼                          ▼                  ▼
  ┌─────────────┐    ┌─────────────┐            ┌─────────────┐    ┌─────────────┐
  │     CPU     │    │   Memory    │            │    Disk     │    │   Network   │
  │ (Processing)│    │(RAM working)│            │(IOPS / R/W) │    │ (Throughput)│
  └─────────────┘    └─────────────┘            └─────────────┘    └─────────────┘
```

### Accessing Resource Tools in Virtual Environments
* **Task Manager**: Press `Ctrl + Shift + Esc` or right-click the taskbar $\rightarrow$ `Task Manager`.
* **VM Key Combos**: Pressing physical `Ctrl + Alt + Delete` intercepts the host machine. On virtual machines:
  * Use the hypervisor menu: `Input` $\rightarrow$ `Keyboard` $\rightarrow$ `Insert Ctrl-Alt-Delete`.
  * In VirtualBox: Press `Host Key (Right Ctrl) + Delete`.

---

### Task Manager Performance Inspection
* **Processes Tab**:
  * Click column headers (**CPU**, **Memory**, **Disk**, **Network**) to sort processes from highest to lowest consumer.
* **Performance Tab**:
  * **CPU**: Real-time utilization percentage, clock speed, socket count, virtual cores, uptime counter, and active handles/threads.
  * **Memory**: Displays in-use RAM, available RAM, committed virtual memory (paging file), and hardware reserved allocations.
  * **Ethernet**: Tracks send/receive bandwidth throughput and link speed.
* **Details Tab**:
  * Displays PID, execution status, process username, and memory working set sizes.

---

### Troubleshooting Performance Bottlenecks
1. **CPU Spikes**:
   * Identify process consuming high percentage of cycles.
   * If an unneeded process consumes excessive CPU, right-click $\rightarrow$ **End task**.
2. **Memory Exhaustion**:
   * Memory leaks occur when a process continually allocates RAM without freeing it.
   * High paging activity (disk thrashing) occurs when physical RAM is full and the OS constantly swaps data to `pagefile.sys`.
3. **Network Saturation**:
   * High inbound/outbound throughput spikes indicate heavy data transfers, automated updates, or potential network flooding.

---

## 6. Windows Event Logs & Auditing (`eventvwr.msc`)

Event logs act as the server's diagnostic medical chart, recording operating system status changes, errors, hardware events, and user logins.

### Log Categories (`Windows Logs`)
1. **Application**: Events recorded by software applications running on the system (e.g., SQL server faults, browser crashes).
2. **Security**: Security audit logs tracking authentication attempts, user creation, privilege use, and object access.
   * *Event ID 4624*: Successful account logon.
   * *Event ID 4625*: Failed account logon attempt.
3. **Setup**: Events logged during operating system staging, service pack installations, and feature updates.
4. **System**: Core operating system events generated by Windows kernel subsystems, device drivers, and system services.

---

### Event Severity Levels

| Severity Level | Icon / Indicator | Significance | Administrative Action |
| :--- | :--- | :--- | :--- |
| **Information** | Blue (i) | Normal operational activity (e.g., service started successfully). | Baseline logging; no action required. |
| **Warning** | Yellow triangle | Potential future issue (e.g., low disk space, temporary DNS timeout). | Monitor closely to prevent escalation. |
| **Error** | Red circle (X) | Significant functionality failure (e.g., service failed to initialize, driver crash). | Immediate investigation required. |
| **Critical** | Red circle with exclamation | System failure or unexpected shutdown. | Urgent root-cause analysis. |

---

### Storage Location & Retention Settings
* **Default Directory**: `C:\Windows\System32\winevt\Logs\` (stored as binary `.evtx` files).
* **Retention Policies** (`Right-click Log -> Properties`):
  * **Maximum log size (KB)**: Defines file size threshold (e.g., 20,480 KB).
  * **Overwrite events as needed (oldest events first)**: Standard FIFO buffer for continuous logging.
  * **Archive the log when full, do not overwrite events**: Preserves historic logs for strict compliance environments.
  * **Clear Log**: Empties the current event log (offers option to export before clearing).
* **Exporting Events**: Right-click target log $\rightarrow$ `Save All Events As...` $\rightarrow$ save as `.evtx` for analysis on other machines or submission to vendor support.

---

## 7. System Maintenance & Patch Management

Routine maintenance ensures host stability, security compliance, and disaster resilience.

```
                      ┌────────────────────────────────────────┐
                      │       Maintenance Lifecycle Plan       │
                      └───────────────────┬────────────────────┘
                                          │
       1. Pre-Maintenance ──────► 2. Execution Phase ──────► 3. Verification
       - Hypervisor Snapshot      - Install Updates/Patches    - Test Services
       - Backup System State      - Reboot into Safe Mode      - Re-enable RDP
       - Disable Remote RDP       - Apply Critical Hotfixes    - Remove Snapshot
```

### Command Line Reboot & Shutdown (`shutdown.exe`)

```cmd
:: Immediate system reboot
shutdown /r /t 0

:: Reboot after a 60-second delay with user notification
shutdown /r /t 60 /c "Scheduled maintenance reboot in progress"

:: Abort a pending shutdown or reboot command
shutdown /a

:: Immediate system shutdown (power off)
shutdown /s /t 0
```

---

### Safe Mode (Single-User Mode)
* **Purpose**: Starts Windows in a clean, minimal state with only essential drivers and system processes running. Non-essential third-party drivers and network users are blocked from logging in.
* **Boot Options**:
  * **Safe Mode**: Minimal GUI environment without network capabilities.
  * **Safe Mode with Networking**: Includes network interface drivers for internet/LAN access.
  * **Safe Mode with Command Prompt**: Starts directly into `cmd.exe` without the Windows Explorer desktop shell.
* **Access Methods**:
  * Tap **`F8`** repeatedly immediately after VM initialization / BIOS screen.
  * In modern Windows: Hold `Shift` while clicking **Restart** in the Start Menu $\rightarrow$ `Troubleshoot` $\rightarrow$ `Advanced Options` $\rightarrow$ `Startup Settings`.
  * Via `msconfig`: Open `msconfig` $\rightarrow$ `Boot` tab $\rightarrow$ check **Safe boot** (Minimal) $\rightarrow$ Restart.

---

### Windows Updates vs. Patch Management
* **Windows Updates**: Cumulative monthly or quarterly rollup releases from Microsoft containing security patches, bug fixes, and feature enhancements.
* **Hotfixes (Patches)**: Targeted, single-issue updates created to resolve a specific vulnerability or software bug without waiting for the next cumulative release.
* **Viewing Installed Updates**:
  * `Control Panel` $\rightarrow$ `Programs and Features` $\rightarrow$ `View installed updates`.
  * Allows administrators to verify update KB numbers (e.g., `KB5005565`) or uninstall problematic patches.
* **Disabling Remote Access During Maintenance**:
  * Right-click `This PC` $\rightarrow$ `Properties` $\rightarrow$ `Remote settings`.
  * Select **"Don't allow remote connections to this computer"** to prevent users from reconnecting while maintenance is underway.
* **Hypervisor Snapshot Best Practice**: Always take a VM snapshot (or Hyper-V Checkpoint) **before** staging major updates or applying hotfixes. If an update corrupts the OS, revert immediately to the pre-maintenance snapshot.

---

## 8. Jobs, Automation, & Task Scheduling

Automating administrative tasks minimizes human error and allows routine maintenance (backups, reporting, reboots) to execute during off-peak hours.

```
                      ┌────────────────────────────────────────┐
                      │             Task Scheduler             │
                      └───────────────────┬────────────────────┘
                                          │
                  ┌───────────────────────┴───────────────────────┐
                  ▼                                               ▼
     ┌─────────────────────────┐                     ┌─────────────────────────┐
     │        Triggers         │                     │         Actions         │
     │ - Schedule (Daily/Weekly│                     │ - Start a Program       │
     │ - At System Startup     │                     │ - Run a Batch Script    │
     │ - On User Logon / Event │                     │ - Execute PowerShell    │
     └─────────────────────────┘                     └─────────────────────────┘
```

### 1. Creating Maintenance Scripts (`.bat`)
Create a batch script to automate server reboots and log operations:

1. Open Notepad (`notepad.exe`).
2. Enter the maintenance command:
   ```bat
   @echo off
   :: Log execution timestamp
   echo Reboot executed on %DATE% at %TIME% >> C:\Scripts\reboot_log.txt
   shutdown /r /t 0
   ```
3. Save the file with a `.bat` extension (e.g., `C:\Scripts\reboot.bat`).

---

### 2. Task Scheduler Configuration (`taskschd.msc`)
* **Access**: `Server Manager` $\rightarrow$ `Tools` $\rightarrow$ `Task Scheduler` (or run `taskschd.msc`).
* **Basic Task vs. Advanced Task**:
  * **Create Basic Task**: Simplified wizard for basic single-trigger tasks.
  * **Create Task (Advanced)**: Full configuration interface supporting multiple triggers, elevated security tokens, failure conditions, and idle states.

### Step-by-Step: Scheduling a Nightly Maintenance Task
1. Open **Task Scheduler** $\rightarrow$ click **Create Task...** in the Actions pane.
2. **General Tab**:
   * **Name**: `Nightly Server Reboot`.
   * **Security Options**:
     * Select **Run whether user is logged on or not**.
     * Check **Run with highest privileges** (ensures administrative UAC token is applied).
3. **Triggers Tab**:
   * Click **New...** $\rightarrow$ select **Daily** $\rightarrow$ set Start time to `02:00:00 AM` (off-peak hours).
4. **Actions Tab**:
   * Click **New...** $\rightarrow$ Action: **Start a program**.
   * Program/script: Browse to `C:\Scripts\reboot.bat`.
5. **Conditions & Settings Tabs**:
   * Uncheck "Start the task only if the computer is on AC power" (for battery-backed physical hardware).
   * Check "If the task fails, restart every 5 minutes".
6. Click **OK** $\rightarrow$ enter the administrative password to save the credential token.

---

## 9. Quick Administration Command Reference

| Administrative Goal | Command / Tool |
| :--- | :--- |
| Open Computer Management | `compmgmt.msc` |
| Open Local Users and Groups | `lusrmgr.msc` |
| Open Services Manager | `services.msc` |
| Open Task Manager | `taskmgr.exe` / `Ctrl + Shift + Esc` |
| Open Event Viewer | `eventvwr.msc` |
| Open Task Scheduler | `taskschd.msc` |
| Open Programs and Features | `appwiz.cpl` |
| Open Steps Recorder | `psr.exe` |
| Open Remote Desktop Client | `mstsc.exe` |
| Open System Configuration (Boot settings) | `msconfig.exe` |
| Immediate Reboot via CLI | `shutdown /r /t 0` |
| Abort Pending Reboot/Shutdown | `shutdown /a` |

