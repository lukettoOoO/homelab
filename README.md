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

*[Date: 2026-01-07]*

**Configuring Netowork for Ubuntu-Server-02 and Ubuntu-Server-03:**

I manually created a new YAML file in `/etc/netplan/` on both servers to initialize the network interfaces.

Netplan YAML file:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      dhcp4: true
    enp0s9:
      dhcp4: true
```
* `network:`: *This is the root node of the configuration; everything following it belongs to the network stack.*
* `version: 2`: *This specifies the Netplan YAML format version; version 2 is the standard for modern Ubuntu releases.*
* `renderer: networkd:` *This tells Ubuntu to use systemd-networkd as the backend engine to manage the interfaces. This is preferred for servers because it is lightweight and doesn't require a GUI.*
* `ethernets:`: *This section begins the definition of the physical or virtual network interfaces.*
* `enp0s8:`: *This is the name of my first virtual network card, which maps directly to Adapter 1 (NAT) in the VirtualBox settings.*
* `enp0s9:`: *This is the name of my second virtual network card, mapping to Adapter 2 (Host-only Network) connected to the vboxnet0 virtual switch.*
* `dhcp4:`: *true: This tells the server to automatically request an IPv4 address from a DHCP server. For enp0s8, this provides internet access (10.0.2.x), and for enp0s9, it provides the private lab connection (192.168.56.x).*

I used `sudo netplan apply` in order to apply the configurations.
I then used `ip a` in order to confirm that the interfaces are up and have assigned addresses.

*Ubuntu-Server-03:*
```
lo: inet 127.0.0.1/8
enp0s8: inet 10.0.2.15/25 (this is for NAT)
enp0s9: inet 192.168.56.3/24 (this is for private connections)
```

*Ubuntu-Server-02:*
```
lo: inet 127.0.0.1/8
enp0s8: inet 10.0.2.15/24 (this is for NAT)
enp0s9: inet 192.168.56.3/24 (this is for private connections)
```

I used `ping` command on my MacOS terminal to send some packets to the servers to confirm that everythinf is working correctly.
```
--- 192.168.56.2 ping statistics ---
10 packets transmitted, 10 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.409/0.769/2.094/0.507 ms

--- 192.168.56.3 ping statistics ---
8 packets transmitted, 8 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.359/0.501/0.854/0.142 ms
```