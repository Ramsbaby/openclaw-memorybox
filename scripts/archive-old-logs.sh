#!/bin/bash
# archive-old-logs.sh — Move 14+ day daily logs to archive/
# Usage: bash archive-old-logs.sh [memory_dir] [days_old]
# Intended for weekly cron job

set -euo pipefail

MEMORY_DIR="${1:-$HOME/openclaw/memory}"
DAYS_OLD="${2:-14}"

mkdir -p "$MEMORY_DIR/archive"

ARCHIVED=0
find "$MEMORY_DIR" -maxdepth 1 -name "202?-??-??.md" -mtime +"$DAYS_OLD" | while read f; do
  mv "$f" "$MEMORY_DIR/archive/"
  ARCHIVED=$((ARCHIVED + 1))
  echo "Archived: $(basename "$f")"
done

echo "Done. Archived $ARCHIVED files older than $DAYS_OLD days."
