#!/bin/bash

# ==========================================
# LinuxOps Automation Suite
# Automated Log Monitoring & Security Analysis
# ==========================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LOG_DIR="$BASE_DIR/logs"
REPORT_DIR="$BASE_DIR/reports"

DATE=$(date '+%Y-%m-%d_%H-%M-%S')

REPORT="$REPORT_DIR/security_report_$DATE.txt"
EXEC_LOG="$LOG_DIR/log_analyzer.log"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" \
        | tee -a "$EXEC_LOG"
}

log_message "Security log analysis started."

TEMP_AUTH=$(mktemp)
TEMP_SYS=$(mktemp)

trap 'rm -f "$TEMP_AUTH" "$TEMP_SYS"' EXIT

# Collect authentication logs

if [ -r /var/log/auth.log ]; then

    cp /var/log/auth.log "$TEMP_AUTH"

elif command -v journalctl >/dev/null 2>&1; then

    journalctl -u ssh -u sshd --since "24 hours ago" \
        --no-pager > "$TEMP_AUTH" 2>/dev/null || true

fi

# Collect system logs

if [ -r /var/log/syslog ]; then

    cp /var/log/syslog "$TEMP_SYS"

elif command -v journalctl >/dev/null 2>&1; then

    journalctl --since "24 hours ago" \
        --no-pager > "$TEMP_SYS" 2>/dev/null || true

fi

# Analyze collected logs

FAILED_LOGINS=$(
    grep -Eic 'Failed password|authentication failure' \
        "$TEMP_AUTH" || true
)

SUCCESS_LOGINS=$(
    grep -Eic 'Accepted password|Accepted publickey' \
        "$TEMP_AUTH" || true
)

ERROR_COUNT=$(
    grep -Eic 'error|failed|critical' \
        "$TEMP_SYS" || true
)

WARNING_COUNT=$(
    grep -Eic 'warning|warn' \
        "$TEMP_SYS" || true
)

# Generate security report

{
    echo "=========================================="
    echo "       LINUXOPS SECURITY REPORT"
    echo "=========================================="

    echo "Hostname : $(hostname)"
    echo "Date     : $(date)"

    echo ""
    echo "SSH AUTHENTICATION ANALYSIS"
    echo "------------------------------------------"

    echo "Failed Login Events     : $FAILED_LOGINS"
    echo "Successful Login Events : $SUCCESS_LOGINS"

    echo ""
    echo "SYSTEM LOG ANALYSIS"
    echo "------------------------------------------"

    echo "Error Matches   : $ERROR_COUNT"
    echo "Warning Matches : $WARNING_COUNT"

    echo ""
    echo "SECURITY STATUS"
    echo "------------------------------------------"

    if [ "$FAILED_LOGINS" -ge 5 ]; then
        echo "WARNING: Multiple failed SSH login events detected."
    else
        echo "No excessive failed SSH login events detected."
    fi

    echo ""
    echo "RECENT MATCHING LOG ENTRIES"
    echo "------------------------------------------"

    grep -Ei 'error|failed|critical|warning' \
        "$TEMP_SYS" | tail -10 || true

    echo ""
    echo "=========================================="

} | tee "$REPORT"

log_message "Security report generated: $REPORT"

log_message "Security log analysis completed."
