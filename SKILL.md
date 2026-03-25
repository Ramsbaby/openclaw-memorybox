# SKILL.md — OpenClaw MemoryBox

> Install with: `clawhub install openclaw-memorybox`

## Metadata

```yaml
name: openclaw-memorybox
version: 2.2.0
description: Zero-dependency memory hygiene CLI — keeps MEMORY.md lean, prevents context overflow
author: Ramsbaby
license: MIT
tags: [memory, maintenance, cli, devtools, zero-dependency]
```

## What This Skill Does

Installs the `memorybox` CLI for maintaining AI agent memory health:

- **`memorybox doctor`** — Full diagnostic
- **`memorybox split`** — Interactive: move large sections to domains/
- **`memorybox health`** — Quick health score (0-100)
- **`memorybox archive`** — Move old daily logs to archive/
- **`memorybox watch`** — Background daemon: alerts when health drops

## Install

```bash
clawhub install openclaw-memorybox
```

Or manually:

```bash
curl -sSL https://raw.githubusercontent.com/Ramsbaby/openclaw-memorybox/main/bin/memorybox \
  -o /usr/local/bin/memorybox && chmod +x /usr/local/bin/memorybox
```

## Post-install

After install, initialize your workspace:

```bash
memorybox init ~/openclaw   # or your workspace path
memorybox doctor ~/openclaw # check current health
```

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

## Dependencies

None. Zero external dependencies. Pure bash.

## Compatibility

- macOS 12+ / Linux (bash 3.2+)
- OpenClaw agents
- Claude Code (CLAUDE.md / AGENTS.md workflow)
- Any markdown-based memory system
