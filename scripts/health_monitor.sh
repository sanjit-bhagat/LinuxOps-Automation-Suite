#!/bin/bash

# =====================================
# LinuxOps Automation Suite
# Automated Server Health Monitoring
# =====================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$BASE_DIR/config/linuxops.conf"

mkdir -p "$BASE_DIR/logs" "$BASE_DIR/reports"

DATE=$(date '+%Y-%m-%d_%H-%M-%S')

REPORT="$BASE_DIR/reports/health_$DATE.txt"
LOG="$BASE_DIR/logs/health_monitor.log"

CPU=$(LC_ALL=C mpstat 1 1 | awk '/^Average:/ && $2 == "all" {printf "%.0f", 100-$NF}')

MEMORY=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')

DISK=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')

{
echo "======================================"
echo "       LINUXOPS HEALTH REPORT"
echo "======================================"

echo "Hostname : $(hostname)"
echo "Date     : $(date)"
echo "Uptime   : $(uptime -p)"

echo ""
echo "SYSTEM RESOURCE USAGE"
echo "--------------------------------------"

echo "CPU Usage    : $CPU%"
echo "Memory Usage : $MEMORY%"
echo "Disk Usage   : $DISK%"

echo ""
echo "SYSTEM ALERTS"
echo "--------------------------------------"

ALERT=0

if [ "$CPU" -ge "$CPU_THRESHOLD" ]; then
    echo "WARNING: High CPU Usage!"
    ALERT=1
fi

if [ "$MEMORY" -ge "$MEMORY_THRESHOLD" ]; then
    echo "WARNING: High Memory Usage!"
    ALERT=1
fi

if [ "$DISK" -ge "$DISK_THRESHOLD" ]; then
    echo "WARNING: High Disk Usage!"
    ALERT=1
fi

if [ "$ALERT" -eq 0 ]; then
    echo "STATUS: SYSTEM HEALTHY"
fi

echo ""
echo "======================================"

} | tee "$REPORT"

echo "$(date): Health monitoring completed. Report: $REPORT" >> "$LOG"
