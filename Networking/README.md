# Networking Configuration

**[Date: 27-08-2026]**

- I have decided on an Isolated Island architecture for the networking configuration of my homelab:
```
[ Primary Home Router (192.168.1.x) ]
                 │
                 ▼ (Ethernet into ether1 / WAN)
  [ MikroTik hEX S (Gateway: 10.0.0.1) ]
                 │ (ether2)
                 ▼ (Uplink to Port 1)
 [ TP-Link TL-SG108E Switch (10.0.0.2) ]
   ├── Port 2: Node 01 - ASUS Laptop Eos (10.0.0.10)
   ├── Port 3: Node 02 - HP Proxmox Dionysus (10.0.0.20)
   ├── Port 4: MacBook / Management Workstation (DHCP)
   └── Ports 5–8: Expansion / Spare
```

| Device | Interface / Role | IP Address | MAC / Notes |
|---|---|---|---|
| **MikroTik hEX S** | `bridge-homelab` (Gateway) | `10.0.0.1/24` | Default DNS & DHCP Gateway |
| **TP-Link Switch** | Management Web UI | `10.0.0.2/24` | Static management IP |
| **Node 01 (Eos)** | `enp2s0f1` (Realtek Gigabit) | `10.0.0.10/24` | Nextcloud, GitLab, NPM, Netdata |
| **Node 02 (Proxmox)** | `vmbr0` on `eno1` (Intel i219LM) | `10.0.0.20/24` | Hypervisor Web UI (`:8006`) |
| **Windows VM (100)** | Virtual NIC (VirtIO) | `10.0.0.30/24` | RDP (`:3389`), SSH (`:22`) |
| **DHCP Pool** | MacBook & temporary devices | `10.0.0.100` - `10.0.0.200` | Dynamic pool |
| **Future VMs / Nodes** | Reserved for expansion | `TBD` | Additional VMs and nodes may be added as the homelab grows |



### Equipment and Service Access

| Equipment / Service | Domain / Access URL | Internal Destination (IP:Port) | Access Type / Protocol |
|---|---|---|---|
| **MikroTik hEX S** | [http://10.0.0.1](http://10.0.0.1) | `10.0.0.1:80` | WebFig (HTTP), WinBox (`8291`), SSH (`22`) |
| **TP-Link TL-SG108E** | [http://10.0.0.2](http://10.0.0.2) | `10.0.0.2:80` | Web GUI (HTTP) |
| **Node 01 (Debian Eos)** | - | `10.0.0.10:22` | SSH CLI |
| **Olympus Dashboard** | [https://home.olympus-luca.online](https://home.olympus-luca.online) | [http://10.0.0.10:8000](http://10.0.0.10:8000) | HTTPS (Reverse Proxy / Docker) |
| **Nextcloud** | [https://nc.olympus-luca.online](https://nc.olympus-luca.online) | `10.0.0.10:11000` | HTTPS (Cloudflare Tunnel) |
| **Nextcloud AIO Panel** | [https://nc-aio.home.olympus-luca.online](https://nc-aio.home.olympus-luca.online) | `https://10.0.0.10:8080` | HTTPS (Reverse Proxy / Docker) |
| **GitLab Server** | [https://gitlab.home.olympus-luca.online](https://gitlab.home.olympus-luca.online) | `http://10.0.0.10:8085` | HTTPS (Reverse Proxy / Docker) |
| **Netdata Monitoring** | [https://nd.home.olympus-luca.online](https://nd.home.olympus-luca.online) | `http://10.0.0.10:19999` | HTTPS (Reverse Proxy / Docker) |
| **Nginx Proxy Manager** | [https://npm.home.olympus-luca.online](https://npm.home.olympus-luca.online) | `http://10.0.0.10:81` | HTTPS (Reverse Proxy / Docker) |
| **Node 02 (Proxmox Dionysus)** | [https://10.0.0.20:8006](https://10.0.0.20:8006) | `10.0.0.20:8006` | PVE Web GUI (HTTPS), SSH (`22`) |
| **VM 100 (Windows Server 2022)** | - | `10.0.0.30:3389` | Remote Desktop (RDP) |
| **VM 100 OpenSSH** | - | `10.0.0.30:22` | SSH CLI (`Administrator@10.0.0.30`) |
| **Tailscale Subnet Router** | Subnet route `10.0.0.0/24` | `100.80.227.117` -> `10.0.0.10` | WireGuard / Tailnet VPN |

- Network equipment details:

### TP-Link TL-SG108E Switch

| Specification | Details |
|---|---|
| Switch type | 8-port Easy Smart Gigabit switch |
| Ethernet ports | 8 × 10/100/1000 Mbps RJ45 |
| Switching capacity | 16 Gbps |
| Forwarding rate | 11.9 Mpps |
| MAC address table | 4K entries |
| Jumbo frames | Up to 16 KB |
| Management | Web-based management and Easy Smart Configuration Utility |
| VLAN | 802.1Q tag-based, port-based, and MTU VLAN |
| Quality of service | 802.1p/DSCP priority queues |
| Other features | IGMP Snooping, loop prevention, cable diagnostics, port mirroring, port statistics |
| Standards | IEEE 802.3, 802.3u, 802.3ab, 802.3x, 802.1p, 802.1q |
| Dimensions | 158 × 101 × 25 mm |
| Cooling | Fanless |
| Power supply | External 5 V DC adapter |
| Maximum power consumption | 3.7 W |

Source: [TP-Link TL-SG108E product page](https://www.tp-link.com/us/business-networking/easy-smart-switch/tl-sg108e/)

### MikroTik hEX S

| Specification | Details |
|---|---|
| Product code | RB760iGS |
| Device type | 5-port Gigabit Ethernet router |
| Ethernet ports | 5 × 10/100/1000 Mbps |
| SFP | 1 × SFP cage, up to 1.25 Gbps |
| CPU | MediaTek MT7621A, dual-core, 880 MHz |
| RAM | 256 MB |
| Storage | 16 MB flash; 1 × microSD slot |
| Operating system | RouterOS, Level 4 license |
| PoE input | 802.3af/at, 12–57 V |
| PoE output | Passive PoE on ether5, up to 57 V, 500 mA |
| USB | 1 × USB Type-A, USB 2.0 |
| Power inputs | DC jack and PoE-in |
| Maximum power consumption | 24 W; 6 W without attachments |
| Cooling | Passive |
| Dimensions | 113 × 89 × 28 mm |
| Operating temperature | -40 °C to 70 °C |

Source: [MikroTik hEX S product page](https://mikrotik.com/product/hex_s)

## The Setup

### Physical Cabling

- Powering off server nodes before connecting the cables
- Connecting an Ethernet cable from a LAN port on my **main home router (`192.168.1.x`)** to **`ether1` (WAN)** on the MikroTik hEX S (this cable was previously connected directly to Node 02)
- Connecting an Ethernet vable from **`ether2`** on the MikroTik to Port 1 of the TP-Link switch
- Connecting **Node 01's internal Gigabit LAN port (`enp2s0f1`)** to **Port 2** on the switch
- Connecting **Node 02's bulit-in Gigabit LAN port (`eno1`)** to **Port 3** on the switch
- Connecting my **MacBook** directly to **`ether3`** on the MikroTik for setup

### Configuring the MikroTik hEX S (RouterOS v7)

- Navigating to `http://192.168.88.1` to access the RouterOS terminal (docs: https://help.mikrotik.com/docs/spaces/ROS/pages/328134/Command+Line+Interface) in the web browser on Mac, clicking **Safe Mode** in the top right and executing the following commands in the terminal:
    - Creating a unified LAN bridge:
    ```
    /interface bridge add name=bridge-olympus
    ```
    - Declaring the new bridge in the LAN list to prevent firewall blocking (this router blocks any bridges besides the default `bridge` by default)
    ```
    /interface list member add interface=bridge-olympus list=LAN
    ```
    - Configuring the gateway IP address:
    ```
    /ip address add address=10.0.0.1/24 interface=bridge-olympus network=10.0.0.0
    ```
    - Configuring DHCP:
    ```
    /ip pool add name=pool-olympus ranges=10.0.0.100-10.0.0.200
    /ip dhcp-server add name=dhcp-olympus interface=bridge-olympus address-pool=pool-olympus disabled=no lease-time=12h
    /ip dhcp-server network add address=10.0.0.0/24 gateway=10.0.0.1 dns-server=10.0.0.1,1.1.1.1
    ```
    - Moving the already existing default bridge ports into my custom LAN bridge;
    ```
    /interface bridge port
    set [find interface=ether2] bridge=bridge-olympus
    # after this command it logged me out of my session and had to connect to the new IP http://10.0.0.1 and renew the DHCP lease on my Mac
    # running the following commands after accessing the console again:
    /interface bridge port
    set [find interface=ether3] bridge=bridge-olympus
    set [find interface=ether4] bridge=bridge-olympus
    set [find interface=ether5] bridge=bridge-olympus
    ```
- Got logged out of my configuration session; after unplugging and plugging back again the Ethernet cable back into the MacBook, I successfully got an IP from the set DHCP pool: `10.0.0.200`
- Now I'm accessing the configuration session again through the new gateway IP set for the router: `http://10.0.0.1`
- To finish the configuration, I'm using the following commands to setup the Internet, DNS and firewall:
    - Deleting old default `bridge` and DHCP for `192.168.88.x`
    ```
    /interface bridge port remove [find bridge=bridge]
    /ip dhcp-server network remove  [find gateway=192.168.88.1]
    /ip dhcp-server remove [find name=defconf]
    /ip pool remove [find name=default-dhcp]
    /ip address remove [find address="192.168.88.1/24"]
    /interface bridge remove [find name=bridge]
    ```
    - Activating WAN on `ether1` and NAT for Internet:
    ```
    /ip dhcp-client add interface=ether1 disabled=no comment="WAN uplink"
    # translate private homelab addresses so devices can access the Internet through ether1
    /ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade comment="olympus NAT outbound"
    ```
    - Activating DNS caching and wildcard DNS for `*.olympus-luca.online` to node `.10`
    ```
    /ip dns set allow-remote-requests=yes servers=1.1.1.1,8.8.8.8
    /ip dns static add name=olympus-luca.online match-subdomain=yes address=10.0.0.10
    ```
    - Isolating the homelab from the parent network (`192.168.1.0/24`)
    ```
    # any 10.0.0.x endpoint cannot access any endpoint 192.168.1.x
    /ip firewall filter add action=drop chain=forward in-interface=bridge-olympus dst-address=192.168.1.0/24 comment="drop homelab to parent LAN" place-before=[find comment~"defconf: drop all from WAN"]
    # any incoming connections from home router cannot access ether1 interface
    /ip firewall filter add action=drop chain=input in-interface=ether1 comment="drop incoming from home router"
    # blocks WAN traffic which tries to access homelab endpoints
    /ip firewall filter add action=drop chain=forward in-interface=ether1 comment="drop unsolicited from home router"
    ```
- Testing if router can reach cloudflare DNS:
```bash
[admin@MikroTik] /interface/bridge/port> /ping 1.1.1.1 count=3 
SEQ HOST                                     SIZE TTL TIME       STATUS                                                                                                          
0 1.1.1.1                                    56  57 13ms507us 
1 1.1.1.1                                    56  57 13ms760us 
2 1.1.1.1                                    56  57 13ms278us 
sent=3 received=3 packet-loss=0% min-rtt=13ms278us avg-rtt=13ms515us max-rtt=13ms760us 
```
- Success!

### TP-Link TL-SG108E Switch Configuration
- Navigating to the factory IP address of the switch won't work because the router already assigned an IP address for the switch through its DHCP settings (it was connected to the switch all this time)
- Finding out the IP address of the switch:
```bash
[admin@MikroTik] > /ip dhcp-server lease print 
Flags: D - DYNAMIC
Columns: ADDRESS, MAC-ADDRESS, HOST-NAME, SERVER, STATUS, LAST-SEEN
#   ADDRESS     MAC-ADDRESS        HOST-NAME   SERVER        STATUS  LAST-SEEN
0 D 10.0.0.101  AC:A7:F1:36:3D:99  TL-SG108E   dhcp-olympus  bound   1h37m34s 
1 D 10.0.0.100  C8:4D:44:28:BC:43  Air---Luca  dhcp-olympus  bound   24s
```
- We can see that based on the hostname `TL-SG108E`, `10.0.0.101` is the IP address of the switch
- Navigating to `http://10.0.0.101` and logging in with the default credentials `admin` / `admin`
- I'm applying the following settings to the switch:
    - Disabling DHCP
    - Setting the IP address to `10.0.0.2` along with `255.255.255.0`
    - Setting the gateway address to `10.0.0.1` (the router)

### Configuring Node 01 to Gigabit Ethernet
See [Node 01 README - Migrating Node 01 to Gigabit Ethernet](../Node-01/README.md#migrating-node-01-to-gigabit-ethernet).

### Configuring Node 02 to Gigabit Ethernet
See [Node 02 README - Migrating Node 02](../Node-02/README.md#migrating-node-02).

- Now I have a successful ping for the devices above:
```bash
luca@MacBook-Air---Luca [19:20:03] [~] 
-> % # 1. Gateway MikroTik
ping -c 2 10.0.0.1

# 2. Switch TP-Link
ping -c 2 10.0.0.2

# 3. Node 01 (Debian Eos)
ping -c 2 10.0.0.10

# 4. Node 02 (Proxmox)
ping -c 2 10.0.0.20
PING 10.0.0.1 (10.0.0.1): 56 data bytes
64 bytes from 10.0.0.1: icmp_seq=0 ttl=64 time=1.544 ms
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=2.724 ms

--- 10.0.0.1 ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 1.544/2.134/2.724/0.590 ms
PING 10.0.0.2 (10.0.0.2): 56 data bytes
64 bytes from 10.0.0.2: icmp_seq=0 ttl=64 time=4.838 ms
64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=3.960 ms

--- 10.0.0.2 ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 3.960/4.399/4.838/0.439 ms
PING 10.0.0.10 (10.0.0.10): 56 data bytes
64 bytes from 10.0.0.10: icmp_seq=0 ttl=64 time=2.201 ms
64 bytes from 10.0.0.10: icmp_seq=1 ttl=64 time=2.798 ms

--- 10.0.0.10 ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 2.201/2.500/2.798/0.298 ms
PING 10.0.0.20 (10.0.0.20): 56 data bytes
64 bytes from 10.0.0.20: icmp_seq=0 ttl=64 time=3.389 ms
64 bytes from 10.0.0.20: icmp_seq=1 ttl=64 time=3.542 ms

--- 10.0.0.20 ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 3.389/3.465/3.542/0.077 ms
```

### Configuring Windows Server 2022 VM (Node 02) to Gigabit Ethernet
- See [Node 02 README - Migrating Windows Server 2022 VM to the new network](../Node-02/README.md#migrating-windows-server-2022-vm-to-the-new-network).

### Updating Nginx Proxy Manager (Node 01)
- See [Node 01 README - Migrating Nginx Proxy Manager to new network](../Node-01/README.md#migrating-nginx-proxy-manager-to-new-network).

### Configuring Tailscale Subnet Router (Node 01)
- See [Node 01 README - Migrating Tailscale to new network settings and setting up Tailscale Subnet Router](../Node-01/README.md#migrating-tailscale-to-new-network-settings-and-setting-up-tailscale-subnet-router-for-network-10000).

## Cloudflare Tunnel for Nextcloud access

See [Node 01 README - Cloudflare Tunnel for Nextcloud access](../Node-01/README.md#cloudflare-tunnel-for-nextcloud-access) for the complete setup log.

Only `https://nc.olympus-luca.online` is publicly reachable. No ports were opened on the home router or MikroTik; all other homelab services remain private.





