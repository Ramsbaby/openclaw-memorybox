# 🧠 OpenClaw MemoryBox

> Zero-dependency hierarchical memory system for OpenClaw agents.
> No external APIs. No plugins. Just smarter file organization.

[![CI](https://github.com/Ramsbaby/openclaw-memorybox/actions/workflows/ci.yml/badge.svg)](https://github.com/Ramsbaby/openclaw-memorybox/actions)
[![OpenClaw Compatible](https://img.shields.io/badge/OpenClaw-Compatible-blue)](https://github.com/openclaw/openclaw)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen)](https://www.shellcheck.net/)

## Origin Story

This project was born from a real production incident.

I run an OpenClaw agent 24/7 across 7 Discord channels with 48 cron jobs. As the agent learned and grew, `MEMORY.md` ballooned to 20KB+. Every session — every cron, every channel, every heartbeat — loaded all of it.

Then one day, **context hit 100%**. Mid-conversation compaction started corrupting state. I tried to fix it by tweaking config — and crashed the gateway. Hard.

That crash led me to build **[openclaw-self-healing](https://github.com/Ramsbaby/openclaw-self-healing)** — a 4-tier autonomous recovery system that detects failures and restores the gateway in ~30 seconds without human intervention.

But self-healing treats the symptom, not the cause. The root cause was **memory bloat** — too much data loaded into every session. So I built MemoryBox: a hierarchical memory system that keeps MEMORY.md lean while preserving everything via tiered storage.

**The full arc:**
```
Memory bloat (20KB+) → Context overflow → Config fix attempt → Gateway crash
  → Built self-healing (recover from crashes)
  → Built MemoryBox (prevent the bloat that caused it)
  → Both open-sourced. Problem solved at both ends.
```

## The Problem

OpenClaw's default memory is flat: `MEMORY.md` + `memory/YYYY-MM-DD.md`. As your agent grows, MEMORY.md bloats to 20KB+ and gets loaded into **every session** — all channels, all crons, all the time.

**What 20KB of memory actually costs:**
```
20KB MEMORY.md × 55 sessions × 200 runs/day = 220MB/day wasted tokens
3.5KB MEMORY.md × 55 sessions × 200 runs/day =  38MB/day
                                                 ↳ 83% reduction
```

> **Honest note:** The 83% reduction applies to MEMORY.md specifically — roughly 5-15% of your total per-session token budget depending on conversation length. But in a 24/7 agent with dozens of crons firing daily, those savings compound fast. More importantly, it **prevents context overflow** — the real killer.

## The Solution

Inspired by [Letta/MemGPT](https://github.com/letta-ai/letta)'s tiered memory pattern, adapted for OpenClaw's file-first philosophy.

```
workspace/
├── MEMORY.md                    # Tier 1: Core facts (≤10KB, auto-loaded everywhere)
└── memory/
    ├── YYYY-MM-DD.md            # Tier 1.5: Daily logs (today+yesterday auto-loaded)
    ├── domains/                 # Tier 2: Topic reference (searched on-demand)
    │   ├── persona.md           #   Response style, formatting rules
    │   ├── decisions.md         #   Past decisions, incident lessons
    │   ├── milestones.md        #   Achievements, project history
    │   ├── investment.md        #   Financial tracking (optional)
    │   └── system.md            #   System config, API keys (optional)
    ├── projects/                # Tier 2: Per-project details
    │   └── my-project.md
    ├── drafts/                  # Workspace: Blog/marketing drafts
    ├── reports/                 # Workspace: Audit/review reports
    ├── incidents/               # Workspace: Incident logs
    └── archive/                 # Tier 3: Old data (14+ day logs)
```

## How It Works

| Tier | Files | Loaded | Token Cost |
|------|-------|--------|------------|
| **Tier 1** | `MEMORY.md` | Every session, automatically | ~3.5KB/session |
| **Tier 1.5** | `memory/YYYY-MM-DD.md` | Today + yesterday, auto | Variable |
| **Tier 2** | `memory/domains/*.md` | On-demand via `memory_search` | Only when needed |
| **Tier 3** | `memory/archive/` | Manual reference only | ~0 |

**Key insight:** OpenClaw's `memory_search` (vector + BM25 hybrid) indexes all `memory/**/*.md` files recursively. Tier 2 files are automatically searchable — no config changes needed.

## Quick Start

### 1. Install

```bash
git clone https://github.com/Ramsbaby/openclaw-memorybox.git
cd openclaw-memorybox

# Make CLI available globally
chmod +x bin/memorybox
sudo ln -sf "$(pwd)/bin/memorybox" /usr/local/bin/memorybox
```

### 2. Analyze Your Memory

```bash
memorybox analyze ~/openclaw
```

```
🔍 MemoryBox Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 MEMORY.md
   Size: 20,542 bytes (205% of 10000 target) 🚨 OVER LIMIT

📊 Sections by Size

   ████████ Investment Portfolio
   4,200 bytes (23%) → suggest: memory/domains/investment-portfolio.md

   ██████ Communication Style
   3,100 bytes (17%) → suggest: memory/domains/communication-style.md

   █████ System Preferences
   2,800 bytes (15%) → suggest: memory/domains/system-preferences.md
```

### 3. Run Migration

```bash
# Non-destructive: creates backup first
bash scripts/migrate.sh ~/openclaw
```

The script:
- Backs up current `MEMORY.md` to `memory/archive/`
- Creates `memory/domains/` structure
- Moves non-daily files to appropriate directories

### 4. Split Large Sections (Interactive)

```bash
memorybox split ~/openclaw
```

```
✂️  MemoryBox Split
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MEMORY.md: 20,542 bytes (target: 10000)
Need to move: 10,542 bytes

Section: Investment Portfolio
Size: 4,200 bytes
Target: memory/domains/investment-portfolio.md
Move this section? [Y/n/s(kip all)] Y
✅ Written to memory/domains/investment-portfolio.md
```

### 5. Check Health

```bash
memorybox health
```

```
🏥 MemoryBox Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ MEMORY.md: 3,460 bytes (34%)
  ✓ domains/: 5 files
  ✓ Daily logs up to date
  ✓ memory/ root is clean
  ✓ archive/ exists

  Health Score: 100/100 ✨ Excellent
```

### 6. Update AGENTS.md

Add to your `AGENTS.md`:

```markdown
## Memory Protocol

### Tier 1: MEMORY.md (≤10KB)
- Core facts only: current projects, preferences, critical rules
- Loaded by ALL sessions — keep it lean

### Tier 2: memory/domains/*.md
- Detailed reference: persona rules, past decisions, milestones
- Use `memory_search` to find relevant content
- Write new domain files for new topics

### Tier 3: memory/archive/
- Old daily logs (14+ days)
- Historical data
- Rarely accessed
```

### 4. Add Maintenance Cron (Optional)

```json
{
  "name": "Memory Maintenance",
  "schedule": { "kind": "cron", "expr": "0 23 * * 0", "tz": "Asia/Seoul" },
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "Run memory maintenance: 1) Move 14+ day daily logs to archive/ 2) Check MEMORY.md size (warn if >8KB) 3) Report summary"
  }
}
```

## MEMORY.md Template

```markdown
# Long-term Memory

> Core facts only. ≤10KB. Loaded by every session.
> Details → memory/domains/*.md (use memory_search)

## Critical Rules
[Your absolute rules here]

## Owner Profile
[Key facts about the user]

## System Preferences
[Essential config — API keys, model preferences]

## Active Projects
[Current work — update frequently]

## Communication Style
> Details: memory/domains/persona.md
[Brief summary only]

## Important Decisions
> Details: memory/domains/decisions.md
[Recent decisions with dates]
```

## Domain File Templates

### `memory/domains/persona.md`
```markdown
# Communication Style Guide

## Persona
[Detailed personality, tone, examples]

## Formatting Rules
[Platform-specific formatting — Discord, Telegram, etc.]

## Forbidden Expressions
[What NOT to say]
```

### `memory/domains/decisions.md`
```markdown
# Decision Archive

## YYYY-MM-DD: Decision Title
**Context:** Why this decision was made
**Decision:** What was decided
**Impact:** What changed
**Lesson:** What we learned
```

### `memory/domains/milestones.md`
```markdown
# Milestones

## YYYY-MM-DD: Achievement Title
**What:** Description
**Links:** URLs
**Impact:** Why it matters
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `memorybox init [path]` | Initialize 3-Tier structure (dirs + templates) |
| `memorybox analyze [path]` | Deep analysis: section sizes, bloat detection, split suggestions |
| `memorybox split [path]` | Interactive: move large sections to domain files |
| `memorybox archive [path]` | Archive old daily logs (14+ days by default) |
| `memorybox report [path]` | Before/after token savings report |
| `memorybox health [path]` | Quick health score (0-100) with recommendations |
| `memorybox dedupe [path]` | Find duplicate content across memory files |
| `memorybox stale [path]` | Detect outdated content and stale references |
| `memorybox suggest [path]` | Smart recommendations for improvement |
| `memorybox doctor [path]` | Full diagnostic (health + size + dedupe + suggestions) |

### Options

```bash
memorybox -w ~/my-workspace analyze    # Custom workspace path
memorybox -d 7 archive                 # Archive logs older than 7 days
memorybox -m 8000 health               # Set 8KB as max target
```

## Why Not elite-longterm-memory?

| Feature | elite-longterm-memory | MemoryBox |
|---------|----------------------|---------------|
| Dependencies | LanceDB, Mem0, SuperMemory API | **None** |
| Setup time | 30+ min (API keys, plugins) | **5 min** (file moves only) |
| OpenClaw version | clawdbot (outdated) | **Current OpenClaw** |
| Token savings | "80% claimed" | **83% measured** |
| Production tested | Documentation only | **48 crons, 7 channels** |
| Philosophy | Replace memory-core | **Extend memory-core** |

## Companion Project: Self-Healing

If MemoryBox prevents the crash, **[openclaw-self-healing](https://github.com/Ramsbaby/openclaw-self-healing)** recovers from it when it happens anyway.

| Layer | Tool | What It Does |
|-------|------|-------------|
| Prevention | **MemoryBox** | Keeps memory lean → fewer context overflows |
| Recovery | **Self-Healing** | 4-tier auto-recovery → gateway back in ~30s |

Together they form a complete reliability stack for production OpenClaw agents. Both are zero-dependency and MIT licensed.

## Compatibility

✅ **Works with OpenClaw's native memory system:**
- `memory-core` plugin (default) — no changes
- `memory_search` tool — indexes `memory/**/*.md` recursively
- `memory_get` tool — reads any `memory/` file
- Pre-compaction memory flush — still works
- Hybrid search (BM25 + vector) — still works

✅ **Works alongside other memory plugins:**
- mem0, cognee, supermemory — these replace the search backend, not file structure
- QMD backend — indexes the same files

❌ **Does NOT modify:**
- OpenClaw config (`openclaw.json`)
- memory-core plugin behavior
- Any OpenClaw internals

## Measured Results

Tested on a production OpenClaw instance (7 Discord channels, 48 crons):

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| MEMORY.md size | 20,542 bytes | 3,460 bytes | **-83%** |
| Daily token load | ~5MB | ~0.94MB | **-81%** |
| Context pressure | High (98%) | Low (7%) | **-91%** |
| memory_search | Works | Works | ✅ No change |
| Compaction frequency | High | Reduced | ✅ Improved |

## Advanced: Auto-Archiving Script

```bash
#!/bin/bash
# archive-old-logs.sh — Move 14+ day daily logs to archive/
MEMORY_DIR="${1:-$HOME/openclaw/memory}"
DAYS_OLD=14

mkdir -p "$MEMORY_DIR/archive"

find "$MEMORY_DIR" -maxdepth 1 -name "202?-??-??.md" -mtime +$DAYS_OLD | while read f; do
  mv "$f" "$MEMORY_DIR/archive/"
  echo "Archived: $(basename $f)"
done
```

## FAQ

**Q: Will OpenClaw updates break this?**
A: Unlikely. This uses standard files in the standard memory directory. OpenClaw's philosophy is "files are source of truth" — they won't change that.

**Q: Does memory_search find files in subdirectories?**
A: Yes. OpenClaw indexes `memory/**/*.md` recursively. The official docs confirm this.

**Q: What about extraPaths config?**
A: Not needed if your files are under `memory/`. Use `extraPaths` only for files outside the workspace.

**Q: Can I use this with QMD backend?**
A: Yes. QMD indexes the same file paths. Set `memory.qmd.includeDefaultMemory: true` (default).

## Contributing

PRs welcome! Areas for improvement:
- [ ] Migration script for different workspace layouts
- [ ] Automated MEMORY.md size monitoring
- [ ] Domain file templates for common use cases
- [ ] Integration tests with memory_search

## License

MIT — Do whatever you want.

---

**Made by [@ramsbaby](https://github.com/ramsbaby)** — Battle-tested on a production OpenClaw instance running 24/7.
