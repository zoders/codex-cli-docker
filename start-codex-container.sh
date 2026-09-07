#!/usr/bin/env bash
set -euo pipefail

readonly INTERFACE="awg0"
readonly SOURCE_CONFIG="/etc/amneziawg/amneziawg.conf"
readonly RUNTIME_DIR="/run/amneziawg"
readonly RUNTIME_CONFIG="${RUNTIME_DIR}/${INTERFACE}.conf"
readonly READY_FILE="/run/codex-container-ready"

chown -R "${CODEX_HOST_UID:-1000}:${CODEX_HOST_GID:-1000}" /opt/npm-global

if [[ "${AMNEZIAWG_ENABLED:-auto}" == "false" || "${AMNEZIAWG_ENABLED:-auto}" == "0" ]]; then
    echo "AmneziaWG is disabled; using the regular Docker network"
    touch "${READY_FILE}"
    exec sleep infinity
fi

if [[ ! -f "${SOURCE_CONFIG}" ]]; then
    if [[ "${AMNEZIAWG_ENABLED:-auto}" == "true" || "${AMNEZIAWG_ENABLED:-auto}" == "1" ]]; then
        echo "AmneziaWG is enabled but config is missing: ${SOURCE_CONFIG}" >&2
        exit 1
    fi
    echo "AmneziaWG config not found; using the regular Docker network"
    touch "${READY_FILE}"
    exec sleep infinity
fi

mkdir -p "${RUNTIME_DIR}"

declare -a routes=()
IFS=',' read -ra domains <<< "${OPENAI_VPN_DOMAINS}"
for domain in "${domains[@]}"; do
    while read -r address; do
        [[ -n "${address}" ]] && routes+=("${address}/32")
    done < <(getent ahostsv4 "${domain}" | awk '{print $1}' | sort -u)
done

if (( ${#routes[@]} == 0 )); then
    echo "Could not resolve any OpenAI VPN domains" >&2
    exit 1
fi

allowed_ips="$(printf '%s\n' "${routes[@]}" | sort -u | paste -sd, -)"
awk -v allowed_ips="${allowed_ips}" '
    /^[[:space:]]*DNS[[:space:]]*=/ { next }
    /^[[:space:]]*AllowedIPs[[:space:]]*=/ {
        print "AllowedIPs = " allowed_ips
        next
    }
    { print }
' "${SOURCE_CONFIG}" > "${RUNTIME_CONFIG}"
chmod 0600 "${RUNTIME_CONFIG}"

awg-quick up "${RUNTIME_CONFIG}"
echo "AmneziaWG split tunnel is active for ${#routes[@]} resolved OpenAI routes"
touch "${READY_FILE}"

exec sleep infinity
