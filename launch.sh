#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_DIR}"

# shellcheck source=select-network-mode.sh
source "${PROJECT_DIR}/select-network-mode.sh"
# shellcheck source=select-dns-server.sh
source "${PROJECT_DIR}/select-dns-server.sh"

if ! docker info >/dev/null 2>&1; then
  if [[ "$(uname -s)" == "Darwin" ]] && command -v open >/dev/null 2>&1; then
    open -a Docker
    echo "Waiting for Docker Desktop..."
    for _ in {1..60}; do
      docker info >/dev/null 2>&1 && break
      sleep 2
    done
  elif command -v systemctl >/dev/null 2>&1; then
    if command -v pkexec >/dev/null 2>&1; then
      pkexec systemctl start docker
    elif command -v sudo >/dev/null 2>&1; then
      sudo systemctl start docker
    else
      echo "Docker is not running and neither pkexec nor sudo is available." >&2
      read -r -p "Press Enter to close..."
      exit 1
    fi
  else
    echo "Docker is not running and systemctl is not available." >&2
    read -r -p "Press Enter to close..."
    exit 1
  fi
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not available." >&2
  read -r -p "Press Enter to close..."
  exit 1
fi

select_codex_network_mode
select_codex_dns_server

docker compose "${CODEX_COMPOSE_ARGS[@]}" up -d --build --wait codex

if docker compose "${CODEX_COMPOSE_ARGS[@]}" exec -T --user "${CODEX_HOST_UID:-1000}:${CODEX_HOST_GID:-1000}" codex test -s /root/.codex/auth.json; then
  exec docker compose "${CODEX_COMPOSE_ARGS[@]}" exec --user "${CODEX_HOST_UID:-1000}:${CODEX_HOST_GID:-1000}" codex codex resume --sandbox danger-full-access
fi

exec docker compose "${CODEX_COMPOSE_ARGS[@]}" exec --user "${CODEX_HOST_UID:-1000}:${CODEX_HOST_GID:-1000}" codex codex --sandbox danger-full-access
