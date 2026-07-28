# Setting up a DHCP Server for HPE iLO

This repository details the procedure for setting up a dedicated DHCP server on a Linux machine to assign a fixed IP address to an HPE iLO (Integrated Lights-Out) interface (specifically HPE iLO 6).

---

## Relevant HPE iLO User Guide Topics

- **iLO**
  - iLO features
- **Setting up iLO**
  - Preparing to set up iLO
    - iLO network connection options
    - iLO IP address acquisition
    - iLO configuration tools
  - Initial setup steps
  - Connecting iLO to the network
  - iLO setup with the web interface
  - Logging in to iLO for the first time
  - iLO default DNS name and user account
- **Using the iLO web interface**
  - Logging in to the iLO web interface
  - iLO web interface overview
- **Configuring iLO network settings**
  - Viewing the network configuration summary
    - Network information summary
    - IPv4 Summary details
  - General network settings
  - Configuring IPv4 settings

---

## Architecture & Topology

According to the HPE iLO User Guide, iLO is connected via a **Dedicated Management Network**, keeping management traffic isolated from the Production Network:

```
                      +----------------------+
                      |  Management Clients  |
                      +----------+-----------+
                                 |
                        Management Network
                                 |
            +--------------------+--------------------+
            |                                         |
   +--------+---------+                      +--------+---------+
   | Linux DHCP Server|                      |    HPE Server   |
   |   (Static IP)    |                      |  iLO Dedicated   |
   +------------------+                      |       NIC       |
                                             +--------+--------+
                                                      |
                                              Production Network
                                                      |
                                            +---------+--------+
                                            |Production Clients|
                                            +------------------+
```

The Linux machine running the DHCP server must be in the same network/VLAN as the HPE iLO port so that DHCP broadcast messages (`DHCPDISCOVER`) are received directly.

---

## Step 1: Configure Static IP on the Linux Host

The Linux DHCP host must have a static IP address configured on the network interface connected to the Management Network.

1. **Identify the network interface:**
   ```bash
   ip a
   ```
   Locate the interface connected to the management network (state `UP`).

2. **Configure Static IP using `NetworkManager` (`nmcli`):**
   *(Do not use temporary commands like `ip addr add` as they do not persist across reboots.)*

   - **Install `NetworkManager` and `iproute2` (if missing):**
     - Debian/Ubuntu:
       ```bash
       sudo apt update && sudo apt install -y network-manager iproute2
       ```
     - RHEL/Fedora/Rocky Linux:
       ```bash
       sudo dnf install -y NetworkManager iproute
       ```

   - **Set static IP and subnet mask:**
     ```bash
     sudo nmcli con mod <interface_name> ipv4.addresses <IP_ADDRESS>/<CIDR_MASK>
     ```

   - **Set gateway (if required):**
     ```bash
     sudo nmcli con mod <interface_name> ipv4.gateway <GATEWAY_IP>
     ```

   - **Set IPv4 method to manual (prevents obtaining a dynamic IP):**
     ```bash
     sudo nmcli connection modify <interface_name> ipv4.method manual
     ```

   - **Apply changes:**
     ```bash
     sudo nmcli con up <interface_name>
     ```

   - **Verify configuration:**
     ```bash
     ip a
     ```

---

## Step 2: Install and Configure the DHCP Server

For lightweight deployment, **ISC DHCP Server (`dhcpd`)** is used.

1. **Install ISC DHCP Server:**
   - Debian/Ubuntu:
     ```bash
     sudo apt install -y isc-dhcp-server
     ```
   - RHEL/Fedora/Rocky Linux:
     ```bash
     sudo dnf install -y dhcp-server
     ```

2. **Edit the configuration file:**
   Open `/etc/dhcp/dhcpd.conf`:
   ```bash
   sudo nano /etc/dhcp/dhcpd.conf
   ```

### HPE iLO 6 DHCP Client Identifier Requirement

> [!IMPORTANT]
> **Client Identifier Format for iLO 6:**
> To create a static reservation in a DHCP server for HPE iLO 6, a specific **DHCP Client Identifier** is required.
> The identifier consists of the **hardware MAC address followed by three bytes (six hex zeroes)**.
> 
> *Example:* If the iLO MAC address is `00:53:00:AA:BB:CC`, the DHCP Client Identifier format is:
> `005300AABBCC000000` (or formatted in bytes `00:53:00:aa:bb:cc:00:00:00`).

### DHCP Options Expected by iLO

HPE iLO expects the DHCP server to provide the following configuration parameters:
- **Gateway** (`option routers`)
- **IPv4 Address** (`fixed-address`)
- **Subnet Mask** (`netmask`)
- **DNS Server** (`option domain-name-servers`)
- **Domain Name** (`option domain-name`)
- **WINS Server** (`option netbios-name-servers` - legacy/deprecated Windows DNS alternative)
- **NTP Servers** (`option ntp-servers` - synchronizes iLO internal clock)

### DHCP Configuration Template & Example

#### Template Structure

```etc
subnet <subnet_address> netmask <subnet_netmask> {
    option routers <gateway_ip>;
    option domain-name-servers <dns_address>;
    option domain-name <domain_name>;
    option netbios-name-servers <wins_address>;
    option ntp-servers <ntp_address>;

    range <start_ip_address> <end_ip_address>;
}

host <host_name> {
    option dhcp-client-identifier <client_identifier>;
    fixed-address <client_ip_address>;
}
```

**Field Breakdown:**
- `subnet ... netmask ...`: Defines the network subnet range for IP allocation.
- `option routers`, `option domain-name-servers`: Specifies default gateway and DNS server addresses sent to the client.
- `range`: Defines dynamic allocation pool. *(Required to activate subnet allocation even when using static reservations.)*
- `host <host_name> { ... }`: Reservation block for assigning a fixed IP to HPE iLO.
- `option dhcp-client-identifier`: The required unique client identifier (MAC + 6 zeros for iLO 6).
- `fixed-address`: The dedicated static IP address reserved exclusively for the specified iLO device.

#### Concrete Example Configuration

```etc
subnet 10.0.0.0 netmask 255.255.255.0 {
    option routers 10.0.0.1;
    option domain-name-servers 8.8.8.8;
    option domain-name "example.local";
    option netbios-name-servers 10.0.0.10;
    option ntp-servers 10.0.0.11;

    range 10.0.0.100 10.0.0.150;
}

host iLO-Server {
    option dhcp-client-identifier 00:53:00:aa:bb:cc:00:00:00;
    fixed-address 10.0.0.51;
}
```

### Starting and Verifying the DHCP Service

1. **Check configuration syntax:**
   ```bash
   sudo dhcpd -t
   ```

2. **Configure listening interface (Debian/Ubuntu):**
   Edit `/etc/default/isc-dhcp-server` and specify the network interface connected to the iLO subnet:
   ```etc
   INTERFACESv4="<interface_name>"
   ```

3. **Start the DHCP service:**
   ```bash
   sudo systemctl start isc-dhcp-server
   # or on RHEL/CentOS:
   sudo systemctl start dhcpd
   ```

4. **Verify service status:**
   ```bash
   sudo systemctl status isc-dhcp-server
   ```

---

## Step 3: DHCP Exchange (DORA) and Server Startup

### Physical Cabling and Power-On Sequence

1. **Cabling:** Ensure the network cable is securely connected from the HPE server's dedicated iLO port to the management network switch **before** connecting power to the server.
2. **Power Supply:** Plug the HPE server into the power source.
   > [!NOTE]
   > You **do not** need to press the server power button for iLO to start. iLO operates on standby power and initializes automatically as soon as the server receives main power.

### DORA Workflow

1. **DISCOVER:** Upon powering up, iLO broadcasts a `DHCPDISCOVER` packet containing its Client Identifier. If no response is received, iLO re-transmits a Discover request every 90 seconds.
2. **OFFER:** The DHCP server receives the `DHCPDISCOVER`, parses `/etc/dhcp/dhcpd.conf`, matches the `dhcp-client-identifier`, and returns a `DHCPOFFER` with the `fixed-address`, gateway, DNS, and NTP details.
3. **REQUEST:** iLO accepts the offered configuration and returns a `DHCPREQUEST` back to the DHCP server.
4. **ACKNOWLEDGE:** The DHCP server sends a `DHCPACK` packet, completing the lease assignment.

### Log Verification

To monitor DHCP server activity in real time, inspect `journalctl`:

```bash
sudo journalctl -u isc-dhcp-server -f
```

**Example Log Output:**

```log
Jul 26 14:02:09 debian-eos dhcpd[843085]: DHCPDISCOVER from 8e:7d:71:8d:b9:28 via veth-srv
Jul 26 14:02:09 debian-eos dhcpd[843085]: DHCPOFFER on 10.0.0.51 to 8e:7d:71:8d:b9:28 via veth-srv
Jul 26 14:02:09 debian-eos dhcpd[843085]: DHCPREQUEST for 10.0.0.51 (10.0.0.1) from 8e:7d:71:8d:b9:28 via veth-srv
Jul 26 14:02:09 debian-eos dhcpd[843085]: DHCPACK on 10.0.0.51 to 8e:7d:71:8d:b9:28 via veth-srv
```

---

## Step 4: Authenticating to the iLO Web Interface

1. **Access Web UI:**
   Open a web browser and navigate to:
   ```
   https://<iLO_IP_address>
   ```
   *(e.g., `https://10.0.0.51`)*

2. **Log in with Factory Credentials:**
   - **Username:** `Administrator`
   - **Password:** Found on the physical serial label pull-tab on the front panel of the HPE server (random 8-character string).

---

## Repository Files & Local Testing

This directory contains configuration files and a test script to simulate and test the DHCP server setup locally using virtual Ethernet (`veth`) interfaces:

| File | Description |
| :--- | :--- |
| [dhcpd.conf](file:///Users/luca/Documents/projects/homelab/Node-01/networking/dhcp-server-for-ilo/dhcpd.conf) | Sample ISC DHCP server configuration file defining the subnet and iLO reservation block. |
| [dhclient.conf](file:///Users/luca/Documents/projects/homelab/Node-01/networking/dhcp-server-for-ilo/dhclient.conf) | Sample DHCP client config configured with `send dhcp-client-identifier 00:53:00:aa:bb:cc:00:00:00;` to simulate an iLO 6 client request. |
| [isc-dhcp-server](file:///Users/luca/Documents/projects/homelab/Node-01/networking/dhcp-server-for-ilo/isc-dhcp-server) | Service configuration file setting `INTERFACESv4="veth-srv"`. |
| [test_dhcp.sh](file:///Users/luca/Documents/projects/homelab/Node-01/networking/dhcp-server-for-ilo/test_dhcp.sh) | Test script that restarts `isc-dhcp-server`, triggers `dhclient` on `veth-cli`, and checks assigned IP & logs. |
