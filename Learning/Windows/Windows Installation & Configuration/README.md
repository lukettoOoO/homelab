# Windows Server Installation & Configuration

## 1. Operating System Installation Methods

There are three primary methods used to install operating systems across physical hardware, virtualized environments, and enterprise infrastructure:

| Installation Method | Technical Description | Typical Use Cases |
| :--- | :--- | :--- |
| **Physical Media (CD / DVD / USB)** | Inserting physical bootable media into an optical drive or USB port and selecting it as the primary boot device in BIOS/UEFI. | Standalone physical servers, workstations, legacy hardware. |
| **ISO Image via Virtual Console / Hypervisor** | Downloading a disk image (`.iso`) and attaching it to a virtual optical drive via out-of-band management controllers (Dell iDRAC, HPE iLO) or hypervisors (Proxmox VE, VMware ESXi, VirtualBox). | Virtualized infrastructure, remote server management, lab environments. |
| **Network Boot (PXE / Netboot)** | Booting over the local network via Preboot Execution Environment (PXE). The client machine queries DHCP/TFTP and loads installation files from an NFS or Samba network share. | Enterprise deployments provisioning tens or hundreds of bare-metal servers automatically. |

---

## 2. Obtaining Windows Server Evaluation Media

Microsoft provides 180-day trial versions of Windows Server (such as Windows Server 2016 and 2022) via the **Microsoft Evaluation Center** (`technet.microsoft.com`).

### Key Download & Licensing Details
* **Format**: 64-bit ISO image file.
* **Trial Duration**: 180 days evaluation period.
* **Activation Requirement**: Evaluation instances must activate over the internet within the first 10 days of deployment to prevent automatic scheduled shutdowns.
* **Enterprise Usage Context**: Many enterprise environments still operate Windows Server 2016 alongside Windows Server 2022. Server management concepts, administrative interfaces, and core roles (Active Directory, DNS, Group Policy) remain consistent across both versions.

---

## 3. Windows Server Installation Procedure

### Step-by-Step Installation Workflow

#### Step 1: Mount ISO & Initiate Boot
* Mount the downloaded Windows Server ISO to the virtual machine's optical drive.
* Power on the machine and boot from the virtual CD/DVD drive.
* *Note on Hypervisor Input*: Hypervisors (like VirtualBox or VMware) capture mouse and keyboard input upon clicking inside the VM window. Use the designated host key (e.g., Right `Ctrl`) to release input back to the host system.

#### Step 2: Language & Regional Selection
* **Language to install**: English (or preferred system language).
* **Time and currency format**: Select regional locale.
* **Keyboard layout**: Select input layout (e.g., US).

#### Step 3: Setup Mode Selection
* **Install Now**: Begins new operating system deployment.
* **Repair Your Computer**: Enters Windows Recovery Environment (WinRE) for troubleshooting corrupted system files, repairing bootloaders, or executing administrative password recovery scripts.

#### Step 4: Edition Selection (Standard vs. Datacenter & Core vs. Desktop)
When installing Windows Server, you must choose between two main edition tiers and two interface modes:

```
                      ┌────────────────────────────────────────┐
                      │          Windows Server Editions       │
                      └───────────────────┬────────────────────┘
                                          │
                  ┌───────────────────────┴───────────────────────┐
                  ▼                                               ▼
     ┌─────────────────────────┐                     ┌─────────────────────────┐
     │    Standard Edition     │                     │   Datacenter Edition    │
     │ (Basic Server Roles)    │                     │  (Full Enterprise Features)│
     └────────────┬────────────┘                     └────────────┬────────────┘
                  │                                               │
        ┌─────────┴─────────┐                           ┌─────────┴─────────┐
        ▼                   ▼                           ▼                   ▼
┌──────────────┐    ┌──────────────┐            ┌──────────────┐    ┌──────────────┐
│ Server Core  │    │   Desktop    │            │ Server Core  │    │   Desktop    │
│ (CLI Only)   │    │  Experience  │            │ (CLI Only)   │    │  Experience  │
└──────────────┘    └──────────────┘            └──────────────┘    └──────────────┘
```

| Interface / Edition | Feature Set & Characteristics |
| :--- | :--- |
| **Server Core** *(Standard or Datacenter)* | Minimal command-line interface without GUI elements. Reduced memory footprint, smaller attack surface, and fewer security updates required. |
| **Desktop Experience** *(Standard or Datacenter)* | Full Graphical User Interface (GUI). Required when running applications that depend on desktop components or for standard visual server administration. |
| **Datacenter Evaluation (Desktop Experience)** | Recommended enterprise selection. Includes full GUI, unlimited virtualization rights, advanced storage/networking features, and complete support for all server roles (Active Directory Domain Services, DNS, DHCP, IIS). |

#### Step 5: License Agreement & Installation Type
* Accept the End User License Agreement (EULA).
* **Select Installation Type**:
  * **Upgrade**: Preserves files, settings, and existing applications. *Only valid if a supported version of Windows is already installed.*
  * **Custom: Install Windows only (advanced)**: Performs a clean installation. Allows formatting, deleting, or creating custom disk partitions.

#### Step 6: Disk Partitioning
* Select target unallocated disk space (e.g., 50 GB or 70 GB drive).
* *Optional Partitioning*: Create custom system drives (e.g., splitting `C:` for the operating system and creating separate volumes for applications or database storage).
* Proceed with default allocation to install Windows entirely on `C:`.

#### Step 7: System Setup & First Boot
* Installer copies files, installs features, applies updates, and reboots.
* **Administrator Password**: Set a strong password for the built-in local `Administrator` account.
* **First Login (`Ctrl + Alt + Delete`)**: To send `Ctrl + Alt + Delete` inside a VM without locking the host machine, use the hypervisor's input menu (e.g., `Input -> Keyboard -> Insert Ctrl-Alt-Del` in VirtualBox/Proxmox).

---

## 4. Windows Server GUI & Desktop Overview

### Desktop Customization & System Settings
* **Default Layout**: Clean interface displaying only the `Recycle Bin` by default.
* **Restoring Desktop Icons**:
  * Navigate to `Right-click Desktop -> Personalize -> Themes -> Desktop Icon Settings`.
  * Enable icons: `This PC` (My Computer), `Network`, `Control Panel`, `User's Files`.
* **Personalization Settings**:
  * **Background / Wallpapers**: Custom solid colors or background images.
  * **Lock Screen**: Configurable static images or slideshows displayed when locked.
  * **Colors**: System accent colors for Start menu and window borders.
  * **Power & Sleep**: Configurable timers to control when display or system enters sleep mode.

### Taskbar & Start Menu Operations
* **Taskbar**: Positioned at the bottom of the screen. Displays running application indicators, quick launch shortcuts, system tray icons (network status, audio), and clock/timezone configuration.
* **Start Menu**: Divided into quick action groups:
  * **Most Used & Administrative Tools**: Direct shortcuts to system features.
  * **Power Menu**: Options to Restart or Shut Down the server.
  * **Built-in Administrative Tooling**: Access to Windows PowerShell, Event Viewer, Disk Management, and Control Panel.

### Server Manager Dashboard
Server Manager is the primary administration console in Windows Server. It opens automatically upon Administrator login.

```
┌───────────────────────────────────────────────────────────────────────────┐
│                          Server Manager Dashboard                         │
├───────────────────────────────────────────────────────────────────────────┤
│ • Configure Local Server (Computer Name, IP Address, Windows Update)      │
│ • Add Roles and Features (Active Directory, DNS, DHCP, IIS Web Server)   │
│ • Add Other Servers to Manage (Multi-Server Centralized Management)       │
│ • Create Server Groups & Connect to Cloud Services (Microsoft Azure)      │
│ • Monitor System Health, Services, and Storage Pools                      │
└───────────────────────────────────────────────────────────────────────────┘
```

### Essential System Management Utilities

| Tool / Utility | Invocation Command / Path | Purpose & Functionality |
| :--- | :--- | :--- |
| **Command Prompt** | `cmd` | Command-line interface for system diagnostic commands (`ipconfig`, `ping`, `sfc`). |
| **PowerShell** | `powershell` | Task automation and configuration management CLI environment. |
| **Task Manager** | `Ctrl + Shift + Esc` or right-click Taskbar | Monitors active system processes, CPU, RAM, Disk, and Network resource consumption. |
| **Registry Editor** | `regedit` | Hierarchical database tool for inspecting and modifying system-level settings. |
| **Direct Drive Access** | Type `C:\` in Search Bar | Bypasses File Explorer GUI to open root drive directory instantly. |
