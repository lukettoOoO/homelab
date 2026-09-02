*This is the first device that I'm adding to my homelab setup, it will run a Debian 13 server permanently on.*

**Date: 2026-02-20**

## 💻 Node 01 (Eos): ASUS laptop

### Installing Debian 13 on ASUS laptop

- Downloaded Debian 13 ISO file  
- Created Debian 13 bootable USB medium  

---

**Date: 2026-02-21**

- Installing Debian 13  
- Chose LVM instead of standard partitioning for more flexible resizing; split SSD/HDD using LVM to maximize OS performance and data access  
[How LVM works](https://www.youtube.com/watch?v=dMHFArkANP8)

### Physical disks:

- SSD (240.1 GB): Kingston SA400S3 (sdb) for the system  
- HDD (750.2 GB): ST750LM022 HN-M7 (sda) for storage  

Boot partition:  
510.7 MB EFI System Partition (ESP) on the SSD (booting from SSD ensures fast access to system files)

### LVM Configuration:

- `vg_system` (SSD) contains `lv_root` (50 GB at `/` for OS) and `lv_swap` (4GB for swap memory)  
- `vg_data` (HDD): contains `lv_storage` (750.2GB at `/srv` where data used by server services is stored)

---

- Installed and ran inxi for system specs:

## Node Overview

| Component | Specification |
|-----------|--------------|
| Hostname  | debian-eos |
| Hardware  | ASUS X550LB (~2013) - repurposed laptop server |
| CPU       | Intel Core i3-4010U (2C/4T, Haswell) |
| RAM       | 8GB (7.64GB usable) |
| Storage   | 240GB Kingston SSD (OS) + 750GB Samsung HDD (data) |
| Network   | Realtek Gigabit LAN + Atheros AR9485 Wi-Fi |
| GPU       | Intel HD 4400 (NVIDIA GT 740M disabled) |
| Battery   | 48% health (~30-60 min backup) |
| OS        | Debian 13 (Trixie) |
| Kernel    | 6.12.73+deb13-amd64 |

---

- Turining the laptop into a headless server so it doesn't go on sleep when the lid is closed: had to modify power consumption settings in the laptop BIOS and also ran the following command to basically take the unit file for these services and replace them with a symbolic link to `/dev/null` (the OS won't even know how to respond to sleep, suspend or hibernate since they are "set to null"):

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target
```

- Used `ip a` to find IP address  
- Successful ping from personal Macbook to Debian server  

```bash
-> % ping 192.168.1.197   

PING 192.168.1.197 (192.168.1.197): 56 data bytes
64 bytes from 192.168.1.197: icmp_seq=0 ttl=64 time=6.531 ms
64 bytes from 192.168.1.197: icmp_seq=1 ttl=64 time=37.524 ms
64 bytes from 192.168.1.197: icmp_seq=2 ttl=64 time=80.208 ms
^C
--- 192.168.1.197 ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 6.531/41.421/80.208/30.204 ms
```

[How Secure Shell Works](https://www.youtube.com/watch?v=ORcvSkgdA58)

- Set up SSH: `ssh luca@192.168.1.197`  

- Creating a secure key pair:

```bash
ssh-keygen
ssh-copy-id luca@192.168.1.197
```

---

**Date: 2026-02-22**

### Setting up the Firewall

[Firewall](https://www.youtube.com/watch?v=kDEX1HXybrU)

- Installed UFW  
- Allowing SSH connections through the firewall (opened port 22):  
  `sudo ufw allow ssh`  
- Turning firewall on:  
  `sudo ufw enable`  

- Current firewall status:

```bash
root@debian-eos:/home/luca# sudo ufw status
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere                  
22/tcp (v6)                ALLOW       Anywhere (v6)
```

**Date: 2026-02-23**
### Setting up static IP address
- Instead of using `arp -a` on my laptop everytime to find the server, I decided to assign a static IP address to the server by modifying the IP of the network interface in the Debian network configuration in `/etc/network/interfaces`; before, DHCP was used which would assign a different IP every time

### Installing Docker
- Installed Docker using the guide on their website nad ran hello-world image `sudo docker run hello-world`
- After running `sudo systemctl status docker`
```bash
● docker.service - Docker Application Container Engine
     Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-02-23 15:11:28 EET; 13s ago
 Invocation: 9cdb1111ddc741adbb396528e91cc1b9
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 1580 (dockerd)
      Tasks: 10
     Memory: 28.4M (peak: 30.2M)
        CPU: 546ms
     CGroup: /system.slice/docker.service
             └─1580 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

Feb 23 15:11:27 debian-eos dockerd[1580]: time="2026-02-23T15:11:27.727268945+02:00" level=info msg="Restoring containe>
Feb 23 15:11:27 debian-eos dockerd[1580]: time="2026-02-23T15:11:27.783249780+02:00" level=info msg="Deleting nftables >
Feb 23 15:11:27 debian-eos dockerd[1580]: time="2026-02-23T15:11:27.807163428+02:00" level=info msg="Deleting nftables >
Feb 23 15:11:28 debian-eos dockerd[1580]: time="2026-02-23T15:11:28.368189301+02:00" level=info msg="Loading containers>
Feb 23 15:11:28 debian-eos dockerd[1580]: time="2026-02-23T15:11:28.380663396+02:00" level=info msg="Docker daemon" com>
Feb 23 15:11:28 debian-eos dockerd[1580]: time="2026-02-23T15:11:28.380824638+02:00" level=info msg="Initializing build>
Feb 23 15:11:28 debian-eos dockerd[1580]: time="2026-02-23T15:11:28.400544066+02:00" level=info msg="Completed buildkit>
Feb 23 15:11:28 debian-eos dockerd[1580]: time="2026-02-23T15:11:28.407096319+02:00" level=info msg="Daemon has complet>
Feb 23 15:11:28 debian-eos dockerd[1580]: time="2026-02-23T15:11:28.407231071+02:00" level=info msg="API listen on /run>
Feb 23 15:11:28 debian-eos systemd[1]: Started docker.service - Docker Application Container Engine.
```
- Found on [Reddit](https://www.reddit.com/r/selfhosted/comments/15f7ju5/docker_and_ufw_firewall/) that Docker bypasses UFW by default; it modifies iptables directly, no matter what rule is set through UFW
- Installed ad configured `ufw-docker` to intercept Docker's traffic and force it to respect UFW rules (https://github.com/chaifeng/ufw-docker)
- For future use:
```bash
# Allow a container port:
sudo ufw-docker allow [container_name] [port]
# Allow from specific IP:
sudo ufw-docker allow [container_name] [port]/tcp [IP_address]
# Check firewall status:
sudo ufw-docker status
```

**Date: 2026-02-24**
### Installing Tailscale
- Found this solution to be able to access my server remotely, outside of my local network
https://www.youtube.com/watch?v=unzPvCe9Y8Q
- In the future I'll buy a router to create my own VPN so this is just a temporary solution

### Getting started with docker
- Created a Dockerfile to build an example image from Docker website
- Started the container and saw the running app
- Learned how to update and rebuild an image, as well as stop and remove a container
- Learned how to push images
- Learned how to persist data using volume mounts and bind mounts
- Learned a little bit about container networking and service discovery using DNS
- Learned to use Docker Compose
- Learned about Docker Compose

**Date: 2026-02-28**

### Relocating Docker volumes, security imptovements and setting up Netdata
- Docker creates all its volumes on the SSD (50GB) but I want it to use the HDD (750GB) as storage
```bash
docker ps
sudo docker ps
sudo docker stop 932c8f8d3020
sudo docker stop 8cdcb8b40304
docker ps
sudo docker ps
sudo systemctl stop docker
sudo systemctl stop docker.socket
cd srv
ls
cd docker/
sudo mkdir docker-data
sudo rsync -aP /var/lib/docker /srv/docker-data/
sudo apt update
sudo apt install rsync
rsync --version
sudo rsync -aP /var/lib/docker /srv/docker-data/
sudo nano /etc/docker/daemon.json
```
- Inside this `.json` file
````json
{
  "data-root": "/srv/docker-data"
}
````
```bash
sudo systemctl start docker
sudo docker info | grep "Docker Root Dir"
sudo rm -rf /var/lib/docker
```

**Installing automatic security updates**
- This will automatically install security upgrades for all installed apt packages once a day
```bash
apt install unattended-upgrades
dpkg-reconfigure unattended-upgrades
```

**Checking open ports with running programs**
- Find the services using netstat
```bash
netstat -tulpen
```
- Stop and disable unwanted services
```bash
systemctl stop [SERVICENAME]
systemctl disable [SERVICENAME]
```
- Solutions found at: https://www.linux.org/threads/the-ultimate-guide-to-reasonable-security-for-your-debian-ubuntu-linux-server-for-new-linux-admins.49199/

**Installing Netdata**
https://github.com/netdata/netdata
- Locally stored server metrics
- Free and open-source
- Uses machine learning to detect anomalies
- I will intaall Netdata directly on my system and not run a Docker container for it since I want it to fully access the metrics of my system and not the virtual environment where it runs in Docker
```bash
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh --nightly-channel
systemctl status netdata
sudo systemctl start netdata
sudo systemctl enable netdata
sudo ufw allow 19999/tcp
sudo ufw status
```
### Installing Nextcloud
- I want a service that helps with system backups but also to help me store my own files in a local cloud storage
- The scope is to be also used by my family
- I will use Nextcloud AIO
- `.yml` file for docker compose
```yml
name: nextcloud-aio
services:
  nextcloud-aio-mastercontainer:
    image: ghcr.io/nextcloud-releases/all-in-one:latest
    init: true
    restart: always
    container_name: nextcloud-aio-mastercontainer
    volumes:
      - nextcloud_aio_mastercontainer:/mnt/docker-aio-config
      - /var/run/docker.sock:/var/run/docker.sock:ro
    network_mode: bridge
    ports:
      - 8080:8080
    environment:
      NEXTCLOUD_DATADIR: /srv/docker/nextcloud/ncdata
      APACHE_PORT: 11000

volumes:
  nextcloud_aio_mastercontainer:
    name: nextcloud_aio_mastercontainer
```
- In the future I will be using a custom domain, that's why I've set `APACHE_PORT: 11000`
- I set up the following directory structure:
```
 nextcloud
    ├── compose.yml
    └── ncdata
```
- Using `ncdata` for host directory where all files uploaded to NextCloud will be stored
- Running `docker-compose up -d` to start everything up

### Setting up NGINX
https://www.youtube.com/watch?v=9t9Mp0BGnyI&t=791s
- For starters, I want to host a simple html that displays "Hello world!"
- Creating directory structure:
```bash
sudo mkdir -p /srv/docker/nginx-tutorial/mysite
cd /srv/docker/nginx-tutorial
sudo touch nginx.conf docker-compose.yml
```
- Setting up `docker-compose.yml` file to map port 8000 and mount the local files into the container
```YAML
name: nginx-tutorial
services:
  nginx:
    image: nginx:latest
    container_name: nginx-tutorial
    ports:
      - "8000:8000"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./mysite:/usr/share/nginx/html
```

- Added a basic configuration to `nginx.conf`
```Nginx
events {}

http {
    include       mime.types;

    server {
        listen       8000;
        server_name  localhost;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }
    }
}
```
- Created a test `index.html` inside the `mysite` folder:
```HTML
<h1>Hello World!</h1>
```
- Started the container and successfully accessed the test page from my personal Macbook browser by navigating to `http://192.168.1.197:8000`

**Setting up a simple homelab dasboard page with NGINX**
- Decided to create a global homelab dashboard to act as a hub for this node and future nodes that will be added
- For now, its main purpose is to access the main services provided by the servers
- In the future, for easier access, I plan on using PiHole to create a custom domain name for this website
- Directory structure:
```bash
dashboard
├── docker-compose.yml
├── html
│   └── index.html
└── nginx.conf

2 directories, 3 files
```
- `docker-compose.yml`:
```yml
name: olympus-dashboard
services:
  web:
    image: nginx:latest
    container_name: homelab-dashboard
    restart: always
    ports:
      - "8000:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./html:/usr/share/nginx/html:ro
```
- `nginx.conf`:
```Nginx
http {

    include mime.types;

    server {
        listen 80;
        root /usr/share/nginx/html;
    }
}

events {}
```
- Built a simple HTML page (`html/index.html`) with direct links to the services running on Eos (Netdata on port 19999, Nextcloud on port 8080, this website on port 8000)
- The port was blocked by default so I had to explicitly allow the container's traffic:
```bash
sudo ufw-docker allow homelab-dashboard 80
```


**Setting up NGINX for Nextcloud**
- To serve Nextcloud under a custom domain
- Nextcloud AIO's Apache server is tucked away on a port; users shouldn't have to type that port at the end of my URL, so NGINX listens on the standard port `443` (HTTPS) and silently passes that traffic to Nextcloud in the background
- By default, web servers block large uploads (often at 1MB); by using NGINX I will be able to send a 10GB file through the server, for example
- NGINX can help with using clean domain names (ex. `cloud.example.com`) to reach multiple services using only one open firewall port (`443`)
- I will set up NGINX proxy manager GUI as a new Docker continer
https://hub.docker.com/r/jc21/nginx-proxy-manager
- Bought a public domain: olympus-luca.online
- Set it up on Cloudflare with DNS records and changed the current nameservers with Cloudflare nameservers on the domain proivder website
- Generated Cloudflare API token
- Now the domain is being managed completely on Cloudflare
- Creating Let's Encrypt certificte on NPM to remove "Not secure" warning
- Rather than opening my home router ports to the public internet, I opted for a high-security configuration that points my public domain (olympus-luca.online) directly to my local server IP (192.168.1.200)
- In Cloudflare, I configured a CNAME wildcard (*) record, ensuring that any subdomain I create—such as nc. for Nextcloud or dash. for my dashboard—automatically routes to my Debian server without needing individual DNS entries for every new service
- To obtain a valid SSL certificate without public port exposure, I utilized the DNS-01 Challenge; by providing NPM with my Cloudflare API token, it successfully "shook hands" with Cloudflare to prove domain ownership behind the scenes, granting me a professional Wildcard SSL Certificate (*.olympus-luca.online)
- Configured AIO Nextcloud and main Nextcloud domain using NPM along with other domains for my homelab (Netdata and dashboard)
```
Proxy Host Configurations:
1. nc.olympus-luca.online -> http://192.168.1.200:11000 (Main Nextcloud Instance)
2. nc-aio.olympus-luca.online -> https://192.168.1.200:8080 (AIO Mastercontainer Setup)
3. nd.olympus-luca.online -> http://192.168.1.200:19999 (Netdata Console)
4. olympus-luca.online -> http://192.168.1.200:8000 (Root Domain / Main Site)
```
- Nextcloud is now up and running
- Set up admin account with email and password

**Date: 2026-03-01**
- Configured Nextcloud group for family and made user accounts for my parents and set upload limits

**Date: 2026-03-05**
 - Configured VS Code Remote - SSH to develop directly on the Debian server from my MacBook
 
 **Date: 2026-03-12**
 - Successfully test system reboot
 - Doing a security check-up:
 1. Checking for open ports using `sudo ss -tulpen`
 2. Verifying Firewall and Docker rules using
 ```
sudo ufw status verbose
sudo ufw-docker status
 ```

**Date: 2026-07-04**

I will upgrade this server node with a new thrifted hard drive which contains `465.8G`, for bigger cloud storage for Nextcloud.

- I'm starting by running the `lsblk` command to identify the new hard drive along with my other volumes:
```bash
luca@debian-eos:~$ lsblk
NAME                   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                      8:0    0 223.6G  0 disk 
├─sda1                   8:1    0   487M  0 part /boot/efi
└─sda2                   8:2    0 223.1G  0 part 
  ├─vg_system-lv_root  254:0    0  46.6G  0 lvm  /
  └─vg_system-lv_swap  254:1    0   3.7G  0 lvm  [SWAP]
sdb                      8:16   0 698.6G  0 disk 
└─sdb1                   8:17   0 698.6G  0 part 
  └─vg_data-lv_storage 254:2    0 698.6G  0 lvm  /srv
sdc                      8:32   0 465.8G  0 disk 
├─sdc1                   8:33   0   100M  0 part 
├─sdc2                   8:34   0  98.3G  0 part 
├─sdc3                   8:35   0  25.1G  0 part 
├─sdc4                   8:36   0     1K  0 part 
└─sdc5                   8:37   0 342.3G  0 part /mnt/temp_check
```
- Wiping the whole metadata of the hard drive:
```bash
# luca @ debian-eos in /dev [20:22:36] 
$ sudo wipefs -a /dev/sdc
/dev/sdc: 2 bytes were erased at offset 0x000001fe (dos): 55 aa
/dev/sdc: calling ioctl to re-read partition table: Success
```
- Reconfiguring LVM for storage extension with the `sdc` hard drive:
```bash
# luca @ debian-eos in /dev [20:22:51] 
$ sudo pvcreate /dev/sdc
  WARNING: Ignoring queue/optimal_io_size = 33553920 for device /dev/sdc (not divisible by 4KiB).
  Physical volume "/dev/sdc" successfully created.
```
- Extending the `vg_data` volume group, taking the new 465 GB and adding adding them to the 750 GB group:
```bash
sudo vgextend vg_data /dev/sdc
```
- Extending the `lv_storage` virtual container, occupying the whole free space `+100%FREE` which was just added to the volume group; this is the phisically mounted volume in `/srv`:
```bash
$ sudo lvextend -l +100%FREE /dev/vg_data/lv_storage
  Size of logical volume vg_data/lv_storage changed from 698.63 GiB (178850 extents) to <1.14 TiB (298084 extents).
  Logical volume vg_data/lv_storage successfully resized.
```
- Now that the LVM has been extended, I will extend the filesystem (ext4) to use the new allocated space:
```bash
$ sudo resize2fs /dev/vg_data/lv_storage
resize2fs 1.47.2 (1-Jan-2025)
Filesystem at /dev/vg_data/lv_storage is mounted on /srv; on-line resizing required
old_desc_blocks = 88, new_desc_blocks = 146
The filesystem on /dev/vg_data/lv_storage is now 305238016 (4k) blocks long.
```
- The storage has been successfully added:
```bash
$ df -h /srv
Filesystem                      Size  Used Avail Use% Mounted on
/dev/mapper/vg_data-lv_storage  1.2T  4.5G  1.1T   1% /srv
```

**[Date: 2026-08-18]**

**Resolving Emergency Mode & Multi-Disk LVM Boot Failure:**
-	After keeping the homelab nodes powered off for several days, neither SSH nor Tailscale connections were reachable.
-	Ping requests to `192.168.1.200` succeeded, but SSH attempts returned `Connection refused`.
-	The router's DHCP server had temporarily assigned the static IP addresses (`192.168.1.200` and `192.168.1.201`) to IoT devices (a security camera perhaps) in the local network during downtime.
-	Upon physical inspection, Node 01 (Debian Eos) was halted at boot in Emergency Mode due to a failed dependency on `/srv `(`dev-mapper-vg_data\x2dlv_storage.device`).
- The logical volume `lv_storage` spans across two physical drives (`sdb` and `sdc` in `vg_data`).
- On cold boot, the internal 750GB SATA HDD failed to initialize in time on the bus, and the secondary drive was temporarily disconnected.
- Because a physical volume (PV) was missing from `vg_data`, LVM refused to activate the volume group partially, causing `/srv` to fail mounting and halting the boot sequence.
- I reconnected the external disk to ensure both physical volumes were attached.
- Authenticated into the maintenance root shell on the server console.
- Forced the SCSI/SATA subsystem to rescan all controller channels:
```bash
for host in /sys/class/scsi_host/host*/scan; do echo "- - -" > "$host"; done
```
  *•	`/sys/class/scsi_host/host*/scan`: The /sys (sysfs) virtual filesystem exposes direct kernel interfaces for hardware drivers. Every SATA controller port, AHCI channel, or USB-to-SATA bridge registers a SCSI host directory (host0, host1, host2, etc.) containing a virtual file named scan.*
  •	*for host in ...; do ... done: A standard shell loop that iterates through every controller channel discovered on the motherboard.*
  •	*echo "- - -" > "$host": Writing three wildcards separated by spaces is the official kernel syntax to request a full bus scan:*
  •	*1st - (Channel): Scan all channels/buses on the controller.*
  •	*2nd - (Target ID): Scan all device IDs.*
  •	*3rd - (LUN): Scan all Logical Unit Numbers.*
- Verified that all three block devices were recognized via `lsblk` (sda 223.6G, sdb 465.8G, sdc 698.6G).
- Reactivated all LVM volume groups and mounted the missing targets:
```bash
vgscan
vgchange -ay
mount -a
exit
```
- The system resumed its regular multi-user boot target; network interfaces, SSH daemon, Tailscale, and Docker services initialized successfully.

**Configuring Automatic Power Recovery via Direct-Link Wake-on-LAN (WoL):**
- Since the laptop lacks an operational battery and does not feature native AC Power Loss recovery in its ASUS BIOS, power outages leave the machine in a cold powered-off state.
- Enabled `Launch PXE OpROM policy` in the BIOS (Aptio Setup Utility) to keep the integrated Realtek NIC energized during sleep and soft-off states.
- Configured the physical Ethernet interface to accept Magic Packets permanently across reboots:
```bash
sudo apt update && sudo apt install -y ethtool
sudo ethtool -s enp2s0f1 wol g
```
- Appended the persistence rule to `/etc/network/interfaces`:
```text
allow-hotplug eth0
iface eth0 inet manual
    ethernet-wol g
```
- Identified a boot failure risk: the current external 3.5" drive enclosure (Inateck FE3002) uses a momentary electronic push-button circuit, causing the disk to remain powered down after power interruptions.
- Selected an *Axagon EE35-XA3* aluminum USB 3.0 enclosure with a dedicated mechanical 2-position rocker switch (`I / O`). Leaving the hardware switch in the `I (ON)` position guarantees automatic drive spin-up directly on power restoration.

**[Date: 2026-08-21]**
- Following a router reconfiguration, Node 01 (`192.168.1.200`) remained unreachable over ping and SSH (`100% packet loss`).
- Node 01's Atheros wireless interface (`wlp3s0`) is statically configured inside `/etc/network/interfaces` using Debian's native ifupdown toolchain rather than NetworkManager. Because `wpa-ssid` and `wpa-psk` were hardcoded, the interface dropped after the router's SSID/password reset and entered an unmanaged state.
- Updated /etc/network/interfaces on Node 01 with the active network credentials:
```
# The primary network interface
allow-hotplug wlp3s0
iface wlp3s0 inet static
	address 192.168.1.200
	netmask 255.255.255.0
	gateway 192.168.1.1
	dns-nameservers 8.8.8.8 1.1.1.1
	wpa-ssid <WIFI_SSID>
	wpa-psk  <WIFI_PASSWORD>
```
- Cycled the physical wireless interface to apply credentials and renew the link state:
```bash
sudo ifdown wlp3s0
sudo ifup wlp3s0
```
- Verified interface status and default gateway routing:
```bash
ip addr show wlp3s0
ping -c 3 1.1.1.1
```
- Verified connectivity and confirmed all nodes are online and stable on their dedicated static IPs across the network topology.

**[Date: 2026-08-22]**
### Deploying GitLab CE on Node 01 (Eos) & Automating GitHub Repositories Backup

- I wanted to self-host an independent Git repository platform using GitLab CE on Node 01 and automate full backup mirrors of my entire GitHub account (public, private, all branches, tags, and commits).
- **Setting Up Storage Directories:**
- Created dedicated persistent directories on the HDD storage partition (`vg_data` mounted at `/srv`):
```bash
sudo mkdir -p /srv/docker/gitlab/{config,logs,data}
cd /srv/docker/gitlab
```
- Since GitLab CE is known to consume substantial memory (typically 4GB-8GB+) and Node 01 only has 8GB of RAM with Nextcloud and Netdata active, I applied aggressive resource constraints in compose.yml to prevent OOM kills on the Haswell dual-core i3 CPU:
  - Configured Puma to run only 2 workers with 1-2 threads max.
  - Limited Sidekiq background processing concurrency to 5.
  - Reduced PostgreSQL shared memory buffers to 256MB and worker processes to 2.
  - Disabled Prometheus embedded monitoring.
  - Remapped Git SSH container port 22 to host port 2222 to prevent conflicts with the host system's SSH daemon on port 22.
  ```yaml
      puma['worker_processes'] = 2 # 2 web workers
      puma['min_threads'] = 1 # limit threading
      puma['max_threads'] = 2 # limit threading
      sidekiq['concurrency'] = 5 # liit background job workers
      postgresql['shared_buffers'] = "256MB" # reduce database memory
      postgresql['max_worker_processes'] = 2
      prometheus_monitoring['enable'] = false # disable metrics collection
  ports:
    - "8085:80" # web ui passed to nginx proxy manager (maps container port 80 to host port 8085)
    - "2222:22" # git ssh clone port (maps container port 22 to host port 2222)
  ```
- View the full Docker Compose file [here](gitlab/compose.yaml).
- Running `sudo docker compose up -d` to spin up the container.
- Retrieved the initial administrator password:
```bash
sudo cat /srv/docker/gitlab/config/initial_root_password | grep "Password:"
```
- **Configuring Firewall & Reverse Proxy:**
  - Allowed Git SSH through host firewall: `sudo ufw allow 2222/tcp comment "GitLab Git SSH"`
  - Allowed Docker internal traffic for GitLab Web UI: `sudo ufw-docker allow gitlab 80`
  - In Nginx Proxy Manager (NPM), added a new Proxy Host:
    ```
    Domain: gitlab.olympus-luca.online
    Scheme: http
    Forward Hostname / IP: 192.168.1.200
    Forward Port: 8085
    ```
  - Enabled Websockets Support, Force SSL with the Wildcard certificate (`*.olympus-luca.online`), and added `client_max_body_size 500M`; under the Advanced tab for large Git pushes.
- **Automating Complete GitHub Repositories Backup:**
  - Created a dedicated sync script at /srv/docker/github-backup/backup-github.sh that fetches all repositories using a GitHub Fine-Grained Personal Access Token, mirrors them locally to /srv/docker/gitlab-backup/repos/, checks the local GitLab REST API via a Personal Access Token to create any missing private repositories under the root user, and pushes the complete mirrors (git push --mirror).
  - View the script [here](gitlab/backup-script.sh)
  - Made script executable and tested manually:
  ```bash
  sudo chmod +x /srv/docker/github-backup/backup-github.sh
  sudo /srv/docker/github-backup/backup-github.sh
  ```
  - All repos cloned and pushed to local GitLab without issue.
  - Configured Daily Automated Cron Job:
    - Added root crontab entry via `sudo crontab -e` to trigger automatic backup execution nightly at 02:00:
    ```cron
    0 2 * * * /srv/docker/github-backup/backup-github.sh >> /var/log/github-backup.log 2>&1
    ```

**[Date: 27-08-2026]**

### Migrating Node 01 to Gigabit Ethernet

- **See network setup here:** [setup](../Networking/README.md)

- Configuring directly through the physical laptop terminal
- Editing the `/etc/network/interfaces` file:
```bash
sudo nano /etc/network/interfaces
```
```
auto lo
iface lo inet loopback

auto enp2s0f1
iface enp2s0f1 inet static
    address 10.0.0.10
    netmask 255.255.255.0
    gateway 10.0.0.1
    dns-nameservers 10.0.0.1 1.1.1.1
    ethernet-wol g
```
- Deleting any previous network settings and setting the interface to `up`
```bash
sudo ifdown wlp3s0 2>/dev/null
sudo ifdown enp2s0f1 2>/dev/null && sudo ifup enp2s0f1
sudo ip route del default 2>/dev/null
sudo ip addr flush dev enp2s0f1

sudo ifup enp2s0f1
```
- The connection has established successfully:
```bash
# luca @ debian-eos in ~ [18:57:49]
$ ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=56 time=14.2 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=56 time=13.9 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=56 time=13.7 ms
^C
--- 1.1.1.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 13.693/13.937/14.247/0.230 ms
```

### Migrating Nginx Proxy Manager to new network

- Editing each entry on the hosts web interface from `192.168.1.200` to `10.0.0.10`

### Migrating Tailscale to new network settings and setting up Tailscale Subnet Router for network `10.0.0.0`

- I wanted to access the entire homelab subnet (`10.0.0.0/24`) remotely without installing Tailscale individually on every device (MikroTik, TP-Link switch, Proxmox and Windows Server VM), so I configured Node 01 (`debian-eos`) to act as a dedicated **Tailscale Subnet Router**.

**1. Enabling Kernel IP Forwarding:**
- I enabled IP forwarding so the Linux kernel can route network packets between the `tailscale0` virtual interface and the physical Ethernet adapter (`enp2s0f1`):
```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
```

**2. Adjusting UFW Forward Policy:**
- By default, UFW drops routed transit packets, so I changed the forwarding policy to accept traffic and allowed connections on the Tailscale interface:
```bash
sudo sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
sudo ufw allow in on tailscale0
sudo ufw reload
```

**3. Advertising the Subnet Route:**
- I re-authenticated and started Tailscale, advertising the new `10.0.0.0/24` subnet while resetting the previous parameters:
```bash
sudo tailscale up --advertise-routes=10.0.0.0/24 --accept-dns=false --reset
```

**4. Approving the Subnet Route in the Admin Console:**
- I navigated to the [Tailscale Admin Console](https://login.tailscale.com/admin/machines).
- Under the machine entry for **`debian-eos`**, I opened **Edit route settings...**.
- I enabled the newly advertised route **`10.0.0.0/24`** and unchecked the deprecated `192.168.1.0/24` route.

**5. Verifying Remote Subnet Routing:**
- I tested connectivity from my MacBook using a cellular hotspot, with Tailscale enabled:
```bash
# Gateway (MikroTik)
ping -c 2 10.0.0.1

# Node 02 (Proxmox Dionysus)
ping -c 2 10.0.0.20

# Windows Server VM
ssh Administrator@10.0.0.30
```

- I confirmed remote reachability for the homelab web interfaces, including RouterOS WebFig, Proxmox VE at `https://10.0.0.20:8006`, Nginx Proxy Manager and Windows RDP, over the Tailnet.

- This setup allows me to securely access the entire `10.0.0.0/24` homelab network remotely through Node 01, without having to install Tailscale on every device.

### Troubleshooting Tailscale Subnet Routing

- The Debian node was not routing packets to the rest of the homelab because UFW was blocking the `FORWARD` chain. Allowing traffic into `tailscale0` only allowed traffic destined for Node 01 itself; it did not allow routed traffic to the other homelab devices.
- I installed the package required to save the firewall rules across reboots:
```bash
sudo apt update
sudo apt install -y iptables-persistent
```
- I connected to Node 01 remotely through Tailscale:
```bash
ssh luca@100.80.227.117
```
- I added rules to allow traffic to be forwarded between Tailscale and the wired interface, and enabled masquerading for the homelab subnet:
```bash
# Allow routed traffic in both directions through Tailscale
sudo iptables -I FORWARD -i tailscale0 -j ACCEPT
sudo iptables -I FORWARD -o tailscale0 -j ACCEPT

# Masquerade Tailscale traffic when it leaves through the wired interface
sudo iptables -t nat -I POSTROUTING -o enp2s0f1 -j MASQUERADE

# Save the rules so they persist after a reboot
sudo netfilter-persistent save
```
- On my MacBook, I checked whether Tailscale installed the route to the homelab subnet:
```bash
netstat -rn | grep 10.0.0
```
- I then tested access to the MikroTik gateway, Proxmox and Windows Server VM from an external network using a cellular hotspot:
```bash
ping -c 2 10.0.0.1
ping -c 2 10.0.0.20
ssh Administrator@10.0.0.30
```
- If the route did not appear on the MacBook, I restarted the Tailscale connection to reload the advertised routes.

## Cloudflare Tunnel for Nextcloud access

**Date: 2026-08-28**

### Objective

I configured external access to Nextcloud for my parents without opening ports on either router or contacting Digi. Only Nextcloud is published; other homelab services remain private.

### Traffic flow

```text
Parents
  -> https://nc.olympus-luca.online
  -> Cloudflare
  -> Cloudflare Tunnel
  -> Node 01 (Debian Eos)
  -> Nextcloud at 10.0.0.10:11000
```

The tunnel creates an outbound connection from Node 01 to Cloudflare. No inbound port-forwarding rules are required.

### Cloudflare DNS

The old public records pointing to private addresses were removed:

```text
olympus-luca.online -> 10.0.0.10
*.olympus-luca.online -> olympus-luca.online
```

Only `nc.olympus-luca.online` is published through the tunnel. The MikroTik local DNS record was kept for local homelab access:

```routeros
/ip dns static
add name=olympus-luca.online match-subdomain=yes address=10.0.0.10
```

### Tunnel creation

The Cloudflare origin certificate was saved to the persistent host directory. Docker needed the host directory mounted at `/tmp` because the cloudflared image's `/home/nonroot` directory was not writable by the host user:

```bash
mkdir -p "$HOME/.cloudflared"

docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  -v "$HOME/.cloudflared:/tmp/.cloudflared" \
  cloudflare/cloudflared:latest \
  tunnel login
```

The tunnel was created successfully:

```text
Name: nextcloud-only
ID:   e76021be-987c-4797-b788-1147f4fdd9d9
```

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  -v "$HOME/.cloudflared:/tmp/.cloudflared" \
  cloudflare/cloudflared:latest \
  tunnel --origincert /tmp/.cloudflared/cert.pem \
  create nextcloud-only
```

The DNS route was created with:

```bash
docker run --rm -it \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  -v "$HOME/.cloudflared:/tmp/.cloudflared" \
  cloudflare/cloudflared:latest \
  tunnel --origincert /tmp/.cloudflared/cert.pem \
  route dns nextcloud-only nc.olympus-luca.online
```

### Tunnel configuration

The file `$HOME/.cloudflared/config.yml` contains only the Nextcloud route:

```yaml
tunnel: e76021be-987c-4797-b788-1147f4fdd9d9
credentials-file: /etc/cloudflared/e76021be-987c-4797-b788-1147f4fdd9d9.json

ingress:
  - hostname: nc.olympus-luca.online
    service: http://10.0.0.10:11000
  - service: http_status:404
```

The final `http_status:404` rule rejects every hostname that is not explicitly configured.

### Running and verifying the tunnel

```bash
docker run -d \
  --name cloudflared-nextcloud \
  --restart unless-stopped \
  --network host \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  -v "$HOME/.cloudflared:/etc/cloudflared:ro" \
  cloudflare/cloudflared:latest \
  tunnel --config /etc/cloudflared/config.yml run

docker logs cloudflared-nextcloud
```

The logs confirmed `Starting tunnel` and multiple `Registered tunnel connection` messages. The UDP receive-buffer message was a performance warning and did not prevent the tunnel from working.

### Nextcloud account security

- The Registration app was not installed or enabled, so visitors cannot self-register.
- Parent accounts are normal users, not administrators.
- Individual storage quotas and unique passwords were configured for parent accounts.
- TOTP two-factor authentication and backup codes were configured for the administrator and parent accounts.
- Brute-force protection and auditing/logging remain enabled.
- Public link sharing should remain disabled unless explicitly required.

### Private services

These services are not published through the tunnel:

- Nginx Proxy Manager and the Nextcloud AIO administration panel
- MikroTik WebFig and TP-Link switch management
- Proxmox, SSH, Windows RDP, GitLab, and Netdata

They remain accessible locally or through the existing Tailscale subnet router.

### Credential protection

The following files contain sensitive credentials and must remain private:

```text
$HOME/.cloudflared/cert.pem
$HOME/.cloudflared/e76021be-987c-4797-b788-1147f4fdd9d9.json
$HOME/.cloudflared/config.yml
```

Permissions were restricted with:

```bash
chmod 700 "$HOME/.cloudflared"
chmod 600 "$HOME/.cloudflared/cert.pem"
chmod 600 "$HOME/.cloudflared/"*.json
chmod 600 "$HOME/.cloudflared/config.yml"
```

The container mounts the configuration directory read-only with `:ro` and restarts automatically after Node 01 reboots.

### Final result

Only `https://nc.olympus-luca.online` is publicly reachable. Anyone can see the Nextcloud login page, but only manually created users with valid credentials and two-factor authentication can access storage. No ports were opened on the home router or MikroTik.

---

## Multi-Disk LVM Filesystem Corruption Recovery & Docker Volume Reconstruction

**Date: 2026-08-31**

### Incident

While reorganizing Docker storage directories inside `/srv`, an interrupted `mv` operation coincided with an instantaneous USB I/O drop on the external drive (`/dev/sdd` / `sdc`), which forms a spanned LVM Volume Group (`vg_data`) together with the internal SATA HDD (`/dev/sdb1`).

Because ext4 lost communication with the physical blocks mid-transaction, directory pointers were unlinked from the root directory tree while the actual data blocks and inodes remained intact on the drive.

Upon re-mounting, the system exhibited `Input/output error` symptoms, Docker failed to initialize its daemon, and `/srv/docker-data/volumes` appeared completely vanished. Inspecting `/srv/lost+found` revealed hundreds of disconnected orphan inodes prefixed with `#`, including www-data assets and database structures.

### Filesystem Repair & Inode Reconnection via e2fsck

Unmounted the degraded `/srv` filesystem to avoid further metadata corruption:

```bash
sudo systemctl stop docker
sudo systemctl stop containerd
sudo umount -l /srv
```

Ran a non-interactive filesystem consistency check across the entire logical volume with both physical disks online:

```bash
sudo e2fsck -fy /dev/vg_data/lv_storage
```

`e2fsck` detected the unlinked directory structures, fixed block bitmaps, and reconnected all orphaned directory inodes into `/srv/lost+found`:

```
/dev/vg_data/lv_storage: ***** FILE SYSTEM WAS MODIFIED *****
/dev/vg_data/lv_storage: 722297/76316672 files (0.3% non-contiguous), 14877910/305238016 blocks
```

### Identifying and Restoring the Orphaned Docker Volumes

Re-mounted `/srv` to inspect the recovered inodes:

```bash
sudo mount /dev/vg_data/lv_storage /srv
```

Located the primary Docker volumes directory by scanning for known database files and analyzing directory sizes:

```bash
sudo find /srv/lost+found -maxdepth 3 \( -name "config.php" -o -name "PG_VERSION" -o -name "_data" -o -name "metadata.db" \) 2>/dev/null

sudo du -hd 1 /srv/lost+found/ 2>/dev/null | sort -h | tail -n 20
```

The search revealed that `#6816207` (8.4GB) was the entire intact `volumes/` directory containing all persistent application state:

- `nextcloud_aio_nextcloud/_data`
- `nextcloud_aio_database/_data` (PostgreSQL)
- `nextcloud_aio_redis/_data`
- `nextcloud_aio_mastercontainer/_data`
- `compose-demo_redis-data/_data`
- `full-stack-compose_db-data/_data`

Restored the recovered folder directly back to its production location:

```bash
sudo mv /srv/lost+found/#6816207 /srv/docker-data/volumes

sudo chmod 710 /srv/docker-data/volumes
```

### Docker Daemon Recovery & Socket Cleanup

Re-verified that `/etc/docker/daemon.json` correctly points to the HDD storage path:

```json
{
  "data-root": "/srv/docker-data"
}
```

Cleaned up stale runtime sockets and reset crashed systemd units:

```bash
sudo rm -rf /run/docker /run/containerd /var/run/docker /var/run/containerd

sudo systemctl reset-failed docker.service docker.socket containerd

sudo systemctl restart containerd

sudo systemctl restart docker
```

Verified volume recognition:

```bash
sudo docker volume ls
```

All named volumes (`nextcloud_aio_*`, `gitlab`, etc.) were detected immediately by Docker Engine.

### Restoring Nextcloud AIO & Remote Access Workaround

Started the Nextcloud AIO Mastercontainer:

```bash
cd /srv/docker/nextcloud

sudo docker compose up -d
```

Verified container health:

```bash
sudo docker logs nextcloud-aio-mastercontainer --tail 30
```

Output showed the server listening on HTTPS port `8080`.

Because direct access over Tailscale timed out due to routing/firewall rules, an encrypted SSH tunnel was established from the MacBook to securely map the administration port:

```bash
# Executed from local MacBook terminal:
ssh -L 8080:localhost:8080 luca@100.80.227.117
```

Navigated to `https://localhost:8080` in Safari, submitted the AIO passphrase, and triggered container initialization.

All dependent microservices initialized with `healthy` status:

- `nextcloud-aio-mastercontainer`
- `nextcloud-aio-database` (PostgreSQL)
- `nextcloud-aio-redis`
- `nextcloud-aio-nextcloud`
- `nextcloud-aio-apache`
- `nextcloud-aio-notify-push`
- `nextcloud-aio-imaginary`

### Restoring Remaining Homelab Services & Verification

Started the rest of the application stacks across `/srv/docker`:

```bash
# Nginx Proxy Manager (Reverse Proxy & SSL termination)
cd /srv/docker/npm && sudo docker compose up -d

# GitLab CE
cd /srv/docker/gitlab && sudo docker compose up -d

# PHP Environment
cd /srv/docker/php && sudo docker compose up -d
```

Verified that all containers across the node are active and operational:

```bash
sudo docker ps
```

### Post-Incident Analysis & Preventive Architecture

**Root Cause Risk:** Spanning an LVM Volume Group (`vg_data`) across an internal SATA bus (`/dev/sdb1`) and an external USB-attached disk (`/dev/sdd`) introduces severe instability. Any momentary power hiccup, sleep cycle, or loose USB cable instantly compromises the entire 1.14 TiB ext4 filesystem.

1. Migrate all active data blocks entirely onto the internal 750GB SATA drive using `pvmove /dev/sdd /dev/sdb1`.
2. Safely reduce the volume group (`vgreduce vg_data /dev/sdd`) and disconnect the USB drive from the primary LVM array.
3. Repurpose the external USB hard drive strictly for automated offline/cold backups.
4. Implement an encrypted offsite cloud backup strategy (Borg / Restic) for critical Nextcloud and GitLab volumes.

### Emergency Recovery Protocol (Reference for Future Outages)

In case of another unexpected USB/drive disconnect causing I/O errors:

```bash
cd ~
sudo systemctl stop docker
sudo systemctl stop containerd
sudo umount -l /srv

# re-scan SCSI bus & refresh LVM metadata
for host in /sys/class/scsi_host/host*/scan; do echo "- - -" > "$host"; done
sudo pvscan --cache
sudo vgchange -ay vg_data

# repair filesystem consistency
sudo e2fsck -fy /dev/vg_data/lv_storage

# remount and clean Docker sockets
sudo mount /dev/vg_data/lv_storage /srv
sudo rm -rf /run/docker /run/containerd /var/run/docker /var/run/containerd

sudo systemctl restart containerd
sudo systemctl restart docker

# restart containers
cd /srv/docker/nextcloud && sudo docker compose up -d
cd /srv/docker/npm && sudo docker compose up -d
cd /srv/docker/gitlab && sudo docker compose up -d
```

**Key Lessons Learned:**

- LVM spanning across mixed storage interfaces (internal SATA + external USB) is a critical single-point-of-failure architecture.
- ext4 orphan inode recovery via `e2fsck -y` is highly effective for unlinked directory structures with intact data blocks.
- Docker named volumes persist and survive filesystem corruption; reconnecting them to recovered inodes is the fastest recovery path.
- SSH tunneling over Tailscale provides secure remote administration when direct network paths are blocked.

---

## Restoring Cloudflare Tunnel & Homelab DNS Resolution

**Date: 2026-08-31 (continued)**

### Problem

After restoring the Docker volumes and starting the container stack, none of the web services were reachable from my MacBook despite all containers reporting healthy status.

**Root Causes:**

- The `cloudflared-nextcloud` container had exited and was not actively maintaining the outbound tunnel connection for `nc.olympus-luca.online`.
- With public wildcard DNS previously removed from Cloudflare, the MacBook (connected via Tailscale using MagicDNS `100.100.100.100`) could not resolve internal subdomains (`gitlab.`, `npm.`, `dash.`) that were only defined statically in MikroTik's local DNS.

### 1. Re-deploying Cloudflare Tunnel for Nextcloud

Removed the stale stopped container and relaunched the active tunnel process in daemon mode:

```bash
sudo docker rm -f cloudflared-nextcloud

sudo docker run -d \
  --name cloudflared-nextcloud \
  --restart unless-stopped \
  --network host \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  -v "$HOME/.cloudflared:/etc/cloudflared:ro" \
  cloudflare/cloudflared:latest \
  tunnel --config /etc/cloudflared/config.yml run
```

Inspected logs to verify tunnel registration:

```bash
sudo docker logs cloudflared-nextcloud --tail 15
```

The output confirmed 4 registered tunnel connections to Cloudflare edge nodes. `https://nc.olympus-luca.online` became immediately reachable from external networks.

### 2. Allowing Tailscale Traffic through Host Firewall

Ensured incoming and forwarded packets on the `tailscale0` virtual interface are explicitly permitted:

```bash
sudo iptables -I INPUT -i tailscale0 -j ACCEPT
sudo iptables -I FORWARD -i tailscale0 -j ACCEPT
sudo netfilter-persistent save
```

This ensures that Tailscale clients can reach services across the homelab without hitting UFW or iptables drop rules.

### 3. Dedicated Private Namespace (*.home.olympus-luca.online) & HTTP/2 Coalescing Resolution

When `nc.olympus-luca.online` is routed via Cloudflare Tunnel (using Cloudflare Universal SSL `*.olympus-luca.online`), browsers visiting Nextcloud open an HTTP/2 connection to Cloudflare. Because first-level subdomains share the wildcard scope, browsers attempt to reuse that connection for private services (`gitlab`, `npm`, `nd`), which Cloudflare rejects with `421 Misdirected Request (openresty)`.

To eliminate browser connection collisions permanently while keeping Nextcloud public:
- **Public Domain (Cloudflare Tunnel):** `nc.olympus-luca.online`
- **Private Subdomain Namespace (NPM / 10.0.0.10):** `*.home.olympus-luca.online` (e.g., `gitlab.home.`, `npm.home.`, `nd.home.`, `home.`)

**Cloudflare DNS Records:**
- **Name:** `*.home` | **Type:** `A` | **Content:** `10.0.0.10` | **Proxy:** DNS only (Grey Cloud)
- **Name:** `home` | **Type:** `A` | **Content:** `10.0.0.10` | **Proxy:** DNS only (Grey Cloud)

**MikroTik Local DNS:**
```routeros
/ip dns static add name=home.olympus-luca.online match-subdomain=yes address=10.0.0.10
```

### 4. Root Filesystem Optimization & Containerd Storage Relocation

Identified `/var/lib/containerd` (22GB) and `/var/cache/apt` (6.3GB) filling the root SSD (`vg_system-lv_root`) to 95% capacity:
1. Emptied apt package cache: `sudo apt clean`
2. Relocated containerd root data to the 1.2TB HDD storage array:
   ```bash
   sudo systemctl stop docker docker.socket containerd
   sudo mv /var/lib/containerd /srv/containerd
   sudo ln -s /srv/containerd /var/lib/containerd
   sudo systemctl start containerd docker
   ```
3. Reduced root SSD usage from 95% (2.5GB free) down to 25% (30GB+ free).

### Verification

- `nc.olympus-luca.online` is reachable publicly through Cloudflare Tunnel ✓
- Internal services on `*.home.olympus-luca.online` resolve to `10.0.0.10` without 421 collisions ✓
- All services accessible locally and over Tailscale via HTTPS with valid Let's Encrypt wildcard certs ✓

---

## Troubleshooting GitLab 502 Boot Failure & Database Recovery

**Date: 2026-08-31 (continued)**

### Problem

When navigating to `https://gitlab.home.olympus-luca.online`, the browser returned `HTTP 502: Waiting for GitLab to boot`. Inspection of GitLab service status revealed that Puma and Sidekiq were stuck in a continuous crash loop, restarting every 45 seconds:

```bash
sudo docker exec -it gitlab gitlab-ctl status
# puma and sidekiq continuously resetting to < 20s runtime
```

### Root Causes

1. **Puma Cluster Mode Worker Timeout & CPU Starvation:**
   - Running Puma in cluster mode (`worker_processes = 2`) on the dual-core i3 CPU with 8GB RAM spawned 5 heavy Ruby processes simultaneously.
   - On the mechanical HDD storage, Rails initialization took ~80 seconds, which exceeded Puma's default 60-second watchdog timeout, causing child workers to be killed before binding to the socket.

2. **Missing Database Schema (`PG::UndefinedTable`):**
   - Inspection of `/srv/docker/gitlab/logs/puma/current` revealed:
     ```text
     PG::UndefinedTable: ERROR: relation "application_settings" does not exist
     ```
   - When the root SSD ran out of disk space earlier (95% full), GitLab's initial database migration was interrupted, leaving PostgreSQL with an empty schema.

3. **Unseeded Default Fixtures & Autoloading Error:**
   - When Rails attempted to dynamically create the missing application settings on the fly inside the web server, it triggered a circular Zeitwerk autoloading crash:
     ```text
     NameError: uninitialized constant Gitlab::Redis::ALL_CLASSES
     ```

### Resolution Steps

1. **Switched Puma to Single Mode in `compose.yaml`:**
   - Changed `puma['worker_processes'] = 0` and set `puma['worker_timeout'] = 300`.
   - Running in Single Mode eliminates child worker forking, saves ~1.5GB of RAM, and prevents watchdog timeout kills on low-resource hardware.

2. **Ran Database Schema Migrations:**
   - Created all PostgreSQL tables, indexes, and constraints:
     ```bash
     sudo docker exec -it gitlab gitlab-rake db:migrate
     ```

3. **Seeded Default System Fixtures & Admin Account:**
   - Populated the `application_settings` row, default organization, root user credentials, and CI signing keys:
     ```bash
     sudo docker exec -it gitlab gitlab-rake db:seed_fu
     ```

4. **Reconfigured Omnibus & Restarted Services:**
   - Re-generated internal configuration templates and restarted the web stack:
     ```bash
     sudo docker exec -it gitlab gitlab-ctl reconfigure
     sudo docker exec -it gitlab gitlab-ctl restart puma
     sudo docker exec -it gitlab gitlab-ctl restart gitlab-workhorse
     sudo docker exec -it gitlab gitlab-ctl restart nginx
     ```

### Verification

- Puma bound to `tcp://127.0.0.1:8080` and `unix:///var/opt/gitlab/gitlab-rails/sockets/gitlab.socket` ✓
- `curl -I http://127.0.0.1:8080` returned `HTTP 302 Found` to `/users/sign_in` ✓
- `https://gitlab.home.olympus-luca.online` loads the GitLab login dashboard cleanly over HTTPS ✓

---

## LVM Span Elimination, Automated Nightly Backup & GitHub Mirror

**Date: 2026-09-01**

### Problem

- Docker containers entered zombie state (`0% CPU, 0B RAM`) due to I/O freeze on `/srv`.
- The volume group `vg_data` spanned across internal SATA HDD (`/dev/sdb1`) and external USB HDD (`/dev/sdc`). Intermittent USB drops triggered kernel zero-size lockups (`limit=0`), freezing the entire filesystem.
- Nextcloud returned `502 Bad Gateway` with a corrupted PostgreSQL index (`activity_user_time`).

### Resolution

1. **LVM Span Removal:** Shrunk filesystem (`resize2fs 680G`), reduced logical volume (`lvreduce -L 690G`), removed `/dev/sdc` from VG (`vgreduce` & `pvremove`), and re-extended `/srv` to 100% of internal SATA HDD (698GB).
2. **Dedicated USB Backup System:** Repurposed `/dev/sdc` as an unmounted off-line backup target with WWN udev rule (`/dev/backup-disk`), 3-attempt retry loop (45 min intervals), and hardlinked incremental rsync (`backup.sh`).
3. **Database & Nextcloud Repair:** Reindexed PostgreSQL (`reindexdb -U oc_nextcloud`), reset admin credentials, and purged 3,385 orphan file records via `occ files:scan --all`.
4. **GitHub to GitLab Mirror:** Generated root API token via Rails runner and mirrored all 22 GitHub repos into local GitLab (`backup-github.sh`).
5. **Dashboard & Cron:** Deployed lightweight HTML status dashboard on port 8000. Configured cron jobs at 02:00 (GitHub mirror), 03:00 (full backup), and */5 (dashboard metrics).

---

## Backup Cron Environment & USB Autosuspend Hardening

**Date: 2026-09-02**

- The automated 03:00 AM backup failed after 3 attempts with `backup drive not detected`.
- In cron's non-interactive environment, `/sbin` was missing from `PATH`, preventing execution of `blkid`.
- External USB drive entered kernel autosuspend during long idle periods while unmounted.

* **Environment PATH Export:** Added explicit `export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"` to `backup.sh` and `generate-status.sh`.
* **Bus Wakeup & Multi-Layer Detection:** Added pre-mount SCSI bus scan (`echo "- - -" > /sys/class/scsi_host/host*/scan`) and detection fallback chain (`/dev/disk/by-uuid/` → `blkid` → `/dev/backup-disk`).
* **Disabled USB Autosuspend:** Updated udev rule with `ATTR{power/control}="on"` to prevent sleep mode.

### Verification

- Manual and scheduled runs execute cleanly in under 30s using hardlinked incremental snapshots
- Dashboard live at `http://10.0.0.10:8000` reporting `SUCCESS` and drive connected

