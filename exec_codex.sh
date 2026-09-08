#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_DIR}"

# shellcheck source=select-network-mode.sh
source "${PROJECT_DIR}/select-network-mode.sh"
# shellcheck source=select-dns-server.sh
source "${PROJECT_DIR}/select-dns-server.sh"
select_codex_network_mode
select_codex_dns_server

# `docker compose down` removes the container. Ensure it exists and is running
# before trying to execute Codex inside it.
docker compose "${CODEX_COMPOSE_ARGS[@]}" up -d --wait codex

docker compose "${CODEX_COMPOSE_ARGS[@]}" exec --user "${CODEX_HOST_UID:-1000}:${CODEX_HOST_GID:-1000}" codex \
    codex \
    "$@" \
    --sandbox danger-full-access
