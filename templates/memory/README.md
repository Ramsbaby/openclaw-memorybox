# Memory Directory — 3-Tier Architecture

> Zero-dependency hierarchical memory for OpenClaw agents.

## Structure

```
memory/
├── YYYY-MM-DD.md          # Daily logs (auto-loaded: today + yesterday)
├── domains/               # Tier 2: Topic reference (memory_search)
│   ├── persona.md         #   Response style, formatting rules
│   ├── decisions.md       #   Past decisions, incident lessons
│   └── milestones.md      #   Achievements, project history
├── projects/              # Tier 2: Per-project details
├── drafts/                # Workspace: Blog/marketing drafts
├── reports/               # Workspace: Audit/review reports
├── incidents/             # Workspace: Incident logs
└── archive/               # Tier 3: Old data (14+ day logs)
```

## Tier Loading

| Tier | Auto-loaded? | Search? | Purpose |
|------|-------------|---------|---------|
| 1 (MEMORY.md) | ✅ Every session | ✅ | Core facts |
| 1.5 (daily logs) | ✅ Today+yesterday | ✅ | Recent context |
| 2 (domains/) | ❌ On-demand | ✅ | Detailed reference |
| 3 (archive/) | ❌ Manual only | ✅ | Historical data |
