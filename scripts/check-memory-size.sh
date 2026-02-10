#!/bin/bash
# check-memory-size.sh — Alert if MEMORY.md exceeds target size
# Usage: bash check-memory-size.sh [workspace_path] [max_bytes]

set -euo pipefail

WORKSPACE="${1:-$HOME/openclaw}"
MAX_BYTES="${2:-10000}"  # 10KB default
WARN_BYTES=$((MAX_BYTES * 80 / 100))  # 80% threshold

MEMORY_FILE="$WORKSPACE/MEMORY.md"

if [ ! -f "$MEMORY_FILE" ]; then
  echo "ℹ️  MEMORY.md not found at $MEMORY_FILE"
  exit 0
fi

SIZE=$(wc -c < "$MEMORY_FILE")
PCT=$((SIZE * 100 / MAX_BYTES))

if [ "$SIZE" -gt "$MAX_BYTES" ]; then
  echo "🚨 MEMORY.md OVER LIMIT: ${SIZE} bytes (${PCT}% of ${MAX_BYTES})"
  echo "Action required: Move detailed sections to memory/domains/*.md"
  exit 1
elif [ "$SIZE" -gt "$WARN_BYTES" ]; then
  echo "⚠️  MEMORY.md WARNING: ${SIZE} bytes (${PCT}% of ${MAX_BYTES})"
  echo "Consider moving some content to memory/domains/"
  exit 0
else
  echo "✅ MEMORY.md OK: ${SIZE} bytes (${PCT}% of ${MAX_BYTES})"
  exit 0
fi
