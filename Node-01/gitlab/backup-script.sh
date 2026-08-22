#!/usr/bin/env bash
set -e

GITHUB_USER="lukettoOoO"
GITLAB_URL="https://gitlab.olympus-luca.online"
BACKUP_DIR="/srv/docker/gitlab-backup/repos"

: "${GITHUB_TOKEN:?Set GITHUB_TOKEN before running the backup}"
: "${GITLAB_TOKEN:?Set GITLAB_TOKEN before running the backup}"

mkdir -p "$BACKUP_DIR"

# fetch all public and private github repositories
REPOS=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
  "https://api.github.com/user/repos?per_page=100&type=all" | grep -o 'git@[^"]*' || true)

for REPO in $REPOS; do
  REPO_NAME=$(basename -s .git "$REPO")
  TARGET_DIR="${BACKUP_DIR}/${REPO_NAME}.git"

  echo "syncing repository: ${REPO_NAME}"

  # mirror clone from GitHub locally
  if [ ! -d "$TARGET_DIR" ]; then
    git clone --mirror "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git" "$TARGET_DIR"
  else
    cd "$TARGET_DIR"
    git remote update --prune
  fi

  # create gitlab project if it doesn't exist
  PROJECT_EXISTS=$(curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_URL}/api/v4/projects?search=${REPO_NAME}")

  if [[ "$PROJECT_EXISTS" == "[]" ]]; then
    echo "creating GitLab project ${REPO_NAME}..."
    curl -s --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
      --data "name=${REPO_NAME}&visibility=private" \
      "${GITLAB_URL}/api/v4/projects"
  fi

  # push full mirror (all branches, tags, and commits) to gitlab
  cd "$TARGET_DIR"
  git push --mirror "https://oauth2:${GITLAB_TOKEN}@gitlab.olympus-luca.online/root/${REPO_NAME}.git" || true
done

echo "backup completed successfully!"