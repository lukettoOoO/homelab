# Chapter 7: Linux Networking and System Resources

## 1. Networking Basics & IP Configuration

### Network Fundamentals
* **Client / Server Roles**: A server listens for incoming network requests; a client initiates outbound requests to a server. A single system can act as both client and server simultaneously.
* **TCP/IP Protocol Stack**:
  * **Transmission Control Protocol (TCP)**: Connection-oriented protocol responsible for segmenting data, verifying packet arrival, sending acknowledgments, and retransmitting lost packets.
  * **Internet Protocol (IP)**: Responsible for routing and transporting data packets across networks to destination IP addresses.

### IP Addressing & Resolution
* **DHCP (Dynamic Host Configuration Protocol)**: Automatically assigns IP addresses to devices on a network.
* **Local IP vs. Global IP**:
  * **Local IP**: Address used within a local network (subnet).
  * **Global / External IP**: Public IP address representing the gateway/router on the public internet.
* **Loopback Device (`lo`)**: Internal virtual interface (`127.0.0.1`) used for local host IPC and self-communication.

### Network Verification Utilities
* **`ip addr show`**: Displays network interface state, MAC addresses, and assigned IPv4 (`inet`) / IPv6 (`inet6`) addresses.
* **`curl ifconfig.me`**: Queries an external server to display the host's public global IP address.
* **`ping <host/IP>`**: Tests connectivity to a network host via ICMP echo requests (`-c <count>` specifies packet limit).

---

## 2. Remote Access & File Transfer

### Secure Shell (SSH)
* **SSH Protocol**: Encrypted network protocol for secure remote command-line login and administration, managed by the background daemon `sshd`.
* **Managing `sshd` Service**:
  * Enable and start service: `sudo systemctl enable --now sshd`
  * Check service status: `systemctl status sshd`
  * Check active state: `systemctl is-active sshd`
* **Connecting over SSH**: `ssh user@hostname_or_IP`

### Remote File Transfer (`scp`)
Copies files securely across network hosts over SSH:
* **Local to Remote**: `scp localfile.txt user@remotehost:/path/to/destination`
* **Remote to Local**: `scp user@remotehost:/path/to/remotefile.txt /local/destination`
* **Remote to Remote**: `scp user1@hostA:/file.txt user2@hostB:/destination`

### Passwordless SSH Key Authentication
SSH key pairs replace static passwords with asymmetric cryptography.

#### Key Pair Files
* **Private Key (`~/.ssh/id_ed25519`)**: Kept strictly secret on the client machine.
* **Public Key (`~/.ssh/id_ed25519.pub`)**: Shared and appended to remote servers (`~/.ssh/authorized_keys`).

#### Configuration Workflow
1. **Generate Key Pair**:  
   `ssh-keygen -t ed25519` (Generates ED25519 key pair in `~/.ssh/`).
2. **Deploy Public Key**:  
   `ssh-copy-id user@remotehost` (Copies public key to target server for passwordless authentication).

---

## 3. Viewing & Managing Linux Processes

### Process Fundamentals
* **Process**: An active running instance of a program, command, or service, assigned a unique numerical **Process ID (PID)**.
* **Daemon**: A background service managed by the system (e.g., `sshd`, `firewalld`).

### Graphical Process Monitoring (GNOME System Monitor)
* **Processes Tab**: View running tasks, CPU, memory, and PID details. Terminate frozen apps via **End Process**.
* **Resources Tab**: Real-time graphical metrics for CPU cores, RAM, and network interface activity.

### Command-Line Process Tools

#### 1. Interactive Process Viewer (`top`)
* Interactive task manager showing top CPU/RAM-consuming processes.
* **Key Bindings in `top`**:
  * `q`: Quit `top`.
  * `x`: Toggle bold formatting on sort column.
  * `<` / `>`: Change sorted column left or right.
  * `R`: Reverse sort order.
  * `L`: Search/locate process by name.
  * `k`: Prompt for PID and send signal (default `SIGTERM` 15) to kill process.

#### 2. Process Searching & Listing
* **`ps -ef`**: Displays snapshot of all running processes in full format (UID, PID, PPID, Start Time, TTY, Command).
* **`pgrep <process_name>`**: Searches active processes and outputs matching Process IDs (`pgrep -f gnome-calculator`).

#### 3. Terminating Processes (`kill`)
* **`kill <PID>`**: Sends termination signal (`SIGTERM`) to gracefully end a process by PID.
* **`kill -9 <PID>`**: Sends forceful kill signal (`SIGKILL`) to terminate un-responsive processes immediately.
