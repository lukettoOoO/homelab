# Windows Scripting and Command Line

A comprehensive technical guide and reference manual covering Windows Server automation, shell environments, and scripting architectures: Windows Batch scripting (`.bat`), Windows PowerShell fundamentals and cmdlet architecture, filesystem and administrative automation, the PowerShell Integrated Scripting Environment (ISE), Windows Management Instrumentation (WMI / WMIC), and an architectural comparison between legacy DOS/CMD and PowerShell.

---

## Table of Contents

1. [Fundamentals of Automation & Scripting in Windows](#1-fundamentals-of-automation--scripting-in-windows)
2. [Windows Batch Scripting (`.bat` / `cmd.exe`)](#2-windows-batch-scripting-bat--cmdexe)
3. [Windows PowerShell Architecture & Discovery](#3-windows-powershell-architecture--discovery)
4. [PowerShell Filesystem & Administrative Cmdlets](#4-powershell-filesystem--administrative-cmdlets)
5. [Windows PowerShell Integrated Scripting Environment (ISE)](#5-windows-powershell-integrated-scripting-environment-ise)
6. [Windows Management Instrumentation (WMI & WMIC)](#6-windows-management-instrumentation-wmi--wmic)
7. [Architectural Comparison: Command Prompt (DOS) vs. PowerShell](#7-architectural-comparison-command-prompt-dos-vs-powershell)
8. [Quick Reference & Command Cheat Sheet](#8-quick-reference--command-cheat-sheet)

---

## 1. Fundamentals of Automation & Scripting in Windows

System administration in enterprise environments demands repeatability, consistency, and efficiency. Performing routine management tasks manually through the Windows Graphical User Interface (GUI) is prone to human error, time-consuming, and impossible to scale across hundreds or thousands of servers.

```
┌────────────────────────────────────────────────────────────────────────┐
│                   Windows Administration Paradigms                     │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
          ┌─────────────────────────┴─────────────────────────┐
          ▼                                                   ▼
┌─────────────────────────────────┐         ┌─────────────────────────────────┐
│     Manual GUI Administration   │         │     Script-Based Automation     │
├─────────────────────────────────┤         ├─────────────────────────────────┤
│ • Click-intensive workflows     │         │ • Deterministic & repeatable    │
│ • Prone to operator errors      │         │ • Rapid execution across fleet  │
│ • Difficult to audit or version │         │ • Version-controllable (Git)    │
│ • Requires live user session    │         │ • Scheduled via Task Scheduler  │
└─────────────────────────────────┘         └─────────────────────────────────┘
```

### The Role of Task Automation

- **Batch Operations**: Performing actions on dozens or hundreds of files, services, or user accounts simultaneously.
- **Scheduled Operations**: Hooking scripts into Windows **Task Scheduler** (`taskschd.msc`) to execute administrative routines unattended at designated hours (e.g., nightly backups, log rotation, system health checks).
- **System Standardization**: Guaranteeing that configuration baselines and deployment steps are executed identically across all domain controllers, member servers, and workstations.

---

## 2. Windows Batch Scripting (`.bat` / `cmd.exe`)

A **batch file** is an uncompiled text file containing a sequence of commands interpreted and executed line-by-line by the Windows command-line interpreter (`cmd.exe`).

```
┌─────────────────┐       Double-Click       ┌─────────────────┐      Sequential     ┌─────────────────┐
│   script.bat    │ ───────────────────────> │     cmd.exe     │ ──────────────────> │ Output/Action   │
│  (Plain Text)   │    or CLI Invocation     │  (Interpreter)  │       Execution     │ (Console / OS)  │
└─────────────────┘                          └─────────────────┘                     └─────────────────┘
```

### File Extension & OS Registration

- **Extension**: Files must be saved with the **`.bat`** (or modern **`.cmd`**) extension.
- **OS Association**: In Windows Explorer, files with `.bat` display an icon with gear wheels, indicating an executable script.
- **Execution vs. Editing**:
  - **Double-clicking** launches `cmd.exe` and executes commands sequentially.
  - **Right-clicking $\rightarrow$ Edit** opens the file in a text editor (e.g., Notepad) for code modification.
- **Execution Lifetime**: By default, when a batch script finishes executing its last instruction, the `cmd.exe` process closes immediately. If launched from GUI, the window flashes and disappears unless an explicit delay or pause is coded.

---

### Core Batch Commands

| Command   | Syntax                                                                   | Description                                                                                  |
| :-------- | :----------------------------------------------------------------------- | :------------------------------------------------------------------------------------------- |
| `DIR`     | `DIR [drive:][path][filename]`                                           | Lists files, directories, sizes, and timestamps in the target folder.                        |
| `TIMEOUT` | `TIMEOUT [/T] <seconds> [/NOBREAK]`                                      | Pauses command-line execution for a specified number of seconds. Displays a countdown timer. |
| `PAUSE`   | `PAUSE`                                                                  | Suspends execution and displays `"Press any key to continue . . ."`.                         |
| `ECHO`    | `ECHO [message]` \| `ECHO [ON \| OFF]`                                   | Displays messages on the screen or toggles command echoing.                                  |
| `MSG`     | `MSG {username \| sessionname \| sessionid \| @filename \| *} [message]` | Sends a graphical pop-up dialog box to one or more user sessions on the server.              |
| `START`   | `START ["title"] [/D path] [options] "program"`                          | Launches an application or command in a separate window.                                     |

---

### Lab Walkthrough: Building Batch Scripts

#### Script 1: Directory Enumeration with Controlled Delay (`list.bat`)

This script enumerates the files in the user's desktop directory and holds the console open so the administrator can review the results.

```bat
@echo off
rem Enumerates current folder contents and waits 20 seconds before closing
dir
timeout /t 20
```

> [!NOTE]
> Without `timeout 20` or `pause`, the command window would execute `dir` and close instantaneously, preventing any human observation of the output.

---

#### Script 2: Terminal Message Output (`helloworld.bat`)

Demonstrates direct terminal printing using the `echo` command.

```bat
echo Hello World
timeout 20
```

- Output in console:

  ```text
  C:\Users\Administrator\Desktop\scripts>echo Hello World
  Hello World

  C:\Users\Administrator\Desktop\scripts>timeout 20

  Waiting for 20 seconds, press a key to continue ...
  ```

---

#### Script 3: Graphical Modal Pop-up Notification (`helloworld2.bat`)

Rather than outputting text to a terminal window, administrators often need to broadcast a notification to logged-in users (e.g., warning of an impending server reboot). The `msg` utility triggers a native Windows dialog box.

```bat
msg * "Hello World"
```

```
┌────────────────────────────────────────────────────────┐
│ Message from ADMINISTRATOR                             │
├────────────────────────────────────────────────────────┤
│                                                        │
│ Hello World                                            │
│                                                        │
│                                           [  OK  ]     │
└────────────────────────────────────────────────────────┘
```

- **`*` (Asterisk Wildcard)**: Broadcasts the message to **all active sessions** on the local server or Remote Desktop Services (RDS) host.
- **Execution characteristics**: The command prompt opens momentarily in the background for a fraction of a second and immediately terminates once the message dispatch is processed by the Windows messaging subsystem.

---

#### Script 4: Sequential Application Launch Automation (`allscripts.bat`)

Illustrates chaining multiple application launches with pauses between execution steps.

```bat
@echo off
rem Step 1: Delay then launch Calculator
timeout 5
calc

rem Step 2: Delay then launch File Explorer
timeout 5
explorer

rem Step 3: Delay then launch MS Paint
timeout 5
mspaint

rem Step 4: Delay then launch Task Manager
timeout 5
taskmgr
```

- **Execution Behavior**: Each command is triggered sequentially. In Windows batch processing, GUI executables like `calc` or `mspaint` launch their own graphical processes. If invoked directly, `cmd.exe` continues to the next line or waits depending on how the application handles the console handle (using `start <prog>` guarantees non-blocking launch).

> [!TIP]
> **Best Practice**: Always store administrative scripts in a centralized, secure directory (e.g., `C:\Scripts` or `C:\Users\Administrator\Desktop\scripts`) rather than leaving them scattered across the desktop. Restrict NTFS write permissions to `SYSTEM` and `Domain Admins` to prevent unauthorized tampering.

---

## 3. Windows PowerShell Architecture & Discovery

**Windows PowerShell** is an object-oriented task automation engine and configuration management framework developed by Microsoft, built directly on top of the **.NET Framework** (and later .NET Core in PowerShell 7+).

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Windows PowerShell Engine                       │
├────────────────────────────────────────────────────────────────────────┤
│  Cmdlets (Verb-Noun)   │   Functions   │   Aliases   │    Scripts      │
├────────────────────────┴───────────────┴─────────────┴─────────────────┤
│                  Object Pipeline (Structured .NET Data)                │
├────────────────────────────────────────────────────────────────────────┤
│                     Underlying .NET Common Language Runtime            │
├────────────────────────────────────────────────────────────────────────┤
│  WMI / CIM  │  Win32 APIs  │  Active Directory  │  Registry  │  Files  │
└─────────────┴──────────────┴───────────────────┴────────────┴─────────┘
```

### Cmdlet Architecture (`Verb-Noun`)

Unlike legacy DOS commands which are arbitrary abbreviations (`dir`, `del`, `ren`, `md`), PowerShell commands are called **Cmdlets** (command-lets) and strictly follow a **`Verb-Noun`** naming convention:

- **Approved Verbs**: Standardized actions such as `Get`, `Set`, `New`, `Remove`, `Start`, `Stop`, `Restart`, `Enable`, `Disable`.
- **Singular Nouns**: Clear description of the resource being acted upon, such as `Process`, `Service`, `Item`, `LocalUser`, `ADUser`, `Computer`.
- **Examples**: `Get-Process`, `New-Item`, `Restart-Computer`, `New-LocalUser`.
- **Case-Insensitivity**: PowerShell is completely case-insensitive (`get-help`, `Get-Help`, and `GET-HELP` execute identically).

---

### The PowerShell Help System

PowerShell provides an extensive built-in documentation system analogous to UNIX/Linux manual (`man`) pages.

```
                   ┌──────────────────────────────────────┐
                   │          PowerShell Help Engine      │
                   └──────────────────┬───────────────────┘
                                      │
         ┌────────────────────────────┼────────────────────────────┐
         ▼                            ▼                            ▼
┌──────────────────┐        ┌──────────────────┐        ┌──────────────────┐
│   Update-Help    │        │  Get-Help <Word> │        │ Get-Help <Cmdlet>│
│ Downloads latest │        │ Discovers cmdlets│        │ Full parameters, │
│ Microsoft docs   │        │ matching keyword │        │ syntax, examples │
└──────────────────┘        └──────────────────┘        └──────────────────┘
```

#### 1. Updating Help Files (`Update-Help`)

Windows Server installations often ship with basic help stubs to conserve disk space. To download the complete, current documentation from Microsoft content delivery networks:

```powershell
Update-Help
```

_(Requires outbound internet access from the server)._

#### 2. Keyword-Based Discovery

If you do not know the exact cmdlet name, query the help engine using broad keywords:

```powershell
Get-Help remote
Get-Help user
Get-Help service
```

- The engine parses all registered modules and lists every cmdlet, function, and conceptual topic containing the keyword.

#### 3. Inspecting Cmdlet Syntax & Examples

Once the target cmdlet is identified, inspect its parameter sets and usage:

```powershell
# Basic synopsis and syntax
Get-Help Get-Process

# Detailed documentation including parameter explanations
Get-Help New-LocalUser -Detailed

# Code examples showing real-world invocations
Get-Help New-LocalUser -Examples

# Opens the official Microsoft Learn documentation in default web browser
Get-Help Get-RDRemoteApp -Online
```

---

### Command Discovery (`Get-Command`)

The `Get-Command` cmdlet returns all commands (cmdlets, functions, workflows, aliases, and external binaries) installed on the system:

```powershell
# Enumerate all commands available in current PowerShell session
Get-Command

# Filter commands by specific administrative module
Get-Command -Module ActiveDirectory

# Filter commands by noun or wildcard pattern
Get-Command *-User*
Get-Command -Verb New
```

---

### Lab Walkthrough: Creating a Local User via PowerShell

```powershell
# Step 1: Discover cmdlets related to user management
Get-Help user

# Step 2: Review syntax for local user creation
Get-Help New-LocalUser

# Step 3: Create the local user account (will prompt securely for password)
New-LocalUser -Name "DPutty"

# Step 4: Verify the user account was registered
Get-LocalUser -Name "DPutty"
```

- **Verification**: In Active Directory Domain Controller environments, verify via **Active Directory Administrative Center** (`dsac.exe`) or the Local Users and Groups console (`lusrmgr.msc`). The account is verified with `Enabled: True`.

---

## 4. PowerShell Filesystem & Administrative Cmdlets

### Filesystem Navigation & Item Management

PowerShell treats files and directories through the generalized **`Item`** abstractions, allowing uniform syntax across the filesystem, registry, and environment variables.

| Legacy DOS      | Linux / Bash | PowerShell Cmdlet              | Description                             |
| :-------------- | :----------- | :----------------------------- | :-------------------------------------- |
| `dir`           | `ls -l`      | `Get-ChildItem`                | Lists child items within a container.   |
| `md` / `mkdir`  | `mkdir -p`   | `New-Item -ItemType Directory` | Creates a new directory.                |
| `type nul > f`  | `touch`      | `New-Item -ItemType File`      | Creates a new empty file.               |
| `copy`          | `cp`         | `Copy-Item`                    | Copies an item to a target destination. |
| `del` / `erase` | `rm`         | `Remove-Item`                  | Deletes an item.                        |
| `ren`           | `mv`         | `Rename-Item`                  | Renames an existing item.               |

#### Hands-On File System Workflow

```powershell
# 1. Enumerate root drive C:\
Get-ChildItem -Path C:\

# 2. Create directory structure C:\shows\Seinfeld
New-Item -Path 'C:\shows' -ItemType Directory
New-Item -Path 'C:\shows\Seinfeld' -ItemType Directory

# 3. Create a text file within the nested folder
New-Item -Path 'C:\shows\Seinfeld\Jerry.txt' -ItemType File

# 4. Copy the file as a backup to C:\
Copy-Item -Path 'C:\shows\Seinfeld\Jerry.txt' -Destination 'C:\Jerry.bak'

# 5. Remove the backup file
Remove-Item -Path 'C:\Jerry.bak'
```

- **Directory Listing Properties**: Notice that `Get-ChildItem` outputs structured columns:
  - `Mode`: Attributes (`d` = Directory, `a` = Archive, `r` = Read-only, `h` = Hidden, `s` = System).
  - `LastWriteTime`: Timestamp of last modification.
  - `Length`: File size in bytes (blank for directories).
  - `Name`: File or directory name.

---

### Core Administrative Cmdlets

```powershell
# Inspect running processes (memory WS/PM, CPU utilization, Id)
Get-Process

# Inspect status of all registered Windows services (Running, Stopped, Paused)
Get-Service

# View all registered PowerShell drives (FileSystem, Registry, Certificate Store, Env)
Get-PSDrive
```

```
Name           Used (GB)     Free (GB) Provider      Root
----           ---------     --------- --------      ----
C                  32.15         27.85 FileSystem    C:\
Cert                                   Certificate   \
Env                                    Environment
HKCU                                   Registry      HKEY_CURRENT_USER
HKLM                                   Registry      HKEY_LOCAL_MACHINE
WSMan                                  WSMan
```

---

### System State Cmdlets

PowerShell includes direct commands for system power management, replacing the legacy `shutdown.exe` command:

```powershell
# Immediately reboots the local server
Restart-Computer

# Powers down the local server
Stop-Computer

# Remote reboot of a network host (requires WinRM / admin credentials)
Restart-Computer -ComputerName "Server02" -Force
```

---

### PowerShell Scripting (`.ps1`)

PowerShell scripts are saved with the **`.ps1`** extension.

#### Lab Example: `powershell_helloworld.ps1`

```powershell
# Print string to output pipeline
Write-Output "Hello World"

# Sleep/pause execution for 20 seconds
Start-Sleep -Seconds 20
```

#### Execution Security (Execution Policies)

Unlike `.bat` files, double-clicking a `.ps1` file **opens the file in Notepad** by default instead of executing it. This is a deliberate security defense against drive-by script execution.

- To execute from GUI: Right-click `.ps1` $\rightarrow$ select **Run with PowerShell**.
- To execute from an active PowerShell console:
  ```powershell
  .\powershell_helloworld.ps1
  ```
- **Execution Policy Management**: Windows restricts script execution by default (`Restricted` on workstations, `RemoteSigned` on modern servers):

  ```powershell
  # Check current execution policy
  Get-ExecutionPolicy

  # Permit execution of locally authored scripts
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

---

## 5. Windows PowerShell Integrated Scripting Environment (ISE)

**PowerShell ISE** (`powershell_ise.exe`) is a built-in Graphical User Interface for authoring, testing, and debugging PowerShell scripts in a unified multi-pane environment.

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ Windows PowerShell ISE                                              [—] [口] [X] │
├─────────────────────────────────────────────────────────────────────────────────┤
│ [Run (F5)] [Run Selection (F8)] [Stop] [Clear Console]                          │
├───────────────────────────────────────────────────────┬─────────────────────────┤
│ 1: # Script Pane (Editor)                             │ Commands Pane (Add-on)  │
│ 2: Get-Process | Where-Object CPU -gt 10              │ ┌─────────────────────┐ │
│ 3: Start-Sleep -Seconds 5                             │ │ Modules: All        │ │
│ 4: Write-Output "Check Completed"                     │ │ Name: user          │ │
│                                                       │ ├─────────────────────┤ │
│                                                       │ │ New-LocalUser       │ │
│                                                       │ │ Get-LocalUser       │ │
│                                                       │ │ Set-LocalUser       │ │
├───────────────────────────────────────────────────────┤ └─────────────────────┘ │
│ PS C:\> # Console Pane (Interactive Execution Output) │ Parameter Form:         │
│ Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id │ Name: [ DPutty       ] │
│      43      12    12400      25400      12.45   1024 │ [Insert] [Run] [Copy]   │
└───────────────────────────────────────────────────────┴─────────────────────────┘
```

### Three-Pane Architecture

1. **Script Pane (Code Editor)**:
   - Multi-tabbed code editor with line numbering and syntax coloring.
   - Context-sensitive IntelliSense and tab completion for cmdlets, parameters, and variable paths.
   - Debugging engine with breakpoint support (`F9`), step-into (`F11`), and step-over (`F10`).
2. **Console Pane**:
   - Fully functional interactive PowerShell console.
   - Displays output streams (`Output`, `Warning`, `Error`, `Verbose`, `Debug`).
   - Clear screen via the console wipe icon or typing `Clear-Host` / `cls`.
3. **Commands Pane (GUI Cmdlet Explorer)**:
   - Lists all available cmdlets categorized by module.
   - Provides graphical forms where administrators can type parameter values into text boxes and click **Run** or **Insert** directly into the editor.

### Key Execution Controls

- **Run Entire Script (`F5`)**: Executes all code in the active Script Pane.
- **Run Selection (`F8`)**: Executes only the highlighted text or the line currently under the cursor. Enables rapid, iterative testing without re-running entire scripts.
- **Show/Hide Script Pane (`Ctrl + R`)**: Toggles the code editor to expand the console full-screen.

---

## 6. Windows Management Instrumentation (WMI & WMIC)

**Windows Management Instrumentation (WMI)** is Microsoft's implementation of Web-Based Enterprise Management (WBEM) and the Common Information Model (CIM). It provides an infrastructure for querying system management data and performing hardware and OS operations locally and across network environments.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        WMI Architecture Layer                          │
├────────────────────────────────────────────────────────────────────────┤
│ Management Applications:  WMIC.exe  │  PowerShell CIM  │  wmimgmt.msc  │
├────────────────────────────────────────────────────────────────────────┤
│                       WMI Service (winmgmt)                            │
├────────────────────────────────────────────────────────────────────────┤
│                CIM Object Manager & WMI Repository                     │
├────────────────────────────────────────────────────────────────────────┤
│ WMI Providers:  Win32 Provider │ Registry Provider │ Active Directory  │
├────────────────────────────────────────────────────────────────────────┤
│ Managed Objects: Hardware (CPU, RAM, Disks), OS, Services, Processes   │
└────────────────────────────────────────────────────────────────────────┘
```

### The WMIC Command-Line Utility (`WMIC.exe`)

`WMIC` exposes WMI classes via a specialized command shell.

#### Entering and Navigating the WMIC Shell

```cmd
# Launch WMIC from standard Command Prompt
C:\> wmic
wmic:root\cli>

# Access interactive help and list all supported class aliases
wmic:root\cli> /?

# Terminate and return to standard command prompt
wmic:root\cli> quit
```

#### Key WMIC Queries

```cmd
# Query physical memory hardware (DIMM modules)
wmic:root\cli> memorychip

# Query Active Directory domain membership, forest, site name, and DC IP
wmic:root\cli> ntdomain

# Query Operating System edition, build number, version, install date
wmic:root\cli> os

# Query CPU specifications, clock speed, core counts
wmic:root\cli> cpu

# Query logical disks, free space, and drive letters
wmic:root\cli> logicaldisk get name, freespace, size
```

> [!NOTE]
> When running `memorychip` inside virtual machines (e.g., VMware, Hyper-V, VirtualBox), WMIC may report `No Instance(s) Available` because the virtualized BIOS does not populate physical SPD DIMM hardware registers.

---

### WMI Management GUI Console (`wmimgmt.msc`)

For managing WMI repository security and connecting to remote servers visually:

1. Launch via `Run` dialog or Command Prompt: `wmimgmt.msc`.
2. Right-click **WMI Control (Local)** $\rightarrow$ **Connect to another computer...**.
3. Select **Another computer**, input the target server's IP address or DNS resolvable hostname.
4. Specify administrative credentials to inspect and manage remote WMI configurations, namespaces (`root\cimv2`), and security permissions.

```
┌────────────────────────────────────────────────────────┐
│ WMI Control Properties                     [?] [X]     │
├────────────────────────────────────────────────────────┤
│ General │ Backup/Restore │ Security │ Advanced         │
├────────────────────────────────────────────────────────┤
│ Target: Local Computer (or 192.168.1.10)               │
│ Successfully connected to WMI repository.              │
│ OS Version: Microsoft Windows Server 2016              │
│ Service Pack: 0.0                                      │
│ WMI Version: 10.0.14393.0                              │
│                                                        │
│                                           [  OK  ]     │
└────────────────────────────────────────────────────────┘
```

> [!IMPORTANT]
> **Modern Industry Evolution**: `WMIC.exe` was officially deprecated by Microsoft starting in Windows 10 / Server 2016 and is removed in newer releases. Modern Windows administration uses PowerShell **CIM cmdlets** (`Get-CimInstance`, `Invoke-CimMethod`), which use WS-Man (WinRM) instead of legacy DCOM/RPC:
>
> ```powershell
> # Modern equivalent of 'wmic os'
> Get-CimInstance -ClassName Win32_OperatingSystem
>
> # Modern equivalent of 'wmic cpu'
> Get-CimInstance -ClassName Win32_Processor
> ```

---

## 7. Architectural Comparison: Command Prompt (DOS) vs. PowerShell

Understanding the conceptual differences between `cmd.exe` and `powershell.exe` is essential for mastering modern Windows Server administration.

```
                  ┌────────────────────────────────────────┐
                  │       Command Stream Comparison        │
                  └───────────────────┬────────────────────┘
                                      │
         ┌────────────────────────────┴────────────────────────────┐
         ▼                                                         ▼
┌─────────────────────────────────┐               ┌─────────────────────────────────┐
│      Command Prompt (DOS)       │               │        Windows PowerShell       │
├─────────────────────────────────┤               ├─────────────────────────────────┤
│ [Cmd 1] ─── Raw Text ───> [Cmd 2│               │ [Cmdlet 1] ── .NET Object ─> [Cmdlet 2]
│                                 │               │                                 │
│  "admin   active   12.4 MB"     │               │  Process Object:                │
│                                 │               │    .Name = "admin"              │
│  Requires fragile string        │               │    .Status = "Running"          │
│  tokenizing, regex, findstr     │               │    .WorkingSet = 13002342       │
└─────────────────────────────────┘               └─────────────────────────────────┘
```

### Comprehensive Comparison Matrix

| Architectural Feature          | Command Prompt (`cmd.exe` / DOS)                                              | Windows PowerShell (`powershell.exe`)                                                              |
| :----------------------------- | :---------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------- |
| **Pipeline Data Format**       | **Raw Unstructured Text Streams** (`stdout` / `stdin`).                       | **Rich .NET Objects** passing typed properties and methods.                                        |
| **Underlying Framework**       | Legacy Win32 C/C++ runtime APIs.                                              | Microsoft .NET Framework / .NET Core / CLR.                                                        |
| **Command Taxonomy**           | Disparate, historic abbreviations (`dir`, `ren`, `xcopy`, `del`).             | Standardized **`Verb-Noun`** cmdlets (`Get-ChildItem`, `Rename-Item`, `Copy-Item`, `Remove-Item`). |
| **WMI & Registry Integration** | Requires external binaries (`wmic.exe`, `reg.exe`).                           | Native integration via cmdlets (`Get-CimInstance`) and PSDrives (`HKLM:`, `HKCU:`).                |
| **Remote Execution**           | Limited; required 3rd-party tools (Sysinternals `psexec`) or Telnet.          | Native enterprise remoting over WS-Management / WinRM (`Invoke-Command`, `Enter-PSSession`).       |
| **Script Execution Safety**    | `.bat` executes immediately on double-click (high malware risk).              | `.ps1` opens in Notepad on double-click; controlled by configurable `ExecutionPolicy`.             |
| **Extensibility**              | Static built-in commands; hard to extend.                                     | Dynamic module architecture (`Import-Module`, PowerShell Gallery `Install-Module`).                |
| **Error Handling**             | Primitive (`%ERRORLEVEL%` checks, `goto :error`).                             | Structured Object-Oriented Exception Handling (`try { ... } catch { ... } finally`).               |
| **Learning Curve**             | Shallow initial curve, but complex scripts become brittle and unmaintainable. | Steeper initial learning curve, but scales effortlessly to enterprise cloud automation.            |

### The Power of Object Piping Explained

In `cmd.exe`, piping outputs raw text strings:

```cmd
tasklist | findstr /i "notepad"
```

If you need to extract the Process ID (PID) from `tasklist`, you must write complex batch parsing routines using `for /f "tokens=2" %%a in (...)`.

In PowerShell, the output of `Get-Process` is a stream of live `System.Diagnostics.Process` objects. You interact directly with named properties:

```powershell
# Filter by object property and terminate process cleanly
Get-Process | Where-Object { $_.CPU -gt 50 } | Stop-Process -Confirm
```

No string slicing, whitespace counting, or token parsing is ever required.

---

## 8. Quick Reference & Command Cheat Sheet

### Batch Scripting (`.bat`)

```bat
rem Turn off command printing to console
@echo off

rem Output text
echo Running maintenance scripts...

rem Send pop-up dialog to all users
msg * "Server will reboot in 10 minutes."

rem Wait with countdown timer
timeout /t 10 /nobreak

rem Launch apps
start calc
start notepad
start explorer

rem Unconditional pause
pause
```

---

### PowerShell Discovery & Help

```powershell
# Update documentation
Update-Help

# Search commands by keyword
Get-Help <keyword>
Get-Command *<keyword>*

# Get command details and examples
Get-Help <Cmdlet-Name> -Detailed
Get-Help <Cmdlet-Name> -Examples
Get-Help <Cmdlet-Name> -Online

# Filter by Module
Get-Command -Module ActiveDirectory
```

---

### Filesystem & Administration Cmdlets

```powershell
# File System
Get-ChildItem -Path C:\
New-Item -Path 'C:\Backup' -ItemType Directory
New-Item -Path 'C:\Backup\log.txt' -ItemType File
Copy-Item -Path 'C:\file.txt' -Destination 'C:\Backup\'
Remove-Item -Path 'C:\Backup\log.txt' -Force

# Process & Services
Get-Process
Stop-Process -Name "notepad"
Get-Service -Name "wuauserv"
Start-Service -Name "wuauserv"
Restart-Service -Name "wuauserv"

# User Management
New-LocalUser -Name "AdminUser"
Get-LocalUser
Enable-LocalUser -Name "AdminUser"
Disable-LocalUser -Name "AdminUser"

# Power Operations
Restart-Computer -Force
Stop-Computer -Force
```

---

### WMI / WMIC Queries

```cmd
# Launch WMIC shell
wmic

# Common queries in WMIC
wmic:root\cli> os
wmic:root\cli> cpu
wmic:root\cli> memorychip
wmic:root\cli> ntdomain
wmic:root\cli> bios
wmic:root\cli> quit

# Launch WMI Management MMC
wmimgmt.msc
```
