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