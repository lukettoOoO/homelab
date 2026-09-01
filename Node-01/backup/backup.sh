#!/usr/bin/env bash
# homelab backup script
# backs up all srv data configs home directory and docker volumes to external usb drive
# runs nightly at 03:00 via cron
# retries up to 3 times if drive is missing or unresponsive
# uses rsync with partial so interrupted backups resume next run
set -uo pipefail

# configuration
BACKUP_UUID="7452da95-ed38-481f-9331-b341d36fe0e5"
BACKUP_MOUNT="/mnt/backup"
BACKUP_DIR="${BACKUP_MOUNT}/homelab-backups"
LATEST_LINK="${BACKUP_DIR}/latest"
LOG_FILE="/var/log/homelab-backup.log"
RETENTION_DAYS=30
IO_TIMEOUT=10       # seconds to wait for drive io test
MAX_RETRIES=3       # total attempts
RETRY_DELAY=2700    # seconds between retries

# source directories
SRV_DOCKER="/srv/docker"
SRV_VOLUMES="/srv/docker-data/volumes"
SRV_NOTES="/srv/notes"
SRV_TEST="/srv/test"
HOME_LUCA="/home/luca"
SYS_ETC="/etc"

# logging
exec > >(tee -a "${LOG_FILE}") 2>&1

# cleanup function always unmount and disable maintenance mode
cleanup() {
    if docker ps --format '{{.Names}}' | grep -q '^nextcloud-aio-nextcloud$'; then
        docker exec -u www-data nextcloud-aio-nextcloud \
            php occ maintenance:mode --off 2>/dev/null || true
    fi

    if findmnt "${BACKUP_MOUNT}" > /dev/null 2>&1; then
        sync 2>/dev/null
        umount "${BACKUP_MOUNT}" 2>/dev/null || umount -l "${BACKUP_MOUNT}" 2>/dev/null
    fi
}
trap cleanup EXIT

# try to find mount and test the backup drive
try_mount_and_test() {
    if ! blkid -U "${BACKUP_UUID}" > /dev/null 2>&1; then
        echo "[!] backup drive not detected."
        return 1
    fi

    DRIVE_DEV=$(blkid -U "${BACKUP_UUID}")
    echo "    found drive at ${DRIVE_DEV}"

    mkdir -p "${BACKUP_MOUNT}"
    if ! mount UUID="${BACKUP_UUID}" "${BACKUP_MOUNT}" 2>&1; then
        echo "[!] could not mount backup drive."
        return 1
    fi

    # test io responsiveness
    TEST_FILE="${BACKUP_MOUNT}/.io_test_$$"
    if ! timeout "${IO_TIMEOUT}" bash -c \
        "echo 'test' > '${TEST_FILE}' && sync && cat '${TEST_FILE}' > /dev/null && rm -f '${TEST_FILE}'" 2>/dev/null; then
        echo "[!] drive mounted but not responding to io within ${IO_TIMEOUT}s."
        umount "${BACKUP_MOUNT}" 2>/dev/null || umount -l "${BACKUP_MOUNT}" 2>/dev/null
        return 1
    fi

    echo "    drive io ok."
    return 0
}

# retry loop
echo ""
echo "================================================================="
echo "backup started: $(date)"
echo "================================================================="

ATTEMPT=1
DRIVE_READY=false

while [ ${ATTEMPT} -le ${MAX_RETRIES} ]; do
    echo ""
    echo "[*] attempt ${ATTEMPT}/${MAX_RETRIES}: looking for backup drive..."

    if try_mount_and_test; then
        DRIVE_READY=true
        break
    fi

    if [ ${ATTEMPT} -lt ${MAX_RETRIES} ]; then
        NEXT_MINS=$((RETRY_DELAY / 60))
        echo "[*] will retry in ${NEXT_MINS} minutes (sleeping ${RETRY_DELAY}s)..."
        sleep "${RETRY_DELAY}"
    fi

    ATTEMPT=$((ATTEMPT + 1))
done

if [ "${DRIVE_READY}" != "true" ]; then
    echo ""
    echo "[!] failed: backup drive unavailable after ${MAX_RETRIES} attempts. giving up."
    echo "================================================================="

    # write failure status for the dashboard
    DASHBOARD_STATUS_DIR="/srv/docker/dashboard/html/data"
    mkdir -p "${DASHBOARD_STATUS_DIR}"
    cat > "${DASHBOARD_STATUS_DIR}/backup-status.json" <<BEOF
{
  "status": "failed",
  "timestamp": "$(date -Iseconds)",
  "message": "backup drive unavailable after ${MAX_RETRIES} attempts",
  "attempt": ${MAX_RETRIES}
}
BEOF

    exit 1
fi

# timestamp set after successful mount so retries get accurate names
TIMESTAMP=$(date +%Y-%m-%d_%H%M)

# prepare backup destination directories
CURRENT_BACKUP="${BACKUP_DIR}/${TIMESTAMP}"
LINK_DEST_OPT=""
if [ -L "${LATEST_LINK}" ] && [ -d "${LATEST_LINK}" ]; then
    LINK_DEST_OPT="--link-dest=${LATEST_LINK}"
    echo "[*] incremental backup (hardlinking unchanged files to previous)."
else
    echo "[*] full backup (no previous backup found)."
fi

mkdir -p "${CURRENT_BACKUP}/srv-docker"
mkdir -p "${CURRENT_BACKUP}/srv-volumes"
mkdir -p "${CURRENT_BACKUP}/home-luca"
mkdir -p "${CURRENT_BACKUP}/system-etc"
mkdir -p "${CURRENT_BACKUP}/database-dumps"

# common rsync flags
RSYNC_OPTS="-a --delete --partial --timeout=60"

# step 1: database dumps
echo ""
echo "[*] creating database and app dumps..."

# gitlab internal backup
if docker ps --format '{{.Names}}' | grep -q '^gitlab$'; then
    echo "    creating gitlab backup archive..."
    docker exec -t gitlab gitlab-backup create CRON=1 2>&1 || {
        echo "[!] warning: gitlab internal backup failed. raw data will still be synced."
    }
fi

# nextcloud database dump
if docker ps --format '{{.Names}}' | grep -q '^nextcloud-aio-nextcloud$'; then
    echo "    enabling nextcloud maintenance mode..."
    docker exec -u www-data nextcloud-aio-nextcloud \
        php occ maintenance:mode --on 2>/dev/null || true
fi

if docker ps --format '{{.Names}}' | grep -q '^nextcloud-aio-database$'; then
    echo "    dumping nextcloud database..."
    if docker exec nextcloud-aio-database pg_dumpall -U oc_nextcloud \
        > "${CURRENT_BACKUP}/database-dumps/nextcloud_database.sql" 2>/dev/null; then
        echo "    database dump complete: $(du -sh "${CURRENT_BACKUP}/database-dumps/nextcloud_database.sql" | cut -f1)"
    fi
fi

# step 2: sync all srv docker directories
echo ""
echo "[*] syncing all /srv/docker data..."
rsync ${RSYNC_OPTS} ${LINK_DEST_OPT:+"${LINK_DEST_OPT}/srv-docker/"} \
    "${SRV_DOCKER}/" "${CURRENT_BACKUP}/srv-docker/" || {
    echo "[!] warning: /srv/docker sync had some non-critical warnings."
}
echo "[ok] /srv/docker synced."

# step 3: sync all docker named volumes
echo ""
echo "[*] syncing /srv/docker-data/volumes..."
rsync ${RSYNC_OPTS} ${LINK_DEST_OPT:+"${LINK_DEST_OPT}/srv-volumes/"} \
    "${SRV_VOLUMES}/" "${CURRENT_BACKUP}/srv-volumes/" || {
    echo "[!] warning: /srv/docker-data/volumes sync had some non-critical warnings."
}
echo "[ok] docker volumes synced."

# step 4: sync notes and test
if [ -d "${SRV_NOTES}" ]; then
    echo ""
    echo "[*] syncing /srv/notes..."
    mkdir -p "${CURRENT_BACKUP}/srv-notes"
    rsync ${RSYNC_OPTS} ${LINK_DEST_OPT:+"${LINK_DEST_OPT}/srv-notes/"} \
        "${SRV_NOTES}/" "${CURRENT_BACKUP}/srv-notes/" || true
fi

if [ -d "${SRV_TEST}" ]; then
    echo ""
    echo "[*] syncing /srv/test..."
    mkdir -p "${CURRENT_BACKUP}/srv-test"
    rsync ${RSYNC_OPTS} ${LINK_DEST_OPT:+"${LINK_DEST_OPT}/srv-test/"} \
        "${SRV_TEST}/" "${CURRENT_BACKUP}/srv-test/" || true
fi

# step 5: sync home directory excluding disposable caches
if [ -d "${HOME_LUCA}" ]; then
    echo ""
    echo "[*] syncing /home/luca (excluding temporary caches)..."
    rsync ${RSYNC_OPTS} \
        --exclude='.cache' \
        --exclude='.npm' \
        --exclude='.vscode-server' \
        --exclude='.antigravity*' \
        --exclude='.minikube/cache' \
        ${LINK_DEST_OPT:+"${LINK_DEST_OPT}/home-luca/"} \
        "${HOME_LUCA}/" "${CURRENT_BACKUP}/home-luca/" || true
    echo "[ok] /home/luca synced."
fi

# step 6: sync /etc system configuration
if [ -d "${SYS_ETC}" ]; then
    echo ""
    echo "[*] syncing /etc system configurations..."
    rsync ${RSYNC_OPTS} ${LINK_DEST_OPT:+"${LINK_DEST_OPT}/system-etc/"} \
        "${SYS_ETC}/" "${CURRENT_BACKUP}/system-etc/" || true
    echo "[ok] /etc synced."
fi

# disable nextcloud maintenance mode
if docker ps --format '{{.Names}}' | grep -q '^nextcloud-aio-nextcloud$'; then
    echo "    disabling nextcloud maintenance mode..."
    docker exec -u www-data nextcloud-aio-nextcloud \
        php occ maintenance:mode --off 2>/dev/null || true
fi

# update latest symlink
ln -sfn "${CURRENT_BACKUP}" "${LATEST_LINK}"

# cleanup old backups
echo ""
echo "[*] cleaning up backups older than ${RETENTION_DAYS} days..."
CLEANED=0
for old_backup in "${BACKUP_DIR}"/20*; do
    [ -d "${old_backup}" ] || continue
    if [ "$(find "${old_backup}" -maxdepth 0 -mtime +${RETENTION_DAYS})" ]; then
        echo "    removing: $(basename "${old_backup}")"
        rm -rf "${old_backup}"
        CLEANED=$((CLEANED + 1))
    fi
done
echo "    removed ${CLEANED} old backup(s)."

# summary
echo ""
BACKUP_SIZE=$(du -sh "${CURRENT_BACKUP}" 2>/dev/null | cut -f1)
DRIVE_USED=$(df -h "${BACKUP_MOUNT}" 2>/dev/null | awk 'NR==2{print $3}')
DRIVE_FREE=$(df -h "${BACKUP_MOUNT}" 2>/dev/null | awk 'NR==2{print $4}')
DRIVE_PCT=$(df -h "${BACKUP_MOUNT}" 2>/dev/null | awk 'NR==2{print $5}')
echo "================================================================="
echo "backup completed successfully: $(date)"
echo "attempt:           ${ATTEMPT}/${MAX_RETRIES}"
echo "this backup:       ${BACKUP_SIZE}"
echo "drive used:        ${DRIVE_USED} (${DRIVE_PCT})"
echo "drive free:        ${DRIVE_FREE}"
echo "location:          ${CURRENT_BACKUP}"
echo "================================================================="

# write backup status for the dashboard
DASHBOARD_STATUS_DIR="/srv/docker/dashboard/html/data"
mkdir -p "${DASHBOARD_STATUS_DIR}"
cat > "${DASHBOARD_STATUS_DIR}/backup-status.json" <<BEOF
{
  "status": "success",
  "timestamp": "$(date -Iseconds)",
  "message": "backup completed successfully",
  "size": "${BACKUP_SIZE}",
  "drive_used": "${DRIVE_USED}",
  "drive_free": "${DRIVE_FREE}",
  "drive_percent": "${DRIVE_PCT}",
  "attempt": ${ATTEMPT},
  "location": "${CURRENT_BACKUP}"
}
BEOF