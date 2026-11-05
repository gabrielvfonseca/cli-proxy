#!/usr/bin/env bash
#
# backup.sh — Back up CLIProxyAPI auth state (data/ directory).
#
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-./backups}"
DATA_DIR="${DATA_DIR:-./data}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/cliproxyapi-data-$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

if [[ ! -d "$DATA_DIR" ]]; then
  echo "No data directory at $DATA_DIR. Nothing to back up."
  exit 0
fi

tar -czf "$BACKUP_FILE" -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")"
echo "Backup created: $BACKUP_FILE"
