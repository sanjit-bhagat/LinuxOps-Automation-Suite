#!/bin/bash

set -uo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PASSED=0
FAILED=0

check() {
    local description="$1"
    shift

    if "$@"; then
        echo "[PASS] $description"
        ((PASSED+=1))
    else
        echo "[FAIL] $description"
        ((FAILED+=1))
    fi
}

echo "======================================"
echo "      LINUXOPS FINAL TEST SUITE"
echo "======================================"

echo

check "Dashboard syntax" \
    bash -n "$BASE_DIR/linuxops.sh"

for script in "$BASE_DIR"/scripts/*.sh; do
    check "$(basename "$script") syntax" bash -n "$script"
done

check "Configuration exists" \
    test -f "$BASE_DIR/config/linuxops.conf"

check "Installer exists" \
    test -f "$BASE_DIR/install.sh"

check "README exists" \
    test -f "$BASE_DIR/README.md"

check "Backup directory exists" \
    test -d "$BASE_DIR/backups"

check "Reports directory exists" \
    test -d "$BASE_DIR/reports"

check "Logs directory exists" \
    test -d "$BASE_DIR/logs"

echo
echo "======================================"
echo "PASSED: $PASSED"
echo "FAILED: $FAILED"
echo "======================================"

if (( FAILED > 0 )); then
    exit 1
fi

echo "All structural and syntax checks passed."
