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

# fetch all public and private github repositories owned by user
REPOS=$(curl -s -H "User-Agent: bash" -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "https://api.github.com/user/repos?per_page=100&affiliation=owner" | grep -o 'git@[^"]*')

for REPO in $REPOS; do
  REPO_PATH="${REPO#git@github.com:}"
  REPO_NAME=$(basename -s .git "$REPO")
  TARGET_DIR="${BACKUP_DIR}/${REPO_NAME}.git"

  echo "syncing repository: ${REPO_NAME}"

  # mirror clone from GitHub locally
  if [ ! -d "$TARGET_DIR" ]; then
    if ! git clone --mirror "https://${GITHUB_TOKEN}@github.com/${REPO_PATH}" "$TARGET_DIR"; then
      echo "[-] Failed to clone ${REPO_NAME}, skipping..."
      continue
    fi
  else
    if ! (cd "$TARGET_DIR" && git remote set-url origin "https://${GITHUB_TOKEN}@github.com/${REPO_PATH}" && git remote update --prune); then
      echo "[-] Failed to update ${REPO_NAME}, skipping..."
      continue
    fi
  fi

  # create gitlab project if it doesn't exist
  PROJECT_EXISTS=$(curl -k -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_URL}/api/v4/projects?search=${REPO_NAME}")

  if [[ "$PROJECT_EXISTS" == "[]" || "$PROJECT_EXISTS" != *"\"name\":\"${REPO_NAME}\""* ]]; then
    echo "creating GitLab project ${REPO_NAME}..."
    curl -k -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
      --data "name=${REPO_NAME}&visibility=private" \
      "${GITLAB_URL}/api/v4/projects" >/dev/null
  fi

  # ensure protected branches allow force-push so amended/rebased GitHub branches sync cleanly
  ENCODED_PROJECT="root%2F${REPO_NAME}"
  curl -k -s --request PATCH --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${GITLAB_URL}/api/v4/projects/${ENCODED_PROJECT}/protected_branches/main?allow_force_push=true" >/dev/null 2>&1 || true
  curl -k -s --request PATCH --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    "${GITLAB_URL}/api/v4/projects/${ENCODED_PROJECT}/protected_branches/master?allow_force_push=true" >/dev/null 2>&1 || true

  # push all branches and tags (excluding hidden refs/remotes/* or refs/pull/* that GitLab rejects)
  if (cd "$TARGET_DIR"); then
    cd "$TARGET_DIR"
    git push --prune "https://oauth2:${GITLAB_TOKEN}@gitlab.home.olympus-luca.online/root/${REPO_NAME}.git" \
      "+refs/heads/*:refs/heads/*" "+refs/tags/*:refs/tags/*" 2>&1 || {
      echo "[-] Warning: Push mirror for ${REPO_NAME} had non-critical errors."
    }
  fi
done

echo "backup completed successfully!"