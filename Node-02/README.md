# Node-02 Specifications

### Hardware Specs Overview
| Specification | Details / Value |
| :--- | :--- |
| **Product Model** | HP EliteDesk 800 G4 (35W) |
| **Product Code** | `69452104` |
| **Condition** | Used / Refurbished (**Grade A-**)* |
| **CPU Manufacturer** | Intel |
| **CPU Model** | Core i5-8500T (8th Gen) |
| **Cores / Frequency** | 6 Cores (Hexa-Core) @ 2.10 GHz (2.1 - 2.5 GHz) |
| **Cache Memory** | 9 MB SmartCache |
| **RAM Capacity** | 16 GB |
| **RAM Type** | DDR4 |
| **Storage Capacity** | 256 GB |
| **Storage Type** | M.2 NVMe SSD |
| **Graphics (GPU)** | Integrated (Intel UHD Graphics 630) |
| **Motherboard Chipset** | Intel Q370 |
| **Audio** | Conexant CX20632 |
| **Networking (LAN)** | Intel i219LM - 10/100/1000 Mbps (Gigabit) |
| **Optical Drive** | None |
| **I/O Ports** | • 2 x DisplayPort<br>• 1 x USB Type-C<br>• 6 x USB 3.1<br>• 1 x RJ-45 (LAN)<br>• 2 x Audio jacks |
| **Operating System** | No OS |

**Date: 2026-08-03**
- Had to order a Display Port to HDMI adapter since this Mini PC does not have any HDMI ports, only Display Ports
- Downloaded ISO for Proxmox and wrote it on a USB drive to boot the Mini PC from it
- Connected an Ethernet cable to the Mini PC from my router since Proxmox requires an Ethernet connection to install and does not support Wi-Fi

**Date: 2026-08-06**

### Proxmox Installation & Configuration

- Started Proxmox installation
- Installation summary:

| Option | Value |
| :--- | :--- |
| **Filesystem** | ext4 |
| **Disk(s)** | `/dev/nvme0n1` |
| **Country** | Romania |
| **Timezone** | Europe/Bucharest |
| **Keymap** | en-us |
| **Email** | `mihut.luca@yahoo.com` |
| **Management Interface** | nic0 |
| **Hostname** | proxmox |
| **IP CIDR** | `192.168.1.201/24` |
| **Gateway** | `192.168.1.1` |
| **DNS** | `100.100.1.1` |

- Successfully logged in to Proxmox VE Web UI at `https://192.168.1.201:8006/` and logged in with `root` username and password used during installation
- Removed enterprise repository subscription since it's not needed and added the no-subscription repository to perform the upgrade successfully

### Windows Server 2022 Installation

- The main purpose of this Windows Server is to run a **remote desktop environment** for me to use from my laptop and also transform it into a **retro-gaming machine** for my friends and I to use.
- I will download directly through URL in Proxmox web interface:
    - Windows Server 2022 ISO
    - VirtIO drivers (for efficient and optimised communication between hypervisor and OS)
- Setting up DNS server for downloading:
```bash
echo "nameserver 1.1.1.1" > /etc/resolv.conf
```
- Creating a new VM in the proxmox node with the following configuration:

| Tab / Section | Parameter / Option | Configured Value |
| :--- | :--- | :--- |
| **General** | Node | `proxmox` |
| **General** | VM ID | `100` |
| **General** | Name | `windows-server-2022-dionysus` |
| **General** | Resource Pool | *(Unspecified)* |
| **General** | Add to HA | Unchecked |
| **OS** | Media Source | `Use CD/DVD disc image file (iso)` |
| **OS** | Storage (ISO) | `local` |
| **OS** | ISO image | `win2022.iso` |
| **OS** | Guest OS Type | `Microsoft Windows` |
| **OS** | Guest OS Version | `11/2022/2025` |
| **OS** | Add additional drive for VirtIO drivers | Checked (`Yes`) |
| **OS** | Storage (VirtIO ISO) | `local` |
| **OS** | ISO image (VirtIO) | `virtio-win.iso` |
| **System** | Graphic card | `Default` |
| **System** | Machine | `q35` |
| **System** | BIOS | `OVMF (UEFI)` |
| **System** | Add EFI Disk | Checked (`Yes`) |
| **System** | EFI Storage | `local-lvm` |
| **System** | Format (EFI) | `Raw disk image (raw)` |
| **System** | Pre-Enroll keys | Checked (`Yes`) |
| **System** | SCSI Controller | `VirtIO SCSI single` |
| **System** | Qemu Agent | Unchecked (`No`) |
| **System** | Add TPM | Checked (`Yes`) |
| **System** | TPM Storage | `local-lvm` |
| **System** | TPM Format | `Raw disk image (raw)` |
| **System** | TPM Version | `v2.0` |
| **Disks** | Bus/Device | `VirtIO Block` (Index: `0`) |
| **Disks** | Storage | `local-lvm` |
| **Disks** | Disk size (GiB) | `70` |
| **Disks** | Format | `Raw disk image (raw)` |
| **Disks** | Cache | `Write back` |
| **Disks** | Discard | Unchecked (`No`) |
| **Disks** | IO thread | Checked (`Yes`) |
| **CPU** | Sockets | `1` |
| **CPU** | Cores | `2` |
| **CPU** | Type | `host` |
| **CPU** | Total cores | `2` |
| **Memory** | Memory (MiB) | `6144` (6 GB RAM) |
| **Network** | Bridge | `vmbr0` |
| **Network** | VLAN Tag | `no VLAN` |
| **Network** | Firewall | Checked (`Yes`) |
| **Network** | Model | `VirtIO (paravirtualized)` |
| **Network** | MAC address | `auto` |

- Since Proxmox uses high-performance virtualized disk controllers (VirtIO), the standard Windows Server installer does not include these drivers out of the box. By pointing to the `viostor/2k22/amd64` folder on the secondary ISO (`virtio-win.iso`), the operating system is instructed on how to communicate with the virtual hard disk created on the Mini PC's SSD.
- The Windows Server 2022 is now installed and is accessible through the proxmox web interface console.

**Date: 2026-08-07**
### Windows Server 2022 Configuration
`ipconfig` - command used to check network configuration on Windows; with `/all` option to show all network information.
- Fixed missing network adapter in Windows Server VM (`ipconfig` showed no interfaces)
- Installed the missing VirtIO network driver by right-clicking `netkvm.inf` in `D:\NetKVM\2k22\amd64\` and selecting Install
- Verified network connectivity was restored
- Setting IP address from right-clicking *This PC*, clicking *Properties*, *Ethernet settings*, *Network and Sharing Center*, *Ethernet*, *Properties*, *Internet Protocol Version 4 (TCP/IPv4)*, *Properties* and setting the IP address, subnet mask and defualt gateway.
- The resulting network configuration can be visualised by running `ipconfig` in the command prompt:
```text
Connection-specific DNS Suffix  . : 
IPv6 Address. . . . . . . . . . . : 2a02:2f08:8c0b:cf00:5981:7c5c:69a:9e5f
Link-local IPv6 Address . . . . . : fe80::5981:7c5c:69a:9e5f%6
IPv4 Address. . . . . . . . . . . : 192.168.1.210
Subnet Mask . . . . . . . . . . . : 255.255.255.0
Default Gateway . . . . . . . . . : fe80::5ea6:e6ff:fee6:3d94%6
                                    192.168.1.1
```
#### Setting up Remote Desktop
- Enabling RDP from *System Properties* -> *Remote* -> *Allow remote connections to this computer* -> *Uncheck "Allow connections only from computers running Remote Desktop with Network Level Authentication"* -> *OK*
- Downloaded Windows App from App Store on my personal Mac to test RDP connection
- Successful connection to RDP on IP `192.168.1.210`

**Date: 2026-08-18**

### Homelab Network Conflict Resolution & Automatic Boot Orchestration

- Resolved a temporary IP collision where an IoT network device intercepted `192.168.1.201` during extended downtime.
- Configured HP EliteDesk BIOS power options to `Power On` automatically after AC power loss.

**Implementing Node 01 Direct-Link Wake-on-LAN Orchestration:**
- Attached a secondary USB-to-Gigabit Ethernet adapter to the HP Mini PC, creating a dedicated direct link to Node 01's internal LAN port.
- Identified the USB interface as `enxc84d4428bc43` using `ip -br link`.
- Installed network wake utilities on Proxmox:
```bash
apt update && apt install -y etherwake wakeonlan
```

**Date 2026-08-21**

### ARP Conflict Remediation, Gateway Hard Reset and Dual-Node Recovery

- Investigated recurring connection drops to Node 02 (`192.168.1.201` Proxmox VE & `192.168.1.210` Windows Server 2022 VM).
- During outage windows, pinging `192.168.1.201` from my personal laptop resulted in abnormal round-trip latencies fluctuating between 80 ms and 170 ms:
```bash
luca@MacBook-Air---Luca [13:22:58] [~] 
-> % ping 192.168.1.201
PING 192.168.1.201 (192.168.1.201): 56 data bytes
64 bytes from 192.168.1.201: icmp_seq=0 ttl=64 time=151.695 ms
64 bytes from 192.168.1.201: icmp_seq=1 ttl=64 time=80.695 ms
64 bytes from 192.168.1.201: icmp_seq=2 ttl=64 time=126.559 ms
64 bytes from 192.168.1.201: icmp_seq=3 ttl=64 time=171.863 ms
^C
--- 192.168.1.201 ping statistics ---
4 packets transmitted, 4 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 80.695/132.703/171.863/34.047 ms
```
- Inspected the local ARP table and decoded the MAC address associated with the IP collision (`30:FF:F6:8F:39:C8` registered to *HangZhou KuoHeng Technology Co., Ltd*).
- A Wi-Fi IoT module (Tuya/smart switch chip - my dad's security camera for the garden) dynamically leased `192.168.1.201` via DHCP, causing severe Layer 2 ARP poisoning and dropping inbound TCP sessions to Proxmox Web UI (`:8006`) and RDP (`:3389`). This definitely an issue when homelabbing without my own router, so I plan on buying a router along with a switch soon.

**Router Factory Reset & DHCP Subnet Segmentation:**
- Attempted to access the gateway admin interface at `192.168.1.1` (TP-Link Archer AX1500 Wi-Fi 6 Router); admin credentials failed after 8 attempts as I didn't remember the credentials.
- Executed a physical hard reset by holding the rear Reset button for 10 seconds until all status LEDs cycled.
- Re-authenticated to the factory Wi-Fi SSID from macOS, accessed 192.168.1.1, configured a new admin password, and applied static subnet boundaries:
    - LAN Gateway: `192.168.1.1 /24`
    - DHCP Dynamic Range: `192.168.1.128` - `192.168.1.199`
    - Static Allocation Zone: Reserved IP blocks `< .128` and `> .199` for infrastructure servers (`.200` for Node 01 Eos, `.201` for Node 02 Proxmox, `.210` for Windows Server VM) to prevent any future DHCP IP collisions.
- Flushed the local macOS ARP cache to drop invalid Layer 2 hardware mappings:
```bash
sudo arp -d 192.168.1.201
```

**Date: 2026-08-22**

### Setting up OpenSSH Server on Windows Server 2022 (Dionysus)

- Instead of relying solely on RDP to manage the Windows Server 2022 VM (`192.168.1.210`), I wanted lightweight CLI access over SSH directly from my MacBook Terminal.
- **Configuring OpenSSH Server via PowerShell:**
    - Installed the native OpenSSH Server capability on Windows Server, enabled the background service to start automatically on system boot, and ensured the inbound firewall rule on port 22 was active:
    ```powershell
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    ```
    - Testing Remote SSH Connection (on macOS):
    ```bash
    ssh Administrator@192.168.1.210
    ```
- Verified and accepted the ED25519 host key fingerprint (SHA256:Cy2YfDUeJO3nDP8k6Ag6YcYpo/pf41sE1U0UeoPg878), authenticated with the Administrator password, and gained an interactive remote Windows command line session directly from my MacBook terminal.

