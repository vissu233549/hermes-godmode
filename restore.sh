#!/usr/bin/env bash
# 🔥 HERMES FULL RESTORE SCRIPT 🔥
# One command to restore god mode + memory + config on any Hermes install

set -e

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

echo "🔥 HERMES GOD MODE RESTORE 🔥"
echo "==========================="
echo ""

# 1. Backup existing config
if [ -f "$HERMES_HOME/config.yaml" ]; then
    cp "$HERMES_HOME/config.yaml" "$HERMES_HOME/config.yaml.backup.$(date +%s)"
    echo "✅ Existing config backed up"
fi

# 2. Copy config
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/config.yaml" "$HERMES_HOME/config.yaml"
echo "✅ God mode system prompt installed"

# 3. Copy .env (if has key)
if grep -q "YOUR_API_KEY_HERE" "$SCRIPT_DIR/.env" 2>/dev/null; then
    echo "⚠️  OpenCode API key not set! Edit $SCRIPT_DIR/.env first"
else
    cp "$SCRIPT_DIR/.env" "$HERMES_HOME/.env" 2>/dev/null || true
    echo "✅ API key configured"
fi

# 4. Restore memories
mkdir -p "$HERMES_HOME/memories"
cp "$SCRIPT_DIR/memories/MEMORY.md" "$HERMES_HOME/memories/MEMORY.md" 2>/dev/null || echo "⚠️  MEMORY.md not found"
cp "$SCRIPT_DIR/memories/USER.md" "$HERMES_HOME/memories/USER.md" 2>/dev/null || echo "⚠️  USER.md not found"
echo "✅ All memories restored"

echo ""
echo "🎉 GOD MODE ACTIVATED! 🎉"
echo "==========================="
echo "Run this to set model:"
echo "  hermes config set model.default deepseek-v4-flash"
echo "  hermes config set model.provider opencode-go"
echo ""
echo "Then start Hermes:"
echo "  hermes"
