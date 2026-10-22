#!/bin/bash

# ==========================================
# LinuxOps Automation Suite
# Interactive Automation Dashboard
# ==========================================

set -uo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RUNNER="$BASE_DIR/scripts/automation_runner.sh"

LOG_DIR="$BASE_DIR/logs"
REPORT_DIR="$BASE_DIR/reports"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

# Terminal colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

pause_screen() {
    echo
    read -r -p "Press Enter to continue..." _
}

header() {
    clear

    echo -e "${BLUE}"
    echo "=========================================="
    echo "         LINUXOPS AUTOMATION SUITE"
    echo "=========================================="
    echo -e "${NC}"

    echo " Hostname : $(hostname)"
    echo " User     : $(whoami)"
    echo " Date     : $(date)"
    echo
}

run_module() {

    local task="$1"

    echo -e "${YELLOW}Executing: $task${NC}"
    echo

    if bash "$RUNNER" "$task"; then
        echo
        echo -e "${GREEN}Task completed successfully.${NC}"
    else
        echo
        echo -e "${RED}Task failed. Check automation logs.${NC}"
    fi

    pause_screen
}

view_logs() {

    echo "========== AUTOMATION LOGS =========="

    if [[ -f "$LOG_DIR/automation.log" ]]; then
        tail -n 40 "$LOG_DIR/automation.log"
    else
        echo "No automation logs found."
    fi

    pause_screen
}

view_reports() {

    echo "========== GENERATED REPORTS =========="

    if [[ -d "$REPORT_DIR" ]]; then
        find "$REPORT_DIR" -maxdepth 1 -type f -name '*.txt' -printf '%f\n' | sort
    else
        echo "Reports directory not found."
    fi

    pause_screen
}

check_cron() {

    echo "========== CRON SCHEDULER =========="

    echo
    echo "Service Status:"
    systemctl is-active cron || true

    echo
    echo "Configured Cron Jobs:"
    crontab -l 2>/dev/null || echo "No cron jobs configured."

    pause_screen
}

while true; do

    header

    echo "  1. Server Health Monitoring"
    echo "  2. Automated Backup"
    echo "  3. Security Log Analysis"
    echo "  4. User & Permission Audit"
    echo "  5. Run All Automation Tasks"
    echo "  6. View Automation Logs"
    echo "  7. View Generated Reports"
    echo "  8. Check Cron Scheduler"
    echo "  9. Exit"

    echo
    echo "=========================================="

    read -r -p "Enter your choice [1-9]: " choice || break

    echo

    case "$choice" in

        1)
            run_module health
            ;;

        2)
            run_module backup
            ;;

        3)
            run_module security
            ;;

        4)
            run_module audit
            ;;

        5)
            run_module all
            ;;

        6)
            view_logs
            ;;

        7)
            view_reports
            ;;

        8)
            check_cron
            ;;

        9)
            echo -e "${GREEN}Thank you for using LinuxOps Automation Suite.${NC}"
            exit 0
            ;;

        *)
            echo -e "${RED}Invalid choice. Please select 1-9.${NC}"
            pause_screen
            ;;

    esac

done
