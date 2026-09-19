# Networking & System Updates

---

## 1. NIC (Network Interface Card)

- **NIC** = Network Interface Card (or Controller) — a hardware add-in card that fits into an expansion slot inside a computer
- The **ports** (where you plug in an Ethernet/Cat5/Cat6 cable) are attached to the NIC and face outside the computer
- A NIC can have **one or more ports** — servers commonly have multi-port NICs
- **All network communication flows through the NIC**
- Wi-Fi cards are also NICs — they just don't have physical ports since communication is wireless

---

## 2. VM Networking

- A VM's network runs **over its host's network** — traffic from the VM flows through the host's physical NIC
- The hypervisor (e.g. VirtualBox, Proxmox) creates a **virtual NIC** inside the VM
- **Bridged Adapter** = VM bridges to the host's physical NIC → VM can access the internet and the local network
- **Host-Only Adapter** = VM can only communicate with the host, not the outside network

---

## 3. NIC Teaming

Also known as **NIC bonding**, **link aggregation**, or **NIC teaming** (Windows term).

**Definition**: Combining multiple NICs into a single logical team interface.

**Main purposes**:
| Purpose | Description |
|---------|-------------|
| **Redundancy** | If one port fails, the other takes over — no downtime |
| **High Bandwidth / Link Aggregation** | Two 1 Gbps NICs = 2 Gbps throughput |

### Teaming Modes

| Mode                   | Description                                                                                            |
| ---------------------- | ------------------------------------------------------------------------------------------------------ |
| **Static**             | Requires configuration on the physical switch                                                          |
| **Switch Independent** | Does NOT require switch configuration — works without switch involvement                               |
| **LACP** (Dynamic)     | Link Aggregation Control Protocol — requires switch-side LACP config, provides active link aggregation |

> [!IMPORTANT]
> In a **VM environment** (Proxmox, VirtualBox, etc.), always use **Switch Independent** mode. LACP requires the physical/virtual switch to participate in the 802.3ad protocol — virtual bridges (like Proxmox's `vmbr`) do not support this.

### NIC Teaming in Windows Server (Lab Steps)

1. **Server Manager → Local Server → NIC Teaming → Disabled** (click to open)
2. **TASKS → New Team** → enter team name (e.g. `Team1`)
3. Select both adapters (e.g. `Ethernet`, `Ethernet 2`)
4. Set **Teaming mode**: `Switch Independent`
5. Set **Load balancing**: `Dynamic`
6. Click **OK** → team becomes active

> [!NOTE]
> After creating the team, assign the **static IP to the Team interface** (e.g. `Team1`), NOT to the individual Ethernet adapters. Individual adapters hand off their identity to the team. The team adapter's `ipconfig` output will show double the speed (e.g. 2 Gbps if both were 1 Gbps).

### Proxmox-Specific Notes (Personal Lab)

- Both NICs must be the **same type** (both VirtIO) — mixing VirtIO + e1000 causes teaming failures
- Both NICs should be on the same bridge (e.g. `vmbr0`)
- After creating the team, assign the server's IP (`10.0.0.30/24`, GW `10.0.0.1`) to the Team1 interface
- Windows may assign a **Public** firewall profile to the new Team interface → change to **Private** or **Domain** to restore RDP/SMB access

---

## 4. Networking Concepts

### Key Terms

| Term                | Description                                                                                                                               |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **IP Address**      | Internet Protocol address — a unique identifier for a computer on a network (e.g. `10.0.0.30`). Like a house address.                     |
| **Subnet Mask**     | Divides a network into sub-networks (e.g. `255.255.255.0` = `/24`). Tells the computer which network it belongs to.                       |
| **Default Gateway** | The "door" out of the local network — usually the router (e.g. `10.0.0.1`). All traffic going outside the local subnet goes through here. |
| **MAC Address**     | Media Access Control address — a hardware-level unique identifier burned into the NIC by the manufacturer.                                |
| **DHCP**            | Dynamic Host Configuration Protocol — automatically assigns IP addresses. Changes on reboot.                                              |
| **Static IP**       | Manually assigned IP — does not change on reboot. Required for servers.                                                                   |

### Useful Commands

```cmd
ipconfig                  # Shows IP, subnet, gateway for all adapters
ipconfig /all             # Shows MAC address, DHCP status, DNS, full details
ipconfig /release         # Releases DHCP lease
ipconfig /renew           # Requests new DHCP lease
```

---

## 5. Windows Updates

- **Windows Update** is a Microsoft service that automatically downloads and installs patches, bug fixes, and security updates
- Updates are identified by **KB (Knowledge Base) article numbers**
- Main reasons for updates:
  - Fix bugs or flaws in the OS
  - Improve stability
  - Fix **security vulnerabilities** (e.g. WannaCry ransomware was patched via Windows Update)

### Accessing Windows Update

- **Settings → Update & Security → Windows Update**

### Windows Update Service

- Service name: `Windows Update`
- Can be stopped/started via `services.msc`
- Can be managed via **Group Policy**: `gpedit.msc → Administrative Templates → Windows Components → Windows Update`

---

## 6. NTP (Network Time Protocol)

**NTP** synchronizes clock time across computers on a network. Critical for:

- Application workflows (logs, transactions) between servers
- Active Directory authentication (Kerberos requires clocks within 5 minutes)
- Troubleshooting — mismatched timestamps make log correlation impossible

### How It Works

```
[External NTP Server (pool.ntp.org)]
           ↓
  [Internal NTP Server]
    ↓    ↓    ↓    ↓
[Server1][Server2][Server3][Client]
```

### Windows NTP Commands

```powershell
# Configure NTP server
w32tm /config /manualpeerlist:pool.ntp.org /syncfromflags:manual

# Restart Windows Time service
Stop-Service w32tm
Start-Service w32tm

# Force sync
w32tm /resync

# Check status (should show Source: pool.ntp.org)
w32tm /query /status
```

> Windows Time service (`w32tm`) must be running for NTP to work.

---

## 7. File Transfer Methods

| Method                            | Notes                                          |
| --------------------------------- | ---------------------------------------------- |
| USB drive                         | Physical, no network needed                    |
| External HDD                      | Same as USB                                    |
| Email                             | Limited file size                              |
| Text message                      | Very limited                                   |
| Cloud storage (Dropbox, OneDrive) | Good for sharing, size limits on free tier     |
| **FTP**                           | Standard enterprise protocol for file transfer |
| **File Sharing (SMB/NFS)**        | Mount remote folders directly as a drive       |
| Third-party tools                 | FileZilla, WinSCP, etc.                        |

---

## 8. FTP Server

**FTP** = File Transfer Protocol — standard protocol for transferring files between a client and a server using **separate control (port 21) and data connections**.

### Installation (Windows Server)

1. **Server Manager → Add Roles and Features**
2. Select **Web Server (IIS)** → expand → check **FTP Server** → **FTP Service**
3. Install → Close

### Configuration (IIS Manager)

1. **Tools → Internet Information Services (IIS) Manager**
2. Expand server → right-click **Sites** → **Add FTP Site**
3. Set:
   - **Site name**: e.g. `DionysusFTPServer`
   - **Physical path**: e.g. `C:\FTPIncoming`
   - **IP**: server's IP (or All Unassigned)
   - **Port**: `21` (default)
   - **SSL**: No SSL (for lab)
   - **Authentication**: Basic
   - **Authorization**: All users, Read + Write

### FTP Client (Windows CMD)

```cmd
ftp 10.0.0.30          # Connect to FTP server
bi                      # Switch to binary mode (for non-text files)
hash                    # Show progress hash marks during transfer
put largevalues.txt    # Upload file to server
dir                     # List files on server
bye                     # Disconnect
```

### Active vs Passive FTP

| Mode        | Data Connection                       | NAT-friendly         |
| ----------- | ------------------------------------- | -------------------- |
| **Active**  | Server connects BACK to client        | ❌ Fails through NAT |
| **Passive** | Client connects to server's data port | ✅ Works through NAT |

> Windows' built-in `ftp.exe` only supports **Active mode**. For clients behind NAT (e.g. Parallels Shared mode), use **FileZilla** or ensure the client is on the same subnet as the server (Bridged adapter mode).

### Lab Gotchas (Personal Notes)

- FTP firewall rules must be added manually — built-in IIS FTP rules may have hidden scope restrictions
  ```powershell
  New-NetFirewallRule -DisplayName "FTP Port 21 Allow" -Direction Inbound -Protocol TCP -LocalPort 21 -Action Allow -Profile Any
  New-NetFirewallRule -DisplayName "FTP Passive Data Ports" -Direction Inbound -Protocol TCP -LocalPort 50000-50100 -Action Allow -Profile Any
  ```
- Configure passive port range: **IIS Manager → Server → FTP Firewall Support → 50000-50100**
- For active FTP from a client on the same subnet: client's Windows Firewall must allow **inbound** connections from the server (data connection back to client)
  ```powershell
  New-NetFirewallRule -DisplayName "FTP Active Data Allow" -Direction Inbound -Protocol TCP -LocalPort 1024-65535 -RemoteAddress 10.0.0.30 -Action Allow -Profile Any
  ```

---

## 9. File Sharing (SMB)

**SMB** = Server Message Block — Microsoft's network file-sharing protocol. Also known as **CIFS** (Common Internet File System). **Samba** is the Linux implementation of SMB.

### Create and Share a Folder (GUI)

1. Create folder (e.g. `C:\Simpsons`)
2. Right-click → **Properties → Sharing → Share**
3. Add users (e.g. `Everyone`) → **Share**

### Permissions — Both Must Allow Access

> [!IMPORTANT]
> There are **two separate permission layers**. Both must grant access:
>
> - **Share Permissions** (network access) — set via Sharing tab
> - **NTFS Permissions** (filesystem access) — set via Security tab

```powershell
# Grant share permissions
Grant-SmbShareAccess -Name "Simpsons" -AccountName "Everyone" -AccessRight Full -Force

# Grant NTFS permissions (with inheritance)
icacls "C:\Simpsons" /grant "Everyone:(OI)(CI)F" /T /C
```

### Access from Client

```cmd
# Connect with explicit credentials (non-domain client)
net use \\10.0.0.30\Simpsons /user:mseinfeld password

# Open in File Explorer
explorer \\10.0.0.30\Simpsons

# Map as a drive letter
net use Z: \\10.0.0.30\Simpsons /persistent:yes
```

---

## 10. WSUS (Windows Server Update Services)

**WSUS** allows administrators to centrally manage and distribute Windows updates to client computers — without each client needing direct internet access.

### Why Use WSUS?

- **Centralized management**: Update 100s of servers from one place
- **No internet required for clients**: Only the WSUS server needs internet access; it distributes updates internally
- **Control**: Choose which updates to approve and deploy

### Architecture

```
[Microsoft Update] → [WSUS Server] → [All Clients]
                         ↑
               (only this server needs internet)
```

### Installation

1. **Server Manager → Add Roles and Features → Windows Server Update Services**
2. Select **WID Connectivity** + **WSUS Services** (use built-in WID database)
3. Set content directory (e.g. `C:\WSUS`) — needs NTFS, min 6 GB free
4. Install → **Launch Post-Installation Task**

### Post-Install Wizard

- **Connect to Upstream Server**: Microsoft Update (takes 20–45 min on first run)
- **Choose Products**: Select only what you need (e.g. Windows 10, Windows Server 2022)
- **Choose Classifications**: Security Updates, Critical Updates
- **Sync Schedule**: Manual or automatic (daily recommended)

### Lab Gotcha — SUSDB Schema Conflict

If you see `Fatal Error: The schema version of the database is from a newer version of WSUS`:

```powershell
# Connect to WID and drop the old SUSDB
$conn = New-Object System.Data.SqlClient.SqlConnection(
    "Server=np:\\.\pipe\MICROSOFT##WID\tsql\query;Integrated Security=SSPI;"
)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "ALTER DATABASE SUSDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE SUSDB"
$cmd.ExecuteNonQuery()
$conn.Close()

# Fix performance counter registry if needed
lodctr /R

# Re-run post-install
& "C:\Program Files\Update Services\Tools\WsusUtil.exe" postinstall CONTENT_DIR=C:\WSUS
```

---

## 11. Windows Firewall

A **firewall** monitors and controls incoming/outgoing network traffic based on security rules — a barrier between trusted (internal) and untrusted (external) networks.

### Access

- **Control Panel → System and Security → Windows Defender Firewall**
- Or: **Windows Defender Firewall with Advanced Security** (for detailed rules)

### Profiles

| Profile     | Used When                                    |
| ----------- | -------------------------------------------- |
| **Domain**  | Computer is joined to a domain               |
| **Private** | Home/trusted networks                        |
| **Public**  | Public/untrusted networks (most restrictive) |

> [!NOTE]
> When a new network adapter (e.g. Team1 after NIC teaming) appears, Windows assigns it **Public** profile by default. This blocks RDP, SMB, and other services. Change it to Domain or Private.

```powershell
# Check network profile
Get-NetConnectionProfile

# Change profile
Set-NetConnectionProfile -InterfaceAlias "Team1" -NetworkCategory Private
```

### Inbound/Outbound Rules

- **Inbound**: controls traffic coming INTO the machine
- **Outbound**: controls traffic going OUT from the machine
- To add a rule: **Advanced Security → Inbound Rules → New Rule**

### In Corporate Environments

- If a hardware firewall (managed by security/networking team) is in front of your servers, the **local Windows Firewall is typically disabled** — the perimeter firewall handles all filtering
- In lab/home environments, manage the local firewall directly
