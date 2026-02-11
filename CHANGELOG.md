# Changelog

All notable changes to this project will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.1.0] - 2026-02-11

### Fixed
- **CRITICAL: Doctor crash on empty workspaces** — `find` on non-existent `memory/` caused exit 1 at duplicate/suggestion checks
- **Help output escape codes** — Color variables using single-quoted `'\033[...]'` didn't render in `cat <<EOF`; switched to `$'\033[...]'` syntax
- **Health score too lenient** — 491% oversize scored 70/100 "Good"; now scales: -30 (1x), -50 (2x+), -70 (4x+) penalty

### Changed
- **README completely rewritten** — Added Quick Start section, navigation buttons, version/stars/last-commit badges, Doctor output example, clearer structure
- **Health scoring** — Proportional penalty for oversized MEMORY.md (Critical at 4x+ over limit)
- Version bump to 2.1.0

### Added
- **Navigation buttons** in README (Quick Start, CLI, Results, How It Works, FAQ)
- **Version badge**, **GitHub stars badge**, **Last commit badge**
- **Doctor output example** in README for first-time users
- **Option B: curl install** — single-file download without cloning
- Guard clauses for all `find` calls on potentially missing directories

## [2.0.0] - 2026-02-10

### Changed
- **Repositioned as lightweight maintenance tool** — complementary to Mem0, Supermemory, QMD (not a competitor)
- README rewritten with "Install once, forget forever" philosophy
- Doctor expanded from 4-step to 5-step diagnostic (added stale content check)
- Dedupe false positive reduction: filtered table rows, code fences, box-drawing chars, URLs, shell code (93 → 56 on production workspace)
- Version bump to 2.0.0

### Added
- Stale content detection in `doctor` command
- Compatibility matrix showing how MemoryBox works alongside other memory tools
- "What This Is (and Isn't)" section in README

## [1.0.0] - 2026-02-10

### Added
- **Phase 1**: Repository, README, migration script, archive script, size check, templates
- **Phase 2**: `memorybox` CLI with 6 commands: `analyze`, `split`, `archive`, `report`, `health`, `init`
- **Phase 3**: 4 advanced commands: `dedupe`, `stale`, `suggest`, `doctor`
- 10 total commands, all zero-dependency pure bash
- CI workflow with ShellCheck + integration tests
- Origin story linking to openclaw-self-healing companion project
- Production-tested on 7 Discord channels, 48 crons

[2.0.0]: https://github.com/Ramsbaby/openclaw-memorybox/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/Ramsbaby/openclaw-memorybox/releases/tag/v1.0.0
