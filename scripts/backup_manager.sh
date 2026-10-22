#!/bin/bash

# ==========================================
# LinuxOps Automation Suite
# Automated Backup and Recovery System
# ==========================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOURCE_DIR="$BASE_DIR/demo_data"
BACKUP_DIR="$BASE_DIR/backups"
LOG_DIR="$BASE_DIR/logs"

RETENTION_DAYS=7

DATE=$(date '+%Y-%m-%d_%H-%M-%S')

BACKUP_FILE="$BACKUP_DIR/linuxops_backup_$DATE.tar.gz"

LOG_FILE="$LOG_DIR/backup.log"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_message "Backup process started."

# Check source directory

if [ ! -d "$SOURCE_DIR" ]; then
    log_message "ERROR: Source directory not found."
    exit 1
fi

# Create compressed backup

log_message "Creating backup..."

if tar -czf "$BACKUP_FILE" -C "$BASE_DIR" demo_data; then
    log_message "Backup created: $BACKUP_FILE"
else
    log_message "ERROR: Backup creation failed."
    rm -f -- "$BACKUP_FILE"
    exit 1
fi

# Verify backup integrity

if tar -tzf "$BACKUP_FILE" > /dev/null; then
    log_message "Backup integrity verification successful."
else
    log_message "ERROR: Backup verification failed."
    rm -f -- "$BACKUP_FILE"
    exit 1
fi

# Remove old backups

log_message "Checking old backups..."

find "$BACKUP_DIR" \
    -maxdepth 1 \
    -type f \
    -name 'linuxops_backup_*.tar.gz' \
    -mtime +6 \
    -print \
    -delete >> "$LOG_FILE"

log_message "Backup retention cleanup completed."

log_message "Backup process finished successfully."
