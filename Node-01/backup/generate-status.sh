#!/usr/bin/env bash
# system status generator writes json for dashboard
# runs every 5 minutes via cron
# outputs to status json
set -uo pipefail

# ensure full path for cron environment
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

STATUS_DIR="/srv/docker/dashboard/html/data"
STATUS_FILE="${STATUS_DIR}/status.json"
BACKUP_STATUS_FILE="${STATUS_DIR}/backup-status.json"

mkdir -p "${STATUS_DIR}"

# disk info
get_disk_json() {
    local name="$1" mount="$2"
    if findmnt "${mount}" > /dev/null 2>&1; then
        df -B1 "${mount}" 2>/dev/null | awk -v name="${name}" 'NR==2{
            printf "{\"name\":\"%s\",\"mount\":\"%s\",\"total\":%s,\"used\":%s,\"free\":%s,\"percent\":\"%s\",\"online\":true}", name, $6, $2, $3, $4, $5
        }'
    else
        printf '{"name":"%s","mount":"%s","total":0,"used":0,"free":0,"percent":"0%%","online":false}' "${name}" "${mount}"
    fi
}

DISK_MAIN=$(get_disk_json "Main Storage (HDD)" "/srv")
DISK_SYSTEM=$(get_disk_json "System (SSD)" "/")

# check if backup drive is connected
BACKUP_UUID_FILE="/etc/homelab-backup-uuid"
BACKUP_CONNECTED=false
if [ -f "${BACKUP_UUID_FILE}" ]; then
    BACKUP_UUID=$(cat "${BACKUP_UUID_FILE}")
    if [ -b "/dev/disk/by-uuid/${BACKUP_UUID}" ] || [ -b "/dev/backup-disk" ]; then
        BACKUP_CONNECTED=true
    elif command -v blkid >/dev/null 2>&1 && blkid -U "${BACKUP_UUID}" > /dev/null 2>&1; then
        BACKUP_CONNECTED=true
    fi
fi

# memory info
MEM_TOTAL=$(free -b | awk '/Mem:/{print $2}')
MEM_USED=$(free -b | awk '/Mem:/{print $3}')
MEM_PERCENT=$(free | awk '/Mem:/{printf "%.0f", $3/$2*100}')

# uptime
UPTIME_SECONDS=$(cat /proc/uptime | cut -d' ' -f1 | cut -d'.' -f1)
UPTIME_DAYS=$((UPTIME_SECONDS / 86400))
UPTIME_HOURS=$(( (UPTIME_SECONDS % 86400) / 3600 ))
UPTIME_STR="${UPTIME_DAYS}d ${UPTIME_HOURS}h"

# docker containers
CONTAINERS_RUNNING=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
CONTAINERS_TOTAL=$(docker ps -aq 2>/dev/null | wc -l | tr -d ' ')

# load backup status if it exists
BACKUP_JSON='{"status":"no_data","message":"No backup has run yet"}'
if [ -f "${BACKUP_STATUS_FILE}" ]; then
    BACKUP_JSON=$(cat "${BACKUP_STATUS_FILE}")
fi

# build final json
cat > "${STATUS_FILE}" <<EOF
{
  "generated": "$(date -Iseconds)",
  "hostname": "$(hostname)",
  "uptime": "${UPTIME_STR}",
  "memory": {
    "total": ${MEM_TOTAL},
    "used": ${MEM_USED},
    "percent": ${MEM_PERCENT}
  },
  "containers": {
    "running": ${CONTAINERS_RUNNING},
    "total": ${CONTAINERS_TOTAL}
  },
  "disks": [
    ${DISK_SYSTEM},
    ${DISK_MAIN}
  ],
  "backup_drive_connected": ${BACKUP_CONNECTED},
  "backup": ${BACKUP_JSON}
}
EOF
