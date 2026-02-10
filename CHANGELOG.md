# Changelog

All notable changes to this project will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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
