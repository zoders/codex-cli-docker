#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AWG_CONFIG=""
INSTALL_SHORTCUT=true

usage() {
    echo "Usage: $0 [--awg-config /path/to/config.conf] [--no-shortcut]"
}

while (( $# > 0 )); do
    case "$1" in
        --awg-config)
            [[ $# -ge 2 ]] || { usage >&2; exit 2; }
            AWG_CONFIG="$2"
            shift 2
            ;;
        --no-shortcut)
            INSTALL_SHORTCUT=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

command -v docker >/dev/null 2>&1 || { echo "Docker is required." >&2; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "Docker Compose plugin is required." >&2; exit 1; }

mkdir -p "${PROJECT_DIR}/codex-home" "${PROJECT_DIR}/workspace" \
    "${PROJECT_DIR}/secrets" "${PROJECT_DIR}/dist"

host_uid="$(id -u)"
host_gid="$(id -g)"
projects_dir="${HOME}/Projects"
webstorm_dir="${HOME}/WebstormProjects"
pycharm_dir="${HOME}/PycharmProjects"

[[ -d "${projects_dir}" ]] || projects_dir="${PROJECT_DIR}/workspace"
[[ -d "${webstorm_dir}" ]] || webstorm_dir="${PROJECT_DIR}/workspace"
[[ -d "${pycharm_dir}" ]] || pycharm_dir="${PROJECT_DIR}/workspace"

{
    printf 'CODEX_HOST_UID=%s\n' "${host_uid}"
    printf 'CODEX_HOST_GID=%s\n' "${host_gid}"
    printf 'CODEX_PROJECTS_DIR=%s\n' "${projects_dir}"
    printf 'CODEX_WEBSTORM_PROJECTS_DIR=%s\n' "${webstorm_dir}"
    printf 'CODEX_PYCHARM_PROJECTS_DIR=%s\n' "${pycharm_dir}"
    printf 'AMNEZIAWG_ENABLED=auto\n'
} > "${PROJECT_DIR}/.env"
chmod 0600 "${PROJECT_DIR}/.env"

if [[ -n "${AWG_CONFIG}" ]]; then
    [[ -f "${AWG_CONFIG}" ]] || { echo "Config not found: ${AWG_CONFIG}" >&2; exit 1; }
    install -m 0600 "${AWG_CONFIG}" "${PROJECT_DIR}/secrets/amneziawg.conf"
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
    open -a Docker
    echo "Waiting for Docker Desktop..."
    for _ in {1..60}; do
        docker info >/dev/null 2>&1 && break
        sleep 2
    done
fi

docker info >/dev/null 2>&1 || { echo "Start Docker and run this installer again." >&2; exit 1; }

cd "${PROJECT_DIR}"
docker compose build codex
docker compose up -d --wait codex

if [[ "${INSTALL_SHORTCUT}" == true ]]; then
    "${PROJECT_DIR}/install-shortcut.sh"
fi

echo "Installation complete. Run: ${PROJECT_DIR}/exec_codex.sh"
