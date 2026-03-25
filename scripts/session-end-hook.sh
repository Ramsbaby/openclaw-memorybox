#!/usr/bin/env bash
# Hook: run at end of Claude Code session to auto-capture memory
# Add to settings.json Stop hook:
#   ~/.local/share/memorybox/session-end-hook.sh
#
# Claude Code settings.json example:
#   {
#     "hooks": {
#       "Stop": [{"command": "bash ~/.local/share/memorybox/session-end-hook.sh"}]
#     }
#   }
set -euo pipefail

MEMORYBOX="${MEMORYBOX_BIN:-$(command -v memorybox 2>/dev/null || echo "")}"
[[ -z "$MEMORYBOX" ]] && exit 0
"$MEMORYBOX" capture --session-end --quiet 2>/dev/null || true
