#!/bin/bash
# migrate.sh — Migrate flat OpenClaw memory to 3-Tier structure
# Usage: bash migrate.sh [workspace_path]
# Non-destructive: creates backup before any changes

set -euo pipefail

WORKSPACE="${1:-$HOME/openclaw}"
MEMORY_DIR="$WORKSPACE/memory"
BACKUP_DIR="$MEMORY_DIR/archive/pre-3tier-backup-$(date +%Y%m%d)"

echo "🧠 OpenClaw MemoryBox Migration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Workspace: $WORKSPACE"
echo ""

# Validate workspace
if [ ! -d "$MEMORY_DIR" ]; then
  echo "❌ Memory directory not found: $MEMORY_DIR"
  echo "   Make sure this is an OpenClaw workspace."
  exit 1
fi

# Step 1: Backup
echo "📦 Step 1: Creating backup..."
mkdir -p "$BACKUP_DIR"
if [ -f "$WORKSPACE/MEMORY.md" ]; then
  cp "$WORKSPACE/MEMORY.md" "$BACKUP_DIR/MEMORY.md.bak"
  echo "   ✅ MEMORY.md backed up"
fi
echo ""

# Step 2: Create directory structure
echo "📁 Step 2: Creating 3-Tier directories..."
mkdir -p "$MEMORY_DIR/domains"
mkdir -p "$MEMORY_DIR/projects"
mkdir -p "$MEMORY_DIR/drafts"
mkdir -p "$MEMORY_DIR/reports"
mkdir -p "$MEMORY_DIR/incidents"
mkdir -p "$MEMORY_DIR/archive"
echo "   ✅ Created: domains/ projects/ drafts/ reports/ incidents/ archive/"
echo ""

# Step 3: Categorize and move non-daily files
echo "🔀 Step 3: Organizing files..."

MOVED=0

# Move blog/marketing drafts
for pattern in blog-* devto-* reddit-* twitter-* hn-* marketing-* discord-*; do
  for f in "$MEMORY_DIR"/$pattern; do
    [ -f "$f" ] || continue
    mv "$f" "$MEMORY_DIR/drafts/"
    echo "   → drafts/$(basename "$f")"
    MOVED=$((MOVED + 1))
  done
done

# Move reports/audits
for pattern in self-review-* quality-check-* audit-* validation-* verification-* evaluation-*; do
  for f in "$MEMORY_DIR"/$pattern; do
    [ -f "$f" ] || continue
    mv "$f" "$MEMORY_DIR/reports/"
    echo "   → reports/$(basename "$f")"
    MOVED=$((MOVED + 1))
  done
done

# Move incidents
for f in "$MEMORY_DIR"/incident-*; do
  [ -f "$f" ] || continue
  mv "$f" "$MEMORY_DIR/incidents/"
  echo "   → incidents/$(basename "$f")"
  MOVED=$((MOVED + 1))
done

echo "   ✅ Moved $MOVED files"
echo ""

# Step 4: Archive old daily logs (14+ days)
echo "🗄️  Step 4: Archiving old daily logs (14+ days)..."
ARCHIVED=0
find "$MEMORY_DIR" -maxdepth 1 -name "202?-??-??.md" -mtime +14 2>/dev/null | while read f; do
  mv "$f" "$MEMORY_DIR/archive/"
  echo "   → archive/$(basename $f)"
  ARCHIVED=$((ARCHIVED + 1))
done
echo "   ✅ Archived old logs"
echo ""

# Step 5: Check MEMORY.md size
echo "📏 Step 5: MEMORY.md size check..."
if [ -f "$WORKSPACE/MEMORY.md" ]; then
  SIZE=$(wc -c < "$WORKSPACE/MEMORY.md")
  echo "   Current size: ${SIZE} bytes"
  if [ "$SIZE" -gt 10000 ]; then
    echo "   ⚠️  WARNING: MEMORY.md exceeds 10KB target!"
    echo "   Recommendation: Move detailed sections to memory/domains/*.md"
    echo ""
    echo "   Suggested domain files:"
    echo "   - memory/domains/persona.md    (communication style, formatting)"
    echo "   - memory/domains/decisions.md  (past decisions, lessons learned)"
    echo "   - memory/domains/milestones.md (achievements, project history)"
  else
    echo "   ✅ Under 10KB target"
  fi
else
  echo "   ℹ️  No MEMORY.md found (will be created on first agent run)"
fi
echo ""

# Step 6: Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Migration complete!"
echo ""
echo "Final structure:"
echo "  memory/"
for d in domains projects drafts reports incidents archive; do
  COUNT=$(find "$MEMORY_DIR/$d" -type f 2>/dev/null | wc -l | tr -d ' ')
  echo "  ├── $d/ ($COUNT files)"
done
DAILY=$(find "$MEMORY_DIR" -maxdepth 1 -name "202?-??-??.md" 2>/dev/null | wc -l | tr -d ' ')
echo "  └── *.md ($DAILY daily logs)"
echo ""
echo "Next steps:"
echo "  1. Review memory/domains/ — add persona.md, decisions.md, milestones.md"
echo "  2. Trim MEMORY.md to ≤10KB (move details to domains/)"
echo "  3. Update AGENTS.md with memory protocol"
echo "  4. (Optional) Add weekly maintenance cron"
echo ""
echo "Backup saved: $BACKUP_DIR"
