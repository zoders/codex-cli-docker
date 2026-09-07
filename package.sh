#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE_NAME="${1:-cdx-portable.tar.gz}"
DIST_DIR="${PROJECT_DIR}/dist"
ARCHIVE_PATH="${DIST_DIR}/${ARCHIVE_NAME}"

mkdir -p "${DIST_DIR}"
rm -f "${ARCHIVE_PATH}"

tar \
  --exclude='cdx/.env' \
  --exclude='cdx/.git' \
  --exclude='cdx/backups' \
  --exclude='cdx/codex-home' \
  --exclude='cdx/context/?*' \
  --exclude='cdx/dist' \
  --exclude='cdx/resume' \
  --exclude='cdx/secrets' \
  --exclude='cdx/workspace/?*' \
  --exclude='cdx/test' \
  --exclude='cdx/last_session.txt' \
  --exclude='cdx/.codex_agent_venv' \
  --exclude='cdx/.codex_tools' \
  --exclude='cdx/.container_venvs' \
  --exclude='cdx/.uv-cache' \
  --exclude='cdx/.DS_Store' \
  -czf "${ARCHIVE_PATH}" \
  -C "${PROJECT_DIR}/.." \
  cdx

if tar -tzf "${ARCHIVE_PATH}" | grep -Eq '^cdx/(\.env$|\.codex_tools/|backups/|codex-home/|context/.+|dist/|resume$|secrets/|workspace/.+)'; then
  echo "Refusing unsafe archive: private or runtime files were included." >&2
  exit 1
fi

echo "Created ${ARCHIVE_PATH}"
