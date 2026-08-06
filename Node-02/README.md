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

