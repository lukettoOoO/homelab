*[Date: 2026-01-03]*
# My homelabbing project

To get started with my homelab, I plan to set up a two-node environment: one virtual node and one physical node using an old laptop.

This phase is purely experimental and I don't plan on maintaining this setup longterm. I just want to test out different services.

I will be using VirtualBox for virtualization on Macbook and a dual boot installation on the ASUS laptop since I want to keep the old Windows that is already installed on it.

![nodes](nodes.png)

### Machine specs:

Macbook specs:
| Specification             | Details                        |
|---------------------------|--------------------------------|
| **Model Name**            | MacBook Air                     |
| **Model Identifier**      | Mac14,2                         |
| **Model Number**          | MLXY3ZE/A                       |
| **Chip**                  | Apple M2                        |
| **Total Number of Cores** | 8 (4 performance, 4 efficiency)|
| **Memory**                | 8 GB                            |
| **System Firmware Version** | 13822.41.1                    |
| **OS Loader Version**     | 13822.41.1                      |

ASUS old laptop specs:
| Specification    | Details                                                 |
|-----------------|---------------------------------------------------------|
| **Processor**    | Intel(R) Core(TM) i3-4010U CPU @ 1.70GHz (1.70 GHz)   |
| **Installed RAM**| 8.00 GB (7.89 GB usable)                               |

## 💻 Node 01: Virtual (Macbook)
- Host: MacBook Pro / VirtualBox
- Role: Ephemeral services & testing
- Networking: Host-Only + NAT
- Observations:
    - since I can't keep this node on permanently, which would result to slow performance on my macbook (which is my base machine), this node is used only for experimental purposes only
    - the specs of the VMs on this node is low due to the motive specified above

### Ubuntu Server 02:
```
Name: Ubuntu-Server-02
Operating System: Ubuntu 24.04.3 LTS (ARM 64-bit)
Base Memory: 2048 MB (2 GB)
Processors: 2
Boot Order: Hard Disk, Optical
Video Memory: 16 MB
Graphics Controller: VMSVGA
Storage Controller: VirtioSCSI
virtio-scsi Port 0: Ubuntu-Server-02.vdi (Normal, 25.00 GB)
virtio-scsi Port 1: [Optical Drive] 
Network Adapter: Intel PRO/1000 MT Desktop (82540EM)
```

### Ubuntu Server 03:
```
Name: Ubuntu-Server-03
Operating System: Ubuntu 24.04.3 LTS (ARM 64-bit)
Base Memory: 2048 MB
Processors: 2
Boot Order: Hard Disk, Optical
EFI: Enabled
Video Memory: 16 MB
Graphics Controller: VMSVGA
Controller: VirtioSCSI
virtio-scsi Port 0: Ubuntu-Server-03.vdi (Normal, 25.00 GB)
virtio-scsi Port 1: [Optical Drive] 
Network Adapter: Intel PRO/1000 MT Desktop (82540EM)
```

- I successfully set up and installed the two Ubuntu servers in the first node.

*[Date: 2026-01-04]*

**Network setup:**
I will be using two adapters for both `Ubuntu-Server-02` and `Ubuntu-Server-03`:
- Adapter 1: NAT for internet access and outbound connections
- Adapter 2: Host-only for private connections betweeen the local host and other VMs
Since Host-only Adapter is deprecated for newer versions of VirtualBox, I will be using Host-only Network for Adapter 2 which acts as a "virtual switch" managed by VirtualBox.
- I have crerated a local network
```
Name: vboxnet0
Mask: 255.255.255.0
Lower Bound: 192.168.56.1
Upper Bound: 192.168.56.199
```
- I attached both VMs 02 and 03 to this host-only network