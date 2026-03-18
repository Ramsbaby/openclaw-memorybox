#!/usr/bin/env bash
# scripts/memorybox-watch.sh — MemoryBox Watch Daemon (v2.2)
#
# Runs in the background, checks memory health every N seconds,
# and sends push/webhook alerts when the score drops below a threshold.
#
# Usage:
#   bash scripts/memorybox-watch.sh                 # foreground (Ctrl-C to stop)
#   bash scripts/memorybox-watch.sh --daemon        # start background daemon
#   bash scripts/memorybox-watch.sh --stop          # stop the daemon
#   bash scripts/memorybox-watch.sh --status        # check running status
#
# Environment variables:
#   MEMORYBOX_WORKSPACE     Workspace path           (default: ~/openclaw)
#   MEMORYBOX_INTERVAL      Poll interval seconds    (default: 60)
#   MEMORYBOX_THRESHOLD     Alert threshold 0-100    (default: 80)
#   MEMORYBOX_NTFY_TOPIC    ntfy.sh topic for alerts (optional)
#   MEMORYBOX_DISCORD_URL   Discord webhook URL      (optional)
#   MEMORYBOX_LOG_DIR       Log directory            (default: ~/.openclaw/logs)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORYBOX_BIN="${MEMORYBOX_BIN:-$(command -v memorybox 2>/dev/null || echo "$SCRIPT_DIR/../bin/memorybox")}"

WORKSPACE="${MEMORYBOX_WORKSPACE:-$HOME/openclaw}"
INTERVAL="${MEMORYBOX_INTERVAL:-60}"
THRESHOLD="${MEMORYBOX_THRESHOLD:-80}"
NTFY_TOPIC="${MEMORYBOX_NTFY_TOPIC:-}"
DISCORD_URL="${MEMORYBOX_DISCORD_URL:-}"
LOG_DIR="${MEMORYBOX_LOG_DIR:-$HOME/.openclaw/logs}"
LOG_FILE="$LOG_DIR/memorybox-watch.log"
PID_FILE="/tmp/memorybox-watch.pid"
STATE_FILE="/tmp/memorybox-watch-state.json"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" >&2
}

send_discord() {
  local content="$1"
  [ -z "$DISCORD_URL" ] && return 0
  local payload
  payload=$(python3 -c "import json,sys; print(json.dumps({'content': sys.stdin.read()}))" <<< "$content" \
            2>/dev/null || echo "{\"content\": \"$content\"}")
  curl -s -X POST "$DISCORD_URL" \
    -H "Content-Type: application/json" \
    -d "$payload" >/dev/null 2>&1 || true
}

send_ntfy() {
  local title="$1"
  local body="$2"
  local priority="${3:-default}"
  [ -z "$NTFY_TOPIC" ] && return 0
  curl -s \
    -H "Title: $title" \
    -H "Priority: $priority" \
    -d "$body" \
    "https://ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 || true
}

send_alert() {
  local score="$1"
  local msg="\u26a0\ufe0f MemoryBox health degraded\nScore: ${score}/100 (threshold: ${THRESHOLD})\nWorkspace: ${WORKSPACE}\nFix: memorybox doctor ${WORKSPACE}"
  log "ALERT: health=${score}/100 < threshold=${THRESHOLD}"
  send_ntfy "MemoryBox Alert" "$msg" "high"
  send_discord "$msg"
}

send_recovery() {
  local score="$1"
  local msg="\u2705 MemoryBox health recovered\nScore: ${score}/100 (threshold: ${THRESHOLD})\nWorkspace: ${WORKSPACE}"
  log "RECOVERY: health=${score}/100 >= threshold=${THRESHOLD}"
  send_ntfy "MemoryBox Recovered" "$msg" "low"
  send_discord "$msg"
}

get_health_score() {
  local out
  out=$("$MEMORYBOX_BIN" health "$WORKSPACE" 2>/dev/null || echo "")
  # Parse "Health Score: NN/100" or "Score: NN"
  local score
  score=$(echo "$out" | grep -oE 'Score: ?[0-9]+' | grep -oE '[0-9]+' | head -1 || echo "")
  echo "${score:-0}"
}

write_state() {
  local score="$1"
  local healthy="$2"
  python3 - <<PYEOF 2>/dev/null || true
import json, time
with open('$STATE_FILE', 'w') as f:
    json.dump({
        'score': $score,
        'threshold': $THRESHOLD,
        'healthy': $healthy,
        'ts': int(time.time()),
        'workspace': '$WORKSPACE',
        'interval': $INTERVAL
    }, f, indent=2)
PYEOF
}

watch_loop() {
  mkdir -p "$LOG_DIR"
  log "=== memorybox watch started ==="
  log "workspace=${WORKSPACE} interval=${INTERVAL}s threshold=${THRESHOLD}"
  [ -n "$NTFY_TOPIC" ]   && log "ntfy alerts: $NTFY_TOPIC"
  [ -n "$DISCORD_URL" ]  && log "Discord alerts: enabled"

  local prev_healthy="true"

  while true; do
    local score
    score=$(get_health_score)
    log "health check: ${score}/100"

    if [ "$score" -lt "$THRESHOLD" ]; then
      write_state "$score" "false"
      if [ "$prev_healthy" = "true" ]; then
        send_alert "$score"
        prev_healthy="false"
      fi
    else
      write_state "$score" "true"
      if [ "$prev_healthy" = "false" ]; then
        send_recovery "$score"
        prev_healthy="true"
      fi
    fi

    sleep "$INTERVAL"
  done
}

cmd="${1:-}"

case "$cmd" in
  --daemon|-d)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Already running (PID $(cat "$PID_FILE"))"
      exit 0
    fi
    mkdir -p "$LOG_DIR"
    # Restart self without the --daemon flag so watch_loop runs
    nohup bash "$0" >> "$LOG_FILE" 2>&1 &
    DAEMON_PID=$!
    echo "$DAEMON_PID" > "$PID_FILE"
    sleep 0.3
    if kill -0 "$DAEMON_PID" 2>/dev/null; then
      echo "memorybox watch daemon started (PID $DAEMON_PID)"
      echo "  interval: ${INTERVAL}s, threshold: ${THRESHOLD}/100"
      echo "  logs:     $LOG_FILE"
    else
      echo "FAILED to start daemon — check $LOG_FILE" >&2
      exit 1
    fi
    ;;

  --stop)
    if [ -f "$PID_FILE" ]; then
      PID=$(cat "$PID_FILE")
      if kill "$PID" 2>/dev/null; then
        echo "Stopped (PID $PID)"
      else
        echo "Process $PID not found"
      fi
      rm -f "$PID_FILE"
    else
      echo "Not running (no PID file at $PID_FILE)"
    fi
    ;;

  --status)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Running (PID $(cat "$PID_FILE"))"
      if [ -f "$STATE_FILE" ]; then
        python3 - <<PYEOF 2>/dev/null || true
import json, datetime
with open('$STATE_FILE') as f:
    s = json.load(f)
ts = datetime.datetime.fromtimestamp(s['ts']).strftime('%Y-%m-%d %H:%M:%S')
status = '\u2705 Healthy' if s['healthy'] else '\u26a0\ufe0f  Below threshold'
print(f"  last check : {ts}")
print(f"  health     : {s['score']}/100 (threshold: {s['threshold']})")
print(f"  status     : {status}")
print(f"  workspace  : {s['workspace']}")
PYEOF
      fi
      echo "  logs: $LOG_FILE"
    else
      echo "Not running"
      echo "  Start with: bash $0 --daemon"
    fi
    ;;

  "")
    # Foreground mode
    watch_loop
    ;;

  --help|-h)
    cat <<'HELP'
Usage:
  bash memorybox-watch.sh                 foreground mode (Ctrl-C to stop)
  bash memorybox-watch.sh --daemon        start background daemon
  bash memorybox-watch.sh --stop          stop the daemon
  bash memorybox-watch.sh --status        check running status

Environment variables:
  MEMORYBOX_WORKSPACE     workspace path          (default: ~/openclaw)
  MEMORYBOX_INTERVAL      check interval (sec)    (default: 60)
  MEMORYBOX_THRESHOLD     alert threshold 0-100   (default: 80)
  MEMORYBOX_NTFY_TOPIC    ntfy.sh topic           (optional)
  MEMORYBOX_DISCORD_URL   Discord webhook URL     (optional)
  MEMORYBOX_LOG_DIR       log directory           (default: ~/.openclaw/logs)
HELP
    ;;

  *)
    echo "Unknown option: $cmd" >&2
    echo "Run '$0 --help' for usage" >&2
    exit 1
    ;;
esac
