#!/bin/bash

# ==========================================
# LinuxOps Automation Suite
# Central Automation Runner
# ==========================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LOG_DIR="$BASE_DIR/logs"

mkdir -p "$LOG_DIR"

TASK="${1:-}"

LOG_FILE="$LOG_DIR/automation.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" \
        >> "$LOG_FILE"
}

run_task() {

    local script="$1"

    log_message "STARTED: $script"

    if bash "$BASE_DIR/scripts/$script" >> "$LOG_FILE" 2>&1; then

        log_message "SUCCESS: $script"

    else

        log_message "FAILED: $script"
        return 1

    fi
}

case "$TASK" in

    health)
        run_task "health_monitor.sh"
        ;;

    backup)
        run_task "backup_manager.sh"
        ;;

    security)
        run_task "log_analyzer.sh"
        ;;

    audit)
        run_task "user_audit.sh"
        ;;

    all)
        run_task "health_monitor.sh"
        run_task "backup_manager.sh"
        run_task "log_analyzer.sh"
        run_task "user_audit.sh"
        ;;

    *)
        echo "Usage: $0 {health|backup|security|audit|all}"
        exit 1
        ;;

esac
