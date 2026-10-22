#!/bin/bash

# ==========================================
# LinuxOps Automation Suite
# Installation Script
# ==========================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo " LinuxOps Automation Suite Installer"
echo "======================================"

echo "[1/4] Checking required commands..."

for command in bash tar gzip awk find df free mpstat; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Missing dependency: $command"
        echo "On Ubuntu, install sysstat if mpstat is missing."
        exit 1
    fi
done

echo "[2/4] Creating project directories..."

mkdir -p \
    "$BASE_DIR/logs" \
    "$BASE_DIR/reports" \
    "$BASE_DIR/backups" \
    "$BASE_DIR/demo_data" \
    "$BASE_DIR/docs/screenshots"

echo "[3/4] Setting script permissions..."

chmod +x "$BASE_DIR/linuxops.sh"

find "$BASE_DIR/scripts" \
    -maxdepth 1 \
    -type f \
    -name '*.sh' \
    -exec chmod +x {} +

echo "[4/4] Checking Bash syntax..."

bash -n "$BASE_DIR/linuxops.sh"

for script in "$BASE_DIR"/scripts/*.sh; do
    bash -n "$script"
done

echo
echo "Installation checks completed successfully."
echo
echo "Launch the dashboard using:"
echo "cd \"$BASE_DIR\" && ./linuxops.sh"
echo
echo "Note: Cron scheduling must be configured separately."
