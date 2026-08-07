# Windows System Access and Filesystem

## 1. Accessing Windows Systems: Console vs. Remote Desktop (RDP)

Operating systems can be accessed using two primary approaches depending on the platform:
* **Linux / Unix**: Remote access is typically managed via **SSH** or **Telnet**.
* **Windows**: Remote access is primarily managed via **Remote Desktop Protocol (RDP)** or direct console access.

```
                      ┌────────────────────────────────────────┐
                      │        Windows Access Methods          │
                      └───────────────────┬────────────────────┘
                                          │
                  ┌───────────────────────┴───────────────────────┐
                  ▼                                               ▼
     ┌─────────────────────────┐                     ┌─────────────────────────┐
     │     Console Access      │                     │ Remote Desktop (RDP)    │
     │  (Direct Physical / OOB)│                     │   (Network GUI Session) │
     └─────────────────────────┘                     └─────────────────────────┘
```

### 1. Console Access
Direct access to the server's video output and keyboard/mouse input:
* **Physical Crash Cart**: Attaching a physical monitor, keyboard, and mouse directly to the server chassis.
* **Out-of-Band (OOB) Management**: Hardware management interfaces such as Dell **iDRAC** or HPE **iLO**.
* **Hypervisor Console**: Interactive virtual display window provided by virtualization platforms (Proxmox VE Console, VirtualBox Console, VMware ESXi Web Console).

### 2. Remote Desktop Access (RDP / `mstsc`)
Remote Desktop Protocol (RDP) is the standard method for managing Windows servers over a network.

#### Prerequisites for RDP Connectivity:
1. **Network Connectivity & IP Address**: Client and server must have valid IP addresses on the same subnet or routed network (`ipconfig` / `ipconfig /all`).
   * *Hypervisor Network Note*: In VirtualBox or VMware, configure the virtual network adapter to **Bridged Adapter** (or Host-Only / NAT with Port Forwarding for port 3389) so the VM receives an IP accessible from the host network.
2. **Enabling Remote Desktop Services**:
   * Navigate to `This PC -> Right-click Properties -> Remote settings -> Remote tab`.
   * Select **"Allow remote connections to this computer"**.
   * *Network Level Authentication (NLA)*: Uncheck *"Allow connections only from computers running Remote Desktop with Network Level Authentication"* when connecting from non-domain machines, cross-platform RDP clients (e.g., macOS Windows App), or lab environments without Active Directory.
3. **Connecting via RDP Client**:
   * Launch `Remote Desktop Connection` (`mstsc.exe` on Windows, or *Windows App* / *Microsoft Remote Desktop* on macOS/Linux).
   * Enter target server IP address (e.g., `192.168.1.210`).
   * Enter administrative credentials (`Administrator` and password) and accept the self-signed TLS security certificate.
4. **Console Session Lockout Behavior**: Logging into a single-user Windows instance via RDP using an account currently active on the local console will lock out the local console screen. Windows Server desktop sessions permit only one active interactive session per user account simultaneously.
5. **Quick Search Shortcut**: Type `allow remote access` or `remote desktop` directly into the Start/Taskbar Search box to open the Remote Settings panel instantly.

---

## 2. Windows File Systems & System Directory Hierarchy

### What is a File System?
A file system is a structured organizational framework used by an operating system to store, manage, locate, and retrieve files and directories on disk volumes. It functions like an organized closet where items (shirts, shoes, sweaters) are placed on dedicated shelves and drawers so they can be retrieved quickly without clutter.

```
                          ┌──────────────────────────┐
                          │   System Storage Drive   │
                          └────────────┬─────────────┘
                                       │
            ┌──────────────────────────┼──────────────────────────┐
            ▼                          ▼                          ▼
     ┌─────────────┐            ┌─────────────┐            ┌─────────────┐
     │ C:\Windows  │            │ C:\Program  │            │  C:\Users   │
     │ (System OS) │            │   Files     │            │ (User Profiles)
     └─────────────┘            └─────────────┘            └─────────────┘
```

### Major Operating System File Systems

| Operating System | File System Types | Key Characteristics |
| :--- | :--- | :--- |
| **Windows** | **NTFS** (New Technology File System)<br>**ReFS** (Resilient File System)<br>**FAT / FAT32** / **UDF** | **NTFS** is the standard file system for Windows. Supports fine-grained access control security (ACLs), file compression, encryption (EFS), volume shadow copies, and large volume sizes.<br>**UDF** is used for optical CD/DVD ISO media. |
| **Linux** | **EXT2**, **EXT3**, **EXT4**, **XFS** | High-performance journaling file systems designed for Linux kernels (XFS handles multi-terabyte volumes efficiently). |
| **macOS** | **APFS**, **HFS+** | Apple File System optimized for solid-state storage. |

### Inspecting File System Type in Windows
1. **File Explorer**: Open `This PC -> Right-click C: Drive -> Properties`. View **File System: NTFS**, Used Space, and Free Space.
2. **Disk Management (`diskmgmt.msc`)**: Open `Server Manager -> Tools -> Computer Management -> Disk Management`. Displays all connected physical disks, volume partitions, drive letters, and file system formats.

### Core Windows System Directories (`C:\`)

| Directory Path | Description & Functional Purpose |
| :--- | :--- |
| `C:\PerfLogs` | **Performance Logs**: System-generated directory used by Performance Monitor. Safe to clear; automatically recreated by Windows upon reboot. |
| `C:\Program Files` | **64-bit Applications**: Default installation directory for 64-bit application binaries, executables, and DLL libraries. |
| `C:\Program Files (x86)` | **32-bit Applications**: Dedicated directory for 32-bit applications running on 64-bit Windows via the WOW64 (Windows-on-Windows 64-bit) emulation layer. |
| `C:\Users` | **User Profiles**: Contains home directories for all local and domain accounts (e.g., `C:\Users\Administrator`, `C:\Users\Public`). Houses user Desktops, Documents, Downloads, and AppData. |
| `C:\Windows` | **Operating System Core**: Contains system binaries, drivers, kernel libraries, and system configurations (`C:\Windows\System32`, `C:\Windows\SysWOW64`).<br>*CRITICAL*: Modifying or deleting files in `C:\Windows` can corrupt the OS. |

---

## 3. File System Navigation Techniques

Windows file systems can be navigated using three complementary methods:

### 1. Graphical User Interface (GUI Navigation)
* Open `This PC` / `File Explorer`.
* Double-click folders to navigate deeper into the directory tree.
* Use the top breadcrumb navigation bar or `Backspace` to move up directory levels.
* Sort files by clicking column headers: **Name**, **Date Modified**, **Type**, or **Size**.
* *Inspecting Folder Sizes*: File Explorer displays individual file sizes in list view, but does not display total folder sizes by default. To check a folder's total size, right-click the folder and select **Properties**.

### 2. Command Prompt (`cmd` CLI Navigation)

```cmd
:: Display contents of current directory
dir

:: Change directory to a subfolder
cd Windows

:: Change directory to a specific absolute path
cd C:\Windows\System32

:: Move up one directory level
cd ..

:: Return directly to the root of the current drive
cd \

:: Auto-complete directory or file names
cd Sys<TAB>
```

### 3. Search Bar Shortcuts
Type absolute paths or system utility names directly into the Start/Taskbar Search box to open locations instantly:
* Type `C:\` to open the root system drive.
* Type `C:\Windows\System32` to jump directly into System32.
* Type `control` to open Control Panel, or `regedit` to launch Registry Editor.

---

## 4. File Types, File Properties, and Creation Methods

### The "Everything is a File" Concept
In modern operating systems, files, directories, device drivers, scripts, and links are all abstracted as file objects managed by the file system layer.

### Common File Categories

| File Category | Examples & Extensions | Description |
| :--- | :--- | :--- |
| **Plain Text Files** | `.txt`, `.log`, `.csv`, `.json` | Unformatted text documents editable in Notepad or text editors. |
| **Directories / Folders** | System folders, User directories | Special file system structures containing references to other files and subdirectories. |
| **Media Files** | `.png`, `.jpg`, `.mp3`, `.mp4` | Compressed image, audio, and video binary streams. |
| **Driver & Device Files**| `.sys`, `.inf`, `.dll` | Kernel-level device drivers enabling OS hardware communication. |
| **File Links & Shortcuts**| `.lnk` | Pointer files linking to executables or target directories elsewhere on disk. |
| **Scripts & Executables** | `.exe`, `.bat`, `.ps1`, `.cmd` | Executable binaries or plain-text automation scripts. |

### File Creation Methods
1. **Graphical Method (GUI)**: Navigate to target folder -> `Right-click -> New -> Folder` or `New -> Text Document`.
2. **Command Line Method (CLI)**:
   ```cmd
   :: Create empty file via copy nul
   copy nul Jerry.txt

   :: Create file with initial text content via echo redirection
   echo Elaine was Jerry's girlfriend > Elaine.txt

   :: Append text content to an existing file
   echo Additional text line >> Elaine.txt
   ```
3. **Application Method**: Open an application (Notepad `notepad.exe`, WordPad `wordpad.exe`, MS Word), enter content, and select `File -> Save As` to specify the filename and target directory.

### File Properties & NTFS Permissions (`Right-click -> Properties`)

Right-clicking any file or folder and selecting **Properties** reveals critical metadata:

* **General Tab**:
  * **Name & Icon**: System identifier and associated default application icon.
  * **Type of File & Opens With**: File extension and default program handler.
  * **Location**: Absolute path on disk (e.g., `C:\Users\Administrator\Desktop`).
  * **Size vs. Size on Disk**: Exact byte size vs. actual allocated disk storage (based on cluster allocation sizes).
  * **Timestamps**: Created, Modified, and Accessed dates.
  * **Attributes**: `Read-only` (prevents modification) and `Hidden`.
* **Security Tab (NTFS ACLs)**:
  * Displays Access Control Lists (ACLs) defining explicit permissions (`Full control`, `Modify`, `Read & execute`, `Read`, `Write`) for specific users and groups (`SYSTEM`, `Administrators`, standard user accounts).
* **Details & Previous Versions Tabs**:
  * Displays metadata properties (file version, author) and Volume Shadow Copy snapshots for file recovery.

---

## 5. Searching & Locating Files and Directories

Locating forgotten files across large storage volumes can be performed via GUI or CLI:

### 1. Graphical Search (File Explorer)
* Open File Explorer at the target search root (e.g., `This PC` or `C:\`).
* Type the filename or wildcard query (e.g., `Jerry` or `*.txt`) in the top-right search bar.
* Once found, right-click the file and select **Properties** to view its absolute path location.

### 2. Command Line Search (`dir /s`)

```cmd
:: Search recursively for a specific file across current directory and subdirectories
dir /s Jerry.txt

:: Search recursively from root C:\ drive for all .txt files
dir C:\ /s /b *.txt
```

* `dir /s`: Instructs `dir` to search the specified directory and all nested subdirectories.
* `/b`: Formats output in bare format (displays absolute file paths only, ideal for scripting).
