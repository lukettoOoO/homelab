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