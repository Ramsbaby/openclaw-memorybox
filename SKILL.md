---
name: openclaw-memorybox
description: "Memory health CLI that diagnoses bloated MEMORY.md files, splits oversized sections into domain files, archives stale daily logs, and runs continuous health monitoring. Use when MEMORY.md exceeds 10KB, context windows overflow from memory bloat, or agent sessions slow down from loading large memory files. Pure bash, zero dependencies."
version: 2.2.0
author: Ramsbaby
license: MIT
tags: [memory, maintenance, cli, devtools, zero-dependency]
---

# OpenClaw MemoryBox

> Install with: `clawhub install openclaw-memorybox`

Memory health CLI for AI agents — diagnoses, splits, archives, and monitors MEMORY.md to prevent context overflow.

## Commands

- **`memorybox doctor`** — Full diagnostic: health score, size analysis, duplicates, stale content
- **`memorybox split`** — Interactive: move large sections to `memory/domains/`
- **`memorybox health`** — Quick health score (0–100)
- **`memorybox archive`** — Move daily logs older than 14 days to `memory/archive/`
- **`memorybox watch`** — Background daemon: alerts when health drops below threshold

## Install

```bash
clawhub install openclaw-memorybox
```

Or manually:

```bash
curl -sSL https://raw.githubusercontent.com/Ramsbaby/openclaw-memorybox/main/install.sh | bash
```

## Recommended Workflow

1. Run `memorybox init ~/openclaw` to set up the 3-tier directory structure
2. Run `memorybox doctor ~/openclaw` to get a full diagnostic
3. Run `memorybox split ~/openclaw` for any flagged sections
4. Verify with `memorybox health ~/openclaw` — target score above 80
5. Run `memorybox archive ~/openclaw` to clean up old daily logs

## Optional: Weekly Health Cron

Add to your OpenClaw tasks.json:

```json
{
  "id": "memory-health-weekly",
  "name": "Weekly Memory Health Check",
  "schedule": { "kind": "cron", "expr": "0 23 * * 0", "tz": "Asia/Seoul" },
  "payload": {
    "kind": "agentTurn",
    "message": "Run: memorybox doctor ~/openclaw. If score < 80, run memorybox split and report."
  }
}
```

## Compatibility

- macOS 12+ / Linux (bash 3.2+)
- OpenClaw agents, Claude Code, any markdown-based memory system
- Zero external dependencies — pure bash
