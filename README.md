# 🧠 OpenClaw MemoryBox

> Zero-dependency hierarchical memory system for OpenClaw agents.
> No external APIs. No plugins. Just smarter file organization.

[![OpenClaw Compatible](https://img.shields.io/badge/OpenClaw-Compatible-blue)](https://github.com/openclaw/openclaw)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## The Problem

OpenClaw's default memory is flat: `MEMORY.md` + `memory/YYYY-MM-DD.md`. As your agent grows, MEMORY.md bloats to 20KB+ and gets loaded into **every session** — all channels, all crons, all the time.

```
Before: 20KB MEMORY.md × 55 sessions × 200 runs/day = 220MB/day wasted tokens
After:   3.5KB MEMORY.md × 55 sessions × 200 runs/day =  38MB/day
         ↳ 83% reduction, zero dependencies
```

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

### 1. Install (copy files to your workspace)

```bash
# Clone this repo
git clone https://github.com/Ramsbaby/openclaw-memorybox.git

# Copy templates to your OpenClaw workspace
cp -r openclaw-memorybox/templates/memory/* ~/openclaw/memory/
cp openclaw-memorybox/templates/MEMORY.md ~/openclaw/MEMORY.md.template
```

### 2. Organize Your Existing Memory

```bash
# Run the migration script (non-destructive, creates backup first)
bash openclaw-memorybox/scripts/migrate.sh ~/openclaw
```

The script:
- Backs up current `MEMORY.md` to `memory/archive/`
- Creates `memory/domains/` structure
- Moves non-daily files to appropriate directories
- Generates a slim `MEMORY.md` template

### 3. Update AGENTS.md

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

## Why Not elite-longterm-memory?

| Feature | elite-longterm-memory | MemoryBox |
|---------|----------------------|---------------|
| Dependencies | LanceDB, Mem0, SuperMemory API | **None** |
| Setup time | 30+ min (API keys, plugins) | **5 min** (file moves only) |
| OpenClaw version | clawdbot (outdated) | **Current OpenClaw** |
| Token savings | "80% claimed" | **83% measured** |
| Production tested | Documentation only | **48 crons, 7 channels** |
| Philosophy | Replace memory-core | **Extend memory-core** |

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
