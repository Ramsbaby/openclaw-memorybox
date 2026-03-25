#!/usr/bin/env bash
set -euo pipefail
# openclaw-memorybox installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Ramsbaby/openclaw-memorybox/main/install.sh | bash

REPO="https://raw.githubusercontent.com/Ramsbaby/openclaw-memorybox/main"
INSTALL_DIR="${MEMORYBOX_DIR:-$HOME/.local/bin}"
SKILL_DIR="${CLAUDE_SKILL_DIR:-$HOME/.claude/skills}"

echo "📦 Installing openclaw-memorybox..."

# Install CLI
mkdir -p "$INSTALL_DIR"
curl -fsSL "$REPO/bin/memorybox" -o "$INSTALL_DIR/memorybox"
chmod +x "$INSTALL_DIR/memorybox"
echo "✓ CLI installed: $INSTALL_DIR/memorybox"

# Install Claude Code skill
mkdir -p "$SKILL_DIR"
curl -fsSL "$REPO/SKILL.md" -o "$SKILL_DIR/memorybox.md"
echo "✓ Skill installed: $SKILL_DIR/memorybox.md"

# Check PATH
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo ""
  echo "⚠️  Add to your shell profile:"
  echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""
echo "✅ Done! Try: memorybox health"
echo "   In Claude Code: /memorybox health"
