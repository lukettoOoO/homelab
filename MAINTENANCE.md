# Olympus Homelab — Monthly Maintenance Runbook

---

## 1. Infrastructure Inventory & Reference Matrix

### 1.1 Hardware & Nodes (`10.0.0.0/24`)

| Node / Appliance | Hostname / ID | IP Address | Domain / Management URL | OS / Firmware | Hardware & Storage Summary | Primary Roles |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Gateway Router** | `MikroTik` | `10.0.0.1` | `https://router.home.olympus-luca.online` | RouterOS v7 | MikroTik hEX S (RB760iGS) / MT7621A 2C / 256MB RAM / 16MB Flash | WAN NAT (`ether1`), `bridge-olympus`, DHCP (`.100-.200`), Static Split DNS, Firewall |
| **Core Switch** | `TL-SG108E` | `10.0.0.2` | `https://switch.home.olympus-luca.online` | TP-Link Easy Smart | 8-Port Gigabit RJ45 / Fanless | L2 Gigabit switching (Port 1: Router, Port 2: Node-01, Port 3: Node-02) |
| **Node-01 (Eos)** | `debian-eos` | `10.0.0.10` (`100.80.227.117` Tailscale) | `https://home.olympus-luca.online` | Debian 13 (Trixie) | ASUS X550LB / i3-4010U (2C/4T) / 8GB RAM / 240GB SSD (`/`) / 750GB SATA HDD (`/srv`) / 465GB USB HDD (`/mnt/backup`) | Docker Host, Nextcloud AIO, GitLab CE, NPM, Netdata, Cloudflared, Tailscale Subnet Router, Nightly Backups |
| **Node-02 (Atlas)** | `proxmox` | `10.0.0.20` | `https://pve.home.olympus-luca.online` (`:8006`) | Proxmox VE 8.x | HP EliteDesk 800 G4 / i5-8500T (6C) / 16GB DDR4 / 256GB NVMe SSD (`/dev/nvme0n1`) / Intel i219LM + USB LAN (WoL) | Type-1 Hypervisor (`local` + `local-lvm`), Direct-Link Wake-on-LAN orchestrator for Node-01 |
| **VM 100 (Dionysus)** | `windows-server-2022-dionysus` | `10.0.0.30` | `dionysus.home.olympus-luca.online` | Windows Server 2022 + Ubuntu 22.04 WSL2 | 2 vCPU / 6GB RAM / 70GB VirtIO Disk (`local-lvm`) | Active Directory DC (`ad.home.olympus-luca.online` / `DIONYSUS`), DNS Server, IIS Web Server, RDP (`:3389`), OpenSSH (`:22`) |

### 1.2 Service Port & Routing Map (Node-01 `10.0.0.10`)

| Service | Container / Systemd Unit | Internal Port | Endpoint URL | Exposure Tier |
| :--- | :--- | :--- | :--- | :--- |
| **Nextcloud** | `nextcloud-aio-apache` | `11000` (HTTP) | `https://nc.olympus-luca.online` | Public (Cloudflare Tunnel `cloudflared-nextcloud`) |
| **Personal Website** | `personal-website` | `8088` (HTTP) | `https://web.olympus-luca.online` | Public (Cloudflare Tunnel `cloudflared-nextcloud`) |
| **Nextcloud AIO Panel** | `nextcloud-aio-mastercontainer` | `8080` (HTTPS) | `https://nc-aio.home.olympus-luca.online` | Private (LAN / Tailscale via NPM) |
| **Olympus Dashboard** | `homelab-dashboard` | `8000` (HTTP) | `https://home.olympus-luca.online` | Private (LAN / Tailscale via NPM) |
| **GitLab CE** | `gitlab` | `8085` (Web) / `2222` (SSH) | `https://gitlab.home.olympus-luca.online` | Private (LAN / Tailscale via NPM; Git SSH on `:2222`) |
| **Nginx Proxy Manager** | `npm` | `81` (Admin) / `80, 443` | `https://npm.home.olympus-luca.online` | Private (LAN / Tailscale via NPM) |
| **Netdata Monitoring** | `netdata.service` (Host) | `19999` (HTTP) | `https://nd.home.olympus-luca.online` | Private (LAN / Tailscale via NPM) |

---

## 2. Execution Order

Execute maintenance procedures strictly in the following order to guarantee that backups and network routing are verified prior to package upgrades or system reboots:

1. [Section 3: Pre-Maintenance & Backup Verification](#3-pre-maintenance--backup-verification)
2. [Section 4: Network Layer, DNS & Remote Access](#4-network-layer-dns--remote-access-1000024)
3. [Section 5: Node-01 (`debian-eos`) — Host OS, Storage & Hardware](#5-node-01-debian-eos--100010--host-os-storage--hardware)
4. [Section 6: Node-01 (`debian-eos`) — Docker Engine & Application Stack](#6-node-01-debian-eos--100010--docker-engine--application-stack)
5. [Section 7: Node-02 (`proxmox`) — Hypervisor & Hardware](#7-node-02-proxmox--atlas--100020--hypervisor--hardware)
6. [Section 8: VM 100 (`windows-server-2022-dionysus`) — AD DS, DNS, IIS & WSL](#8-vm-100-windows-server-2022-dionysus--100030--ad-ds-dns-iis--wsl)
7. [Section 9: Quarterly & Semi-Annual Maintenance Procedures](#9-quarterly--semi-annual-maintenance-procedures)
8. [Section 10: Post-Maintenance Verification & Sign-Off](#10-post-maintenance-verification--sign-off)

---

## 3. Pre-Maintenance & Backup Verification

Do not apply system or container updates until all recent backup archives are verified and pre-maintenance snapshots are completed.

### 3.1 Node-01 Nightly USB Backup (`03:00` Cron)
Target: `ssh luca@10.0.0.10`

- [ ] **Inspect Dashboard Backup Status JSON & Cron Logs:**
  ```bash
  cat /srv/docker/dashboard/html/data/backup-status.json
  sudo journalctl -u cron --since "48 hours ago" | grep -i "backup"
  sudo tail -n 40 /var/log/backup.log 2>/dev/null || sudo tail -n 40 /var/log/homelab-backup.log 2>/dev/null
  ```
  *Acceptance Criteria:* `"status": "success"`, timestamp corresponds to `03:00` today, `"attempt": 1`.

- [ ] **Mount External USB Backup Drive (`Axagon EE35-XA3`) & Audit Snapshots:**
  > **Note:** `backup.sh` automatically unmounts `/mnt/backup` upon completion (`trap cleanup EXIT`) to keep the backup partition offline and protected when idle. Navigating to `/mnt/backup` without mounting the drive first will show an empty directory. Always run `cd ~` before mounting or unmounting; if your shell is already inside `/mnt/backup` when `mount` is executed, the shell remains attached to the underlying empty mountpoint inode.

  ```bash
  # Ensure shell is outside /mnt/backup before mounting
  cd ~

  # Rescan SCSI/USB bus (in case the drive spun down) and mount read-only for inspection
  for host in /sys/class/scsi_host/host*/scan; do [ -f "$host" ] && echo "- - -" | sudo tee "$host" >/dev/null; done
  sudo mkdir -p /mnt/backup
  sudo mount -o ro /dev/disk/by-uuid/7452da95-ed38-481f-9331-b341d36fe0e5 /mnt/backup

  # Verify disk utilization, 30-day snapshot rotation, latest snapshot contents, and SQL dump size
  df -h /mnt/backup
  ls -lh /mnt/backup/homelab-backups/
  ls -lh /mnt/backup/homelab-backups/latest/
  ls -lh /mnt/backup/homelab-backups/latest/database-dumps/

  # Step out of /mnt/backup and unmount cleanly after inspection
  cd ~
  sudo umount /mnt/backup
  ```
  *Acceptance Criteria:* `nextcloud_database.sql` is present and non-zero; 30-day retention window is intact; `latest` symlink resolves to the most recent snapshot; partition unmounts cleanly.

- [ ] **Execute Manual Pre-Maintenance Backup (Recommended Prior to Major Upgrades):**
  ```bash
  sudo /srv/docker/backup/backup.sh
  ```

### 3.2 GitHub-to-GitLab Nightly Mirror (`02:00` Cron)
Target: `ssh luca@10.0.0.10`

- [ ] **Inspect Mirror Execution Log:**
  ```bash
  tail -n 50 /var/log/github-backup.log
  ```
  *Acceptance Criteria:* Log concludes with `backup completed successfully!` with no HTTP `401`/`403` token errors or repository ownership exceptions.

- [ ] **Verify Mirrored Repository Count:**
  ```bash
  ls -1 /srv/docker/gitlab-backup/repos/ | wc -l
  ```

### 3.3 MacBook-to-Nextcloud Daily Sync Verification (`20:00` LaunchAgent)
Target: Management Workstation (`MacBook`)

> **Note:** On macOS, the Nextcloud menu bar icon can report *Up to date* even when the `FileProviderExt` virtual filesystem (`~/Library/CloudStorage/Nextcloud-...`) has failed to upload individual files (`isUploaded = 0`, `NSFileProviderErrorDomain Code=-2005`) during server downtime. `/Users/luca/bin/nextcloud-backup.sh` now checks `https://nc.olympus-luca.online/status.php` prior to copying and verifies `isUploaded = 1` via `fileproviderctl evaluate` afterward, raising a macOS alert if any file remains un-uploaded.

- [ ] **Inspect MacBook Nextcloud Backup Log & Trigger Verification:**
  ```bash
  tail -n 30 /Users/luca/Library/Logs/nextcloud-backup.log
  /Users/luca/bin/nextcloud-backup.sh
  ```
  *Acceptance Criteria:* Script exits with `0` and logs `INFO  : All Documents synced and verified as uploaded on nc.olympus-luca.online.` with zero `isUploaded=0` or `resource deadlock avoided` errors.

### 3.4 VM 100 (`windows-server-2022-dionysus`) Snapshot & Off-Node Backup
Target: `ssh root@10.0.0.20`

- [ ] **Create Pre-Maintenance Proxmox Snapshot:**
  ```bash
  qm snapshot 100 "pre-maint-$(date +%Y%m%d)" --description "Monthly maintenance snapshot $(date +%Y-%m-%d)"
  qm listsnapshot 100
  ```

- [ ] **Generate Compressed VM Archive (`vzdump`) & Replicate to Node-01:**
  ```bash
  # Create compressed backup archive in /var/lib/vz/dump
  vzdump 100 --mode snapshot --compress zstd --dumpdir /var/lib/vz/dump

  # Transfer latest archive to Node-01 /srv for inclusion in nightly USB backup
  LATEST_DUMP=$(ls -t /var/lib/vz/dump/vzdump-qemu-100-*.vma.zst | head -n 1)
  scp "$LATEST_DUMP" luca@10.0.0.10:/srv/docker/backup/

  # Prune local Node-02 archives older than 14 days to conserve NVMe capacity
  find /var/lib/vz/dump/ -name "vzdump-qemu-100-*" -mtime +14 -delete
  ```

### 3.5 Network Appliance Configuration Backups
- [ ] **Export MikroTik hEX S (`10.0.0.1`) Configuration:**
  Execute in RouterOS CLI (`ssh admin@10.0.0.1` or WebFig Terminal):
  ```routeros
  /system backup save name=olympus-monthly
  /export show-sensitive file=olympus-monthly-config
  /file print
  ```
  From Node-01 (`10.0.0.10`), retrieve the exported files into `/srv/docker/backup/network-configs/`:
  ```bash
  mkdir -p /srv/docker/backup/network-configs
  scp admin@10.0.0.1:olympus-monthly.backup "/srv/docker/backup/network-configs/mikrotik-$(date +%Y-%m).backup"
  scp admin@10.0.0.1:olympus-monthly-config.rsc "/srv/docker/backup/network-configs/mikrotik-$(date +%Y-%m).rsc"
  ```
- [ ] **Export TP-Link TL-SG108E (`10.0.0.2`) Configuration (If Modified):**
  Access `https://switch.home.olympus-luca.online` -> **System** -> **System Tools** -> **Backup and Restore** -> click **Backup Config** to download the `.cfg` file to your Mac, then optionally copy it to Node-01:
  ```bash
  scp ~/Downloads/TL-SG108E*.cfg "luca@10.0.0.10:/srv/docker/backup/network-configs/tplink-switch-$(date +%Y-%m).cfg"
  ```

---

## 4. Network Layer, DNS & Remote Access (`10.0.0.0/24`)

### 4.1 MikroTik hEX S (`10.0.0.1`) Health & Firmware
Target: `ssh admin@10.0.0.1`

- [ ] **Audit CPU, Memory & 16MB Flash Storage Utilization:**
  ```routeros
  /system resource print
  /system health print
  ```
  *Acceptance Criteria:* `free-hdd-space` on the 16MB internal flash must exceed **2.5 MiB**. Remove stale `.backup` or `.rsc` files via `/file remove` if free space is below threshold.

- [ ] **Verify Firewall Isolation & NAT Rules:**
  ```routeros
  /ip firewall filter print stats
  /ip firewall nat print stats
  ```
  *Acceptance Criteria:*
  - `drop homelab to parent LAN` (`bridge-olympus` -> `192.168.1.0/24`) is enabled and ordered prior to `defconf: drop all from WAN`.
  - `drop incoming from home router` (`input` on `ether1`) and `drop unsolicited from home router` (`forward` on `ether1`) are enabled.
  - `olympus NAT outbound` (`masquerade` on `ether1`) is enabled.

- [ ] **Verify Static Local DNS Records:**
  ```routeros
  /ip dns static print
  ```
  *Acceptance Criteria:* Explicit static A records resolve `router.home.`, `switch.home.`, `pve.home.`, `home.`, `gitlab.home.`, `npm.home.`, `nd.home.`, and `nc-aio.home.` to `10.0.0.10`, and `dionysus.home.` to `10.0.0.30`, with no wildcard rule overriding `dionysus.home.`.

- [ ] **Review DHCP Leases & System Logs:**
  ```routeros
  /ip dhcp-server lease print
  /log print where topics~"error|warning|critical"
  ```

- [ ] **Check RouterOS & RouterBOARD Firmware Updates:**
  ```routeros
  /system package update check-for-updates
  # To apply a stable RouterOS update (requires router reboot):
  # /system package update install
  # After reboot, verify RouterBOARD firmware alignment:
  /system routerboard print
  # If current-firmware != upgrade-firmware:
  # /system routerboard upgrade
  # /system reboot
  ```

### 4.2 TP-Link TL-SG108E Switch (`10.0.0.2`)
- [ ] **Verify Port Negotiation & Packet Error Counters:**
  Access `https://switch.home.olympus-luca.online`:
  - **Monitoring** -> **Port Statistics**: Confirm Ports 1 (MikroTik), 2 (Node-01), and 3 (Node-02) operate at **1000Mbps Full Duplex (`1000M Full`)** with zero `RxBadPkts` / `TxBadPkts`.
  - **Monitoring** -> **Loop Prevention**: Confirm Loop Prevention is **Enabled**.

### 4.3 Tailscale Subnet Router (Node-01 `10.0.0.10`)
Target: `ssh luca@10.0.0.10`

- [ ] **Verify Tailscale Daemon Status & Machine Key Expiry:**
  ```bash
  sudo tailscale status
  tailscale netcheck
  ```
  *Acceptance Criteria:* In the [Tailscale Admin Console](https://login.tailscale.com/admin/machines), confirm `debian-eos` (`100.80.227.117`) has key expiry disabled (or > 30 days remaining) and subnet route `10.0.0.0/24` is approved.

- [ ] **Verify Kernel Packet Forwarding & `iptables` Rules:**
  ```bash
  sysctl net.ipv4.ip_forward net.ipv6.conf.all.forwarding
  sudo iptables -S FORWARD | grep tailscale0
  sudo iptables -t nat -S POSTROUTING | grep enp2s0f1
  ```
  *Acceptance Criteria:* Both sysctl keys return `1`; `FORWARD` permits `tailscale0` ingress/egress; `POSTROUTING` masquerades outbound traffic on `enp2s0f1`. If absent, re-apply and persist:
  ```bash
  sudo iptables -I INPUT -i tailscale0 -j ACCEPT
  sudo iptables -I FORWARD -i tailscale0 -j ACCEPT
  sudo iptables -I FORWARD -o tailscale0 -j ACCEPT
  sudo iptables -t nat -I POSTROUTING -o enp2s0f1 -j MASQUERADE
  sudo netfilter-persistent save
  ```

### 4.4 Cloudflare Tunnel (`cloudflared-nextcloud` on Node-01)
Target: `ssh luca@10.0.0.10`

- [ ] **Verify Tunnel Container Status & Edge Registration:**
  ```bash
  sudo docker ps --filter "name=cloudflared-nextcloud"
  sudo docker logs cloudflared-nextcloud --tail 25
  ```
  *Acceptance Criteria:* Container status is `Up` with active edge connections registered.

- [ ] **Audit Tunnel Credential Permissions & Ingress Configuration:**
  ```bash
  ls -ld "$HOME/.cloudflared"
  ls -l "$HOME/.cloudflared"
  cat "$HOME/.cloudflared/config.yml"
  ```
  *Acceptance Criteria:* Directory permissions are `700` (`drwx------`), credential files are `600` (`-rw-------`), and `config.yml` routes exclusively `nc.olympus-luca.online` (`10.0.0.10:11000`) and `web.olympus-luca.online` (`10.0.0.10:8088`) with catch-all `http_status:404`.

- [ ] **Update `cloudflared` Container Image:**
  ```bash
  sudo docker pull cloudflare/cloudflared:latest
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

---

## 5. Node-01 (`debian-eos` - `10.0.0.10`) — Host OS, Storage & Hardware

Target: `ssh luca@10.0.0.10`

### 5.1 CPU, Load Average, Memory & Swap Audit
- [ ] **Inspect Resource Utilization:**
  ```bash
  uptime
  free -h
  ps aux --sort=-%cpu | head -n 10
  ps aux --sort=-%mem | head -n 10
  ```
  *Acceptance Criteria (Intel Core i3-4010U 2C/4T, 8GB RAM):*
  - 15-minute load average is **< 3.5**.
  - Swap utilization is **< 500 MB**.
  - No unthrottled `ffmpeg` worker processes or runaway `dockerd` log consumers.

### 5.2 Storage Utilization, LVM Integrity & SMART Diagnostics
- [ ] **Check Filesystem Capacity & Inode Utilization:**
  ```bash
  df -h / /boot/efi /srv
  df -i / /srv
  ls -ld /var/lib/containerd
  ```
  *Acceptance Criteria:*
  - Root SSD (`/`, `vg_system-lv_root` 46.6GB) utilization is **< 50%**.
  - `/var/lib/containerd` resolves as a symbolic link to `/srv/containerd`.
  - Data HDD (`/srv`, `vg_data-lv_storage` 698.6GB) utilization is **< 80%**.

- [ ] **Verify LVM Volume Group & Logical Volume Health:**
  ```bash
  sudo pvs
  sudo vgs
  sudo lvs
  ```
  *Acceptance Criteria:* `vg_system` maps exclusively to `/dev/sda2` (internal SSD); `vg_data` maps exclusively to `/dev/sdb1` (internal SATA HDD) with no external USB physical volumes attached.

- [ ] **Inspect `/srv/lost+found` for Orphaned Inodes:**
  ```bash
  sudo ls -la /srv/lost+found
  ```
  *Acceptance Criteria:* Directory contains no recovered `#inode` entries.

- [ ] **Execute SMART Health Assessments Across All Physical Disks:**
  ```bash
  # Ensure smartmontools is installed: sudo apt install -y smartmontools
  # 1. Internal Kingston 240GB SSD (OS)
  sudo smartctl -H -A /dev/sda
  # 2. Internal Samsung 750GB SATA HDD (/srv)
  sudo smartctl -H -A /dev/sdb
  # 3. External 465GB USB Backup HDD
  sudo smartctl -H -A /dev/backup-disk || sudo smartctl -d sat -H -A /dev/backup-disk
  ```
  *Acceptance Criteria:*
  - `SMART overall-health self-assessment test result: PASSED`
  - `Reallocated_Sector_Ct`: `0` (or stable baseline)
  - `Current_Pending_Sector`: `0`
  - `Offline_Uncorrectable`: `0`
  - Operating temperature: `< 50°C`

### 5.3 Debian 13 Package Updates & Log Maintenance
- [ ] **Review Unattended Upgrades Log:**
  ```bash
  sudo tail -n 30 /var/log/unattended-upgrades/unattended-upgrades.log
  ```

- [ ] **Apply APT Package Upgrades & Purge Obsolete Dependencies:**
  ```bash
  sudo apt update
  sudo apt list --upgradable
  sudo apt full-upgrade -y
  sudo apt autoremove --purge -y
  sudo apt clean
  ```

- [ ] **Vacuum Systemd Journal Archives:**
  ```bash
  sudo journalctl --disk-usage
  sudo journalctl --vacuum-time=14d --vacuum-size=500M
  ```

- [ ] **Check Pending Reboot Requirement:**
  ```bash
  [ -f /var/run/reboot-required ] && cat /var/run/reboot-required || echo "No reboot required"
  ```

### 5.4 Host Security, Firewall, Power Management & Netdata
- [ ] **Audit Listening Network Sockets:**
  ```bash
  sudo ss -tulpen
  ```

- [ ] **Verify UFW & `ufw-docker` Rulesets:**
  ```bash
  sudo ufw status verbose
  sudo ufw-docker status
  ```
  *Acceptance Criteria:* Host rules allow `22/tcp` (SSH), `2222/tcp` (GitLab SSH), and `19999/tcp` (Netdata); `ufw-docker` rules remain intact for `homelab-dashboard`, `gitlab`, and `npm`.

- [ ] **Review Failed SSH Authentication Events:**
  ```bash
  sudo journalctl -u ssh --since "30 days ago" | grep -iE "failed|invalid" | tail -n 20
  ```

- [ ] **Verify Sleep Target Masking & Wake-on-LAN Configuration (`enp2s0f1`):**
  ```bash
  systemctl status sleep.target suspend.target hibernate.target | grep Loaded
  sudo ethtool enp2s0f1 | grep -i "Wake-on"
  ```
  *Acceptance Criteria:* Sleep targets are `masked (/dev/null)` and NIC reports `Wake-on: g`.

- [ ] **Verify Netdata Telemetry Daemon (`nd.home.olympus-luca.online`):**
  ```bash
  sudo systemctl status netdata --no-pager
  ```

---

## 6. Node-01 (`debian-eos` - `10.0.0.10`) — Docker Engine & Application Stack

Target: `ssh luca@10.0.0.10`

### 6.1 Docker Engine & Container Log Rotation Audit
- [ ] **Verify Container States:**
  ```bash
  sudo docker ps -a
  ```
  *Acceptance Criteria:* All production containers report `Up` (and `healthy` where healthchecks are defined) with zero exited or crash-looping instances.

- [ ] **Verify Container JSON Log Rotation Enforcement (`max-size: 10m`, `max-file: 3`):**
  ```bash
  cat /etc/docker/daemon.json
  sudo find /srv/docker-data/containers/ -name "*-json.log" -exec ls -lh {} +
  ```
  *Acceptance Criteria:* `/etc/docker/daemon.json` specifies `"data-root": "/srv/docker-data"` and `"log-opts": {"max-size": "10m", "max-file": "3"}`. No container log file exceeds `10M`.

### 6.2 Nextcloud AIO (`nc.olympus-luca.online`)
- [ ] **Update Nextcloud AIO Containers:**
  Access `https://nc-aio.home.olympus-luca.online` (or via local port forward `ssh -L 8080:localhost:8080 luca@10.0.0.10` -> `https://localhost:8080`):
  - Check for pending Mastercontainer or sub-container updates.
  - If updates are available, select **Stop containers** -> **Update containers** -> **Start containers**.

- [ ] **Execute Nextcloud `occ` Database & Filesystem Maintenance:**
  ```bash
  # 1. Verify application status
  sudo docker exec -u www-data nextcloud-aio-nextcloud php occ status

  # 2. Apply any pending schema indices, columns, or primary keys
  sudo docker exec -u www-data nextcloud-aio-nextcloud php occ db:add-missing-indices
  sudo docker exec -u www-data nextcloud-aio-nextcloud php occ db:add-missing-columns
  sudo docker exec -u www-data nextcloud-aio-nextcloud php occ db:add-missing-primary-keys

  # 3. Reconcile file cache and purge orphaned entries
  sudo docker exec -u www-data nextcloud-aio-nextcloud php occ files:scan --all
  sudo docker exec -u www-data nextcloud-aio-nextcloud php occ files:cleanup

  # 4. Expire aged trashbin items and file versions
  sudo docker exec -u www-data nextcloud-aio-nextcloud php occ trashbin:expire
  sudo docker exec -u www-data nextcloud-aio-nextcloud php occ versions:expire

  # 5. Confirm video preview generation (OC\Preview\Movie) remains disabled
  sudo docker exec -u www-data nextcloud-aio-nextcloud php occ config:system:get enabledPreviewProviders
  ```
  *Acceptance Criteria:* `OC\Preview\Movie` is absent from `enabledPreviewProviders`.

- [ ] **Update PostgreSQL Planner Statistics (`ANALYZE`):**
  ```bash
  sudo docker exec nextcloud-aio-database vacuumdb -U oc_nextcloud -d nextcloud_database --analyze-only
  ```

### 6.3 GitLab CE (`gitlab.home.olympus-luca.online`)
- [ ] **Inspect Internal Omnibus Runit Services:**
  ```bash
  sudo docker exec -it gitlab gitlab-ctl status
  ```
  *Acceptance Criteria:* All 10 internal services (`gitaly`, `gitlab-exporter`, `gitlab-kas`, `gitlab-workhorse`, `logrotate`, `nginx`, `postgresql`, `puma`, `redis`, `sidekiq`) report `run:` state.

- [ ] **Run GitLab Diagnostic Suite & Audit Backup Retention:**
  ```bash
  sudo docker exec -it gitlab gitlab-rake gitlab:check SANITIZE=true
  ls -lh /srv/docker/gitlab/data/backups/
  ```
  *Acceptance Criteria:* `gitlab:check` completes without error; `/srv/docker/gitlab/data/backups/` retains only archives within the 7-day window (`backup_keep_time = 604800`).

- [ ] **Update GitLab CE Image:**
  ```bash
  cd /srv/docker/gitlab
  sudo docker compose pull
  sudo docker compose up -d
  ```
  *Post-Update Check:* Allow 2–3 minutes for Puma Single Mode (`worker_processes = 0`) initialization on HDD storage, then confirm HTTP readiness:
  ```bash
  sudo docker exec -it gitlab gitlab-ctl status
  curl -I http://127.0.0.1:8085/users/sign_in
  ```

### 6.4 Nginx Proxy Manager (`npm.home.olympus-luca.online`) & TLS Certificates
- [ ] **Audit Let's Encrypt Wildcard Certificate Validity:**
  Access `https://npm.home.olympus-luca.online` -> **SSL Certificates**:
  - Verify `*.olympus-luca.online` and `*.home.olympus-luca.online` certificates have **> 30 days** remaining validity.
  - If `< 30 days`, trigger **Renew Now** to validate Cloudflare DNS-01 API token functionality.

- [ ] **Update Nginx Proxy Manager Container:**
  ```bash
  cd /srv/docker/npm
  sudo docker compose pull
  sudo docker compose up -d
  ```

### 6.5 Olympus Dashboard (`:8000`) & Personal Website (`:8088`)
- [ ] **Verify Dashboard Telemetry Cron (`*/5`):**
  ```bash
  cat /srv/docker/dashboard/html/data/status.json | head -n 15
  ```
  *Acceptance Criteria:* `"generated"` timestamp is within 5 minutes of current system time.

- [ ] **Update Web Server Containers:**
  ```bash
  cd /srv/docker/dashboard && sudo docker compose pull && sudo docker compose up -d
  cd /srv/docker/personal-website && sudo docker compose up -d --build
  ```

### 6.6 Docker Image Cleanup
- [ ] **Prune Dangling Images After Service Verification:**
  ```bash
  sudo docker image prune -f
  ```
  > **Caution:** Never execute `docker volume prune` or `docker system prune --volumes` on Node-01. Nextcloud AIO persists critical state inside named Docker volumes (`nextcloud_aio_*`).

---

## 7. Node-02 (`proxmox` / Atlas - `10.0.0.20`) — Hypervisor & Hardware

Target: `ssh root@10.0.0.20` (or via Proxmox Web UI at `https://pve.home.olympus-luca.online`)

### 7.1 Storage Pools (`local` & `local-lvm`) & NVMe SMART Diagnostics
- [ ] **Check Proxmox Storage & LVM Thin-Pool Utilization:**
  ```bash
  pvesm status
  df -h /
  lvs -a
  ```
  *Acceptance Criteria:* `local-lvm` data allocation is **< 80%** and thin-pool metadata allocation (`Meta%`) is **< 50%**.

- [ ] **Audit 256GB NVMe SSD (`/dev/nvme0n1`) SMART Telemetry:**
  ```bash
  smartctl -a /dev/nvme0n1
  ```
  *Acceptance Criteria:*
  - `SMART overall-health self-assessment test result: PASSED`
  - `Percentage Used`: `< 10%`
  - `Media and Data Integrity Errors`: `0`
  - `Temperature`: `< 55°C`

### 7.2 Intel i219LM (`e1000e`) NIC Stability & Wake-on-LAN Interface Verification
- [ ] **Inspect Kernel Ring Buffer for `e1000e` Hardware Unit Hangs:**
  ```bash
  journalctl -b --grep="nic0|eno1|e1000e|Hang"
  ```
  *Acceptance Criteria:* Zero `Detected Hardware Unit Hang` events logged since boot.

- [ ] **Verify GRUB Kernel Parameters & `ethtool` Offload Settings:**
  ```bash
  cat /proc/cmdline
  ethtool -g nic0 2>/dev/null || ethtool -g eno1
  ethtool -k nic0 2>/dev/null | grep -E "tcp-segmentation-offload|generic-segmentation-offload|generic-receive-offload" || ethtool -k eno1 | grep -E "tcp-segmentation-offload|generic-segmentation-offload|generic-receive-offload"
  ```
  *Acceptance Criteria:* `/proc/cmdline` contains `pcie_aspm=off e1000e.SmartPowerDownEnable=0`; RX/TX ring buffers are `4096`; `tso`, `gso`, and `gro` report `off`.

- [ ] **Verify Direct-Link USB Ethernet Adapter for Node-01 Wake-on-LAN:**
  ```bash
  ip -br link show
  ```
  *Acceptance Criteria:* Secondary USB Ethernet interface (`enxc84d4428bc43`) is present.

### 7.3 Proxmox VE Package Upgrades (No-Subscription Repository)
- [ ] **Apply Hypervisor Updates:**
  ```bash
  apt update
  apt list --upgradable
  apt dist-upgrade -y
  apt autoremove -y
  ```
  *Note:* Always use `apt dist-upgrade` (or `pveupgrade`) on Proxmox VE. If a new `proxmox-kernel-*` package is installed, schedule a hypervisor reboot after completing Section 8.

---

## 8. VM 100 (`windows-server-2022-dionysus` - `10.0.0.30`) — AD DS, DNS, IIS & WSL

Target: `ssh Administrator@10.0.0.30` (or via RDP at `dionysus.home.olympus-luca.online:3389`) in an **Elevated PowerShell** session.

### 8.1 System Capacity, Uptime & Core Windows Services
- [ ] **Check System Partition (`C:`) Free Space & Uptime:**
  ```powershell
  Get-PSDrive C | Select-Object Used, Free, @{Name="FreeGB";Expression={[math]::Round($_.Free/1GB,2)}}
  (Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime
  ```
  *Acceptance Criteria:* Free space on `C:` (70GB VirtIO disk) exceeds **15 GB**.

- [ ] **Verify Core Infrastructure Services:**
  ```powershell
  Get-Service NTDS, DNS, Netlogon, W32Time, W3SVC, sshd, TermService | Format-Table Name, Status, StartType -AutoSize
  ```
  *Acceptance Criteria:* All 7 services report `Running` with `Automatic` startup type.

### 8.2 Active Directory Domain Services (`ad.home.olympus-luca.online` / `DIONYSUS`)
- [ ] **Execute Domain Controller Diagnostics (`dcdiag`):**
  ```powershell
  dcdiag /q
  ```
  *Acceptance Criteria:* Command returns no output (`dcdiag /q` outputs only failed tests). If errors appear, run `dcdiag /v` to isolate the failing test.

- [ ] **Verify SYSVOL, Netlogon Shares & DC Locator:**
  ```powershell
  net share
  nltest /dsgetdc:ad.home.olympus-luca.online
  ```
  *Acceptance Criteria:* `SYSVOL` and `NETLOGON` shares are published; DC locator resolves `10.0.0.30` (`\\WINDOWS-SERVER-DIONYSUS`).

- [ ] **Inspect Directory Service & System Event Logs:**
  ```powershell
  Get-EventLog -LogName "Directory Service" -EntryType Error,Warning -Newest 15
  Get-EventLog -LogName "System" -EntryType Error -Newest 15
  ```

### 8.3 Windows DNS Server & Network Interface Audit
- [ ] **Verify IPv4 Binding (`10.0.0.30`) & DNS Client Configuration:**
  ```powershell
  Get-NetIPAddress -InterfaceAlias "Team1" -AddressFamily IPv4 | Select-Object IPAddress, PrefixLength
  Get-DnsClientServerAddress -InterfaceAlias "Team1" -AddressFamily IPv4
  ```
  *Acceptance Criteria:* `Team1` (NIC Teaming combining `Ethernet` + `Ethernet 3` at 20 Gbps) is bound to `10.0.0.30/24`; DNS servers are `127.0.0.1` (primary) and `10.0.0.1` (secondary).

- [ ] **Audit Active Directory DNS Zone Records:**
  ```powershell
  Get-DnsServerResourceRecord -ZoneName "ad.home.olympus-luca.online" -RRType A
  Resolve-DnsName ad.home.olympus-luca.online
  ```
  *Acceptance Criteria:* All domain A records resolve to `10.0.0.30`.

### 8.4 IIS Web Server & Security Log Audit
- [ ] **Verify IIS Websites & Application Pools:**
  ```powershell
  Import-Module WebAdministration
  Get-Website | Format-Table Name, State, PhysicalPath, Bindings -AutoSize
  Get-ChildItem IIS:\AppPools | Format-Table Name, State -AutoSize
  ```

- [ ] **Audit Failed Authentication Events (Event ID `4625`):**
  ```powershell
  Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625; StartTime=(Get-Date).AddDays(-30)} -MaxEvents 20 -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, @{N='Account';E={$_.Properties[5].Value}}, @{N='SourceIP';E={$_.Properties[19].Value}}
  ```

### 8.5 Windows Server Updates & Component Store Cleanup
- [ ] **Install Monthly Cumulative Updates & Clean WinSxS Store:**
  Run `sconfig` (Option `6` -> `1` All updates) or install via Windows Update GUI, rebooting VM 100 if required. Perform component store cleanup:
  ```powershell
  dism.exe /Online /Cleanup-Image /StartComponentCleanup
  ```

### 8.6 Ubuntu 22.04 WSL2 Distribution Maintenance
- [ ] **Apply Ubuntu Package Updates Inside WSL:**
  ```powershell
  wsl --status
  wsl -d Ubuntu -u root -- bash -c "apt update && apt full-upgrade -y && apt autoremove --purge -y && apt clean"
  ```

### 8.7 Post-Update Proxmox Snapshot Cleanup
Target: `ssh root@10.0.0.20`

- [ ] **Remove Temporary Pre-Maintenance Snapshot After VM 100 Verification:**
  ```bash
  qm listsnapshot 100
  qm delsnapshot 100 "pre-maint-$(date +%Y%m%d)"
  ```

---

## 9. Quarterly & Semi-Annual Maintenance Procedures

Execute the following deep-maintenance tasks once every quarter (January, April, July, October).

### 9.1 Backup Restore Validation Drill (Quarterly)
- [ ] **File-Level Restore Test (Node-01):**
  Mount `/dev/backup-disk` read-only at `/mnt/backup`, copy a sample configuration file from `/mnt/backup/homelab-backups/latest/srv-docker/` to `/tmp/restore-test/`, verify checksum (`sha256sum`) against the live file in `/srv/docker/`, remove `/tmp/restore-test/`, and unmount `/mnt/backup`.
- [ ] **Nextcloud PostgreSQL Dump Verification:**
  ```bash
  head -n 30 /mnt/backup/homelab-backups/latest/database-dumps/nextcloud_database.sql
  tail -n 20 /mnt/backup/homelab-backups/latest/database-dumps/nextcloud_database.sql
  ```
  *Acceptance Criteria:* Dump file header is valid SQL and footer concludes with `-- PostgreSQL database cluster dump complete`.
- [ ] **GitLab Repository Clone Test:**
  Clone a mirrored repository via `https://gitlab.home.olympus-luca.online/root/<repo>.git` or `ssh://git@10.0.0.10:2222/root/<repo>.git` into a temporary directory to verify Gitaly storage integrity.

### 9.2 Credential, Token & Access Review (Quarterly)
- [ ] **GitHub & GitLab Personal Access Tokens:**
  Audit expiration dates for `GITHUB_TOKEN` and `GITLAB_TOKEN` defined in `/srv/docker/github-backup/backup.env` on Node-01. Rotate tokens prior to expiration.
- [ ] **Cloudflare API Token & Tunnel Origin Certificate:**
  Verify validity of the Cloudflare API token configured in Nginx Proxy Manager and origin credentials in `$HOME/.cloudflared/`.
- [ ] **Nextcloud Account & 2FA Review:**
  Confirm all user accounts enforce TOTP 2FA, adhere to storage quotas, and have no unrecognized active sessions.

### 9.3 Physical, Thermal & Hardware Inspection (Every 3–6 Months)
- [ ] **Node-01 (`debian-eos` — ASUS X550LB):**
  - **Battery Safety Inspection:** Given the degraded internal lithium-ion battery (~48% health), physically inspect the laptop chassis and trackpad for any mechanical swelling or abnormal thermal output.
  - **Thermal Maintenance:** Clear dust accumulation from CPU heatsink fins and fan exhaust vents.
  - **External Storage Enclosure (`Axagon EE35-XA3`):** Verify USB 3.0 data cable seating, DC power connection, and confirm the hardware power rocker switch remains in the `I (ON)` position.
- [ ] **Node-02 (`proxmox` — HP EliteDesk 800 G4) & Network Appliances:**
  - Clear dust from the HP EliteDesk intake bezel and rear exhaust vents.
  - Verify physical RJ45 latch integrity across MikroTik hEX S (`ether1`–`ether3`) and TP-Link Switch (`Ports 1–3`).

### 9.4 Cold-Boot & Wake-on-LAN Recovery Drill (Semi-Annual)
- [ ] Validate automated recovery sequence from a cold power state:
  1. MikroTik hEX S and TP-Link Switch initialize L2/L3 routing and WAN NAT within 60 seconds.
  2. Node-02 powers on automatically via BIOS AC power recovery and starts VM 100 (`onboot: 1`).
  3. Node-02 transmits a Wake-on-LAN magic packet via `enxc84d4428bc43` (`wakeonlan` / `etherwake`) to wake Node-01 (`enp2s0f1`).
  4. Node-01 mounts `/srv`, initializes all Docker containers, establishes the Cloudflare Tunnel, and advertises `10.0.0.0/24` over Tailscale.

---

## 10. Post-Maintenance Verification & Sign-Off

Execute the following verification script from the management workstation (MacBook) at the conclusion of maintenance to confirm end-to-end reachability and service readiness:

```bash
echo "=== 1. ICMP Reachability Sweep (10.0.0.0/24) ==="
for ip in 10.0.0.1 10.0.0.2 10.0.0.10 10.0.0.20 10.0.0.30; do
  ping -c 1 -W 1000 "$ip" >/dev/null 2>&1 && echo "[OK] $ip reachable" || echo "[FAIL] $ip unreachable"
done

echo -e "\n=== 2. Internal HTTPS Service Endpoints ==="
urls=(
  "https://home.olympus-luca.online"
  "https://gitlab.home.olympus-luca.online/users/sign_in"
  "https://npm.home.olympus-luca.online"
  "https://nd.home.olympus-luca.online"
  "https://pve.home.olympus-luca.online"
  "https://router.home.olympus-luca.online"
  "https://switch.home.olympus-luca.online"
)
for url in "${urls[@]}"; do
  code=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time 5 "$url")
  echo "[$code] $url"
done

echo -e "\n=== 3. Public Cloudflare Tunnel Endpoints ==="
pub_urls=(
  "https://nc.olympus-luca.online/login"
  "https://web.olympus-luca.online"
)
for url in "${pub_urls[@]}"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 "$url")
  echo "[$code] $url"
done

echo -e "\n=== 4. Windows Server AD / DNS / SSH / RDP Port Verification ==="
for port in 22 53 80 389 3389; do
  nc -zv -G 2 10.0.0.30 "$port" 2>&1 | grep -E "succeeded|open"
done
```

---

## 11. Maintenance Log

### 2026-10-25 — Comprehensive Homelab Maintenance & Remediation
- Fixed nightly USB backup script by adding `--bwlimit=35000` and `ionice -c2 -n7` to prevent saturating the SATA bus of the internal 750GB HDD; full incremental run completed cleanly (132GB snapshot, 251GB used on USB).
- Verified Nextcloud database dump (`pg_dumpall --no-role-passwords`) produces a complete 126MB SQL archive.
- Confirmed recent iPhone photos and videos (including Oct 22-23 media) are backed up on the external USB drive (`/mnt/backup/homelab-backups/latest`).
- Diagnosed and permanently resolved an ACPI interrupt storm on Node-01 (`gpe0A`) that generated over 53 million interrupts and locked 1000+ `kworker` processes in uninterruptible sleep (`D`); created and enabled `/etc/systemd/system/disable-gpe0A.service`, reducing load average from 1025+ to ~0.30.
- Upgraded Nextcloud AIO from v33.0.8.2 to v34.0.5.1; cleared `update.failed` lock, updated database schema, executed `occ db:add-missing-indices`, and performed full file scan across all 5 users with zero errors.
- Disabled resource-heavy video preview generation (`OC\Preview\Movie`) on Node-01 to protect CPU and disk I/O during mobile photo/video uploads.
- Truncated an unrotated 11GB Docker container JSON log file, recovering significant storage on `/srv`.
- Upgraded GitLab CE container to `latest` (`Up (healthy)`); verified all 10 internal services (`puma`, `sidekiq`, `gitaly`, `postgresql`, `redis`, etc.) are running.
- Fixed GitHub-to-GitLab mirror script (`backup-github.sh`) by filtering on owner affiliation, enabling branch force-pushes, and using head/tag refspecs to sync amended branches (`Go`, `BetterTown`).
- Fixed reverse proxy configuration for TP-Link TL-SG108E switch in Nginx Proxy Manager (`11.conf`) by stripping oversized headers and forwarding only `H_P_SSID` cookie, restoring Web GUI access at `https://switch.home.olympus-luca.online`.
- Pulled and restarted `cloudflared-nextcloud` on `latest` image with QUIC protocol active across redundant edge connections (Bucharest & Frankfurt).
- Renewed all Let's Encrypt wildcard SSL certificates (`*.home.olympus-luca.online`) in Nginx Proxy Manager for a fresh 90-day period.
- Audited SMART health across all storage drives: Node-01 Kingston SSD (79% life left, 0 bad blocks, 26°C), Samsung 750GB HDD (0 bad sectors, identified UDMA CRC errors for cable replacement), external USB backup HDD (passed, 37°C), and Node-02 WD SN530 NVMe (98% life left, 0 integrity errors, 31°C).
- Verified Node-02 Proxmox hypervisor stability, confirming Intel `e1000e` NIC hang mitigations (`pcie_aspm=off`, `SmartPowerDownEnable=0`, RX/TX ring buffers at 4096, TSO/GSO/GRO disabled).
- Audited VM 100 (Windows Server 2022 Domain Controller): enabled and started `IsmServ`, resolved DFSR Event 2214 recovery, verified SYSVOL/NETLOGON shares, and validated 20 Gbps VirtIO NIC Teaming (`Team1`).
- Cleaned stale/phantom DNS records (`10.0.0.200`) from the Active Directory DNS zone `ad.home.olympus-luca.online`, ensuring reliable domain resolution to `10.0.0.30`.
- Verified macOS backup automation (`nextcloud-backup.sh`): confirmed pre-flight healthcheck, file exclusions, and post-copy upload status validation.
- Executed post-maintenance verification sweep from MacBook with a 100% success rate across ICMP reachability, internal HTTPS endpoints, Cloudflare tunnels, and AD/DNS/SSH/RDP service ports.

| Date (`YYYY-MM-DD`) | Operator | Backups Verified | Node-01 Updated | Node-02 Updated | VM 100 Updated | Network Audited | Notes / Remedial Actions |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| `2026-10-24` | Luca | `[ ]` | `[ ]` | `[ ]` | `[ ]` | `[ ]` | Initial SOP established |
| `2026-11-__` | Luca | `[ ]` | `[ ]` | `[ ]` | `[ ]` | `[ ]` | |
| `2026-12-__` | Luca | `[ ]` | `[ ]` | `[ ]` | `[ ]` | `[ ]` | |
