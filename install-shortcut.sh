#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "${PROJECT_DIR}/launch.sh"

if [[ "$(uname -s)" == "Darwin" ]]; then
    APP_DIR="${HOME}/Applications/Codex CLI Docker.app"
    mkdir -p "${APP_DIR}/Contents/MacOS" "${APP_DIR}/Contents/Resources"

    sed "s#__LAUNCH_PATH__#${PROJECT_DIR}/launch.sh#g" \
        "${PROJECT_DIR}/macos-launcher.sh.in" > "${APP_DIR}/Contents/MacOS/Codex CLI Docker"
    chmod 0755 "${APP_DIR}/Contents/MacOS/Codex CLI Docker"
    cp "${PROJECT_DIR}/macos-Info.plist" "${APP_DIR}/Contents/Info.plist"
    cp "${PROJECT_DIR}/codex.icns" "${APP_DIR}/Contents/Resources/codex.icns"
    touch "${APP_DIR}"
    echo "Installed macOS launcher: ${APP_DIR}"
    exit 0
fi

APP_DIR="${HOME}/.local/share/applications"
DESKTOP_FILE="${APP_DIR}/cdx-codex.desktop"
mkdir -p "${APP_DIR}"

sed \
    -e "s#^Exec=.*#Exec=${PROJECT_DIR}/launch.sh#" \
    -e "s#^Icon=.*#Icon=${PROJECT_DIR}/codex.svg#" \
    "${PROJECT_DIR}/cdx-codex.desktop" > "${DESKTOP_FILE}"
chmod 0755 "${DESKTOP_FILE}"

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${APP_DIR}" >/dev/null 2>&1 || true
fi
echo "Installed Linux desktop launcher: ${DESKTOP_FILE}"
