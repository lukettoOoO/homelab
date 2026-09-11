#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${BACKUP_CONFIG_FILE:-${SCRIPT_DIR}/backup.env}"
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
fi

GITHUB_USER="lukettoOoO"
GITLAB_URL="https://gitlab.home.olympus-luca.online"
BACKUP_DIR="/srv/docker/gitlab-backup/repos"

: "${GITHUB_TOKEN:?Set GITHUB_TOKEN before running the backup}"
: "${GITLAB_TOKEN:?Set GITLAB_TOKEN before running the backup}"

mkdir -p "$BACKUP_DIR"

# allow git to operate on repos regardless of owner (avoids dubious ownership error in cron)
git config --global --add safe.directory '*' 2>/dev/null || true

# fetch all public and private github repositories
REPOS=$(curl -s -H "User-Agent: bash" -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "https://api.github.com/user/repos?per_page=100&type=all" | grep -o 'git@[^"]*')

for REPO in $REPOS; do
  REPO_NAME=$(basename -s .git "$REPO")
  TARGET_DIR="${BACKUP_DIR}/${REPO_NAME}.git"

  echo "syncing repository: ${REPO_NAME}"

  # mirror clone from GitHub locally
  if [ ! -d "$TARGET_DIR" ]; then
    if ! git clone --mirror "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git" "$TARGET_DIR"; then
      echo "[-] Failed to clone ${REPO_NAME}, skipping..."
      continue
    fi
  else
    if ! (cd "$TARGET_DIR" && git remote set-url origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git" && git remote update --prune); then
      echo "[-] Failed to update ${REPO_NAME}, skipping..."
      continue
    fi
  fi

  # create gitlab project if it doesn't exist
  PROJECT_EXISTS=$(curl -k -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_URL}/api/v4/projects?search=${REPO_NAME}")

  if [[ "$PROJECT_EXISTS" == "[]" || "$PROJECT_EXISTS" != *"${REPO_NAME}"* ]]; then
    echo "creating GitLab project ${REPO_NAME}..."
    curl -k -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
      --data "name=${REPO_NAME}&visibility=private" \
      "${GITLAB_URL}/api/v4/projects"
  fi

  # push full mirror (all branches, tags, and commits) to gitlab
  if (cd "$TARGET_DIR"); then
    cd "$TARGET_DIR"
    git push --mirror "https://oauth2:${GITLAB_TOKEN}@gitlab.home.olympus-luca.online/root/${REPO_NAME}.git" 2>&1 || {
      echo "[-] Warning: Push mirror for ${REPO_NAME} had non-critical errors."
    }
  fi
done

echo "backup completed successfully!"