#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_DIR}"

# shellcheck source=select-network-mode.sh
source "${PROJECT_DIR}/select-network-mode.sh"
select_codex_network_mode

# `docker compose down` removes the container. Ensure it exists and is running
# before trying to execute Codex inside it.
docker compose up -d --wait codex

docker compose exec --user "${CODEX_HOST_UID:-1000}:${CODEX_HOST_GID:-1000}" codex \
    codex \
    "$@" \
    --sandbox danger-full-access
