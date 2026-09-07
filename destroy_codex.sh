#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PROJECT_NAME="$(basename "$SCRIPT_DIR")"
IMAGE_NAME="${PROJECT_NAME}-codex"

printf 'Destroying Codex compose stack in %s\n' "$SCRIPT_DIR"

sudo docker compose down -v --remove-orphans

if sudo docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  sudo docker image rm -f "$IMAGE_NAME"
fi

rm -rf "$SCRIPT_DIR/codex-home" "$SCRIPT_DIR/workspace"

printf 'Done. Removed compose containers, volumes, local image if present, codex-home, and workspace.\n'
