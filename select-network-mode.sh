#!/usr/bin/env bash

select_codex_network_mode() {
    local choice

    echo "How should Codex CLI Docker connect?"
    echo "  1) Through AmneziaWG VPN"
    echo "  2) Without VPN (direct connection)"

    if [[ -t 0 ]]; then
        read -r -p "Select an option [1-2] (default: 2): " choice || choice=""
    else
        choice="2"
        echo "No interactive terminal detected; using direct connection."
    fi

    case "${choice:-2}" in
        1)
            if [[ ! -s "${PROJECT_DIR}/secrets/amneziawg.conf" ]]; then
                echo "VPN configuration is missing: ${PROJECT_DIR}/secrets/amneziawg.conf" >&2
                echo "Run ./install.sh --awg-config /path/to/amneziawg.conf first." >&2
                return 1
            fi
            export AMNEZIAWG_ENABLED=true
            echo "Starting with AmneziaWG VPN."
            ;;
        2|"")
            export AMNEZIAWG_ENABLED=false
            echo "Starting without VPN."
            ;;
        *)
            echo "Invalid option: ${choice}. Please enter 1 or 2." >&2
            return 2
            ;;
    esac
}
