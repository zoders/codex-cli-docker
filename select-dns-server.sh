#!/usr/bin/env bash

select_codex_dns_server() {
    local dns_file="${PROJECT_DIR}/dns-servers.txt"
    local line choice index
    local -a dns_servers=()

    CODEX_COMPOSE_ARGS=(-f "${PROJECT_DIR}/docker-compose.yml")
    [[ -f "${dns_file}" ]] || return 0

    while IFS= read -r line || [[ -n "${line}" ]]; do
        line="${line%%#*}"
        line="${line//[[:space:]]/}"
        [[ -z "${line}" ]] && continue

        if [[ ! "${line}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
            echo "Ignoring invalid DNS address in ${dns_file}: ${line}" >&2
            continue
        fi
        dns_servers+=("${line}")
    done < "${dns_file}"

    (( ${#dns_servers[@]} > 0 )) || return 0

    echo "Which DNS server should Docker use?"
    echo "  0) System default (no custom DNS)"
    for (( index=0; index<${#dns_servers[@]}; index++ )); do
        printf '  %d) %s\n' "$((index + 1))" "${dns_servers[index]}"
    done

    if [[ -t 0 ]]; then
        read -r -p "Select an option [0-${#dns_servers[@]}] (default: 0): " choice || choice=""
    else
        choice="0"
        echo "No interactive terminal detected; using the system DNS."
    fi

    choice="${choice:-0}"
    if [[ ! "${choice}" =~ ^[0-9]+$ ]] || (( choice > ${#dns_servers[@]} )); then
        echo "Invalid DNS option: ${choice}." >&2
        return 2
    fi

    if (( choice == 0 )); then
        echo "Using the system DNS."
        return 0
    fi

    export CODEX_DNS="${dns_servers[choice - 1]}"
    CODEX_COMPOSE_ARGS+=( -f "${PROJECT_DIR}/docker-compose.dns.yml" )
    echo "Using DNS server ${CODEX_DNS} outside the VPN tunnel."
}
