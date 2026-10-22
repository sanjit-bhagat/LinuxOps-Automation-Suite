#!/bin/bash

# ==========================================
# LinuxOps Automation Suite
# Linux User & Permission Auditing
# ==========================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

REPORT_DIR="$BASE_DIR/reports"
LOG_DIR="$BASE_DIR/logs"

DATE=$(date '+%Y-%m-%d_%H-%M-%S')

REPORT="$REPORT_DIR/user_audit_$DATE.txt"
LOG="$LOG_DIR/user_audit.log"

mkdir -p "$REPORT_DIR" "$LOG_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG"
}

log_message "User and permission audit started."

{
    echo "=========================================="
    echo "       LINUXOPS USER AUDIT REPORT"
    echo "=========================================="

    echo "Hostname : $(hostname)"
    echo "Date     : $(date)"

    echo ""
    echo "1. TOTAL LOCAL USER ACCOUNTS"
    echo "------------------------------------------"

    awk -F: 'END {print NR}' /etc/passwd

    echo ""
    echo "2. UID 0 ACCOUNTS"
    echo "------------------------------------------"

    awk -F: '$3 == 0 {print $1}' /etc/passwd

    echo ""
    echo "3. ACCOUNTS WITH INTERACTIVE SHELLS"
    echo "------------------------------------------"

    awk -F: '
    $7 ~ /(\/bash|\/sh|\/zsh|\/fish)$/ {
        print $1 " : " $7
    }' /etc/passwd

    echo ""
    echo "4. SUDO GROUP MEMBERS"
    echo "------------------------------------------"

    if getent group sudo >/dev/null; then
        getent group sudo
    else
        echo "Sudo group not found."
    fi

    echo ""
    echo "5. WORLD-WRITABLE FILE AUDIT"
    echo "------------------------------------------"

    echo "Scanning project directory..."

    find "$BASE_DIR" \
        -type f \
        -perm -0002 \
        -print 2>/dev/null || true

    echo ""
    echo "6. SECURITY SUMMARY"
    echo "------------------------------------------"

    ROOT_COUNT=$(awk -F: '$3 == 0 {count++} END {print count+0}' /etc/passwd)

    if [ "$ROOT_COUNT" -gt 1 ]; then
        echo "WARNING: Multiple UID 0 accounts detected."
    else
        echo "UID 0 account check passed."
    fi

    echo ""
    echo "Audit completed."
    echo "=========================================="

} | tee "$REPORT"

log_message "Audit report generated: $REPORT"
log_message "User and permission audit completed."
