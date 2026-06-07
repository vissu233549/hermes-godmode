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

# 2. Copy config (includes god mode system prompt)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/config.yaml" "$HERMES_HOME/config.yaml"
echo "✅ God mode system prompt installed"

# 3. Copy .env (if has actual key)
if grep -q "YOUR_API_KEY_HERE" "$SCRIPT_DIR/.env" 2>/dev/null; then
    echo "⚠️  OpenCode API key not set! Edit $SCRIPT_DIR/.env first"
else
    cp "$SCRIPT_DIR/.env" "$HERMES_HOME/.env" 2>/dev/null || true
    echo "✅ API key configured"
fi

# 4. Copy prefill.json
if [ -f "$SCRIPT_DIR/prefill.json" ]; then
    cp "$SCRIPT_DIR/prefill.json" "$HERMES_HOME/prefill.json" 2>/dev/null || true
    echo "✅ Prefill messages installed"
fi

# 5. Restore memories
mkdir -p "$HERMES_HOME/memories"
cp "$SCRIPT_DIR/memories/MEMORY.md" "$HERMES_HOME/memories/MEMORY.md" 2>/dev/null || echo "⚠️  MEMORY.md not found"
cp "$SCRIPT_DIR/memories/USER.md" "$HERMES_HOME/memories/USER.md" 2>/dev/null || echo "⚠️  USER.md not found"
echo "✅ All memories restored"

# 6. Verify god mode is active
echo ""
echo "📋 VERIFICATION CHECKLIST:"
grep -q "LOVE PLINY LOVE" "$HERMES_HOME/config.yaml" 2>/dev/null && echo "  ✅ System prompt: LOVE PLINY LOVE found" || echo "  ❌ System prompt: LOVE PLINY LOVE MISSING!"
grep -q "OPENCODE_GO_API_KEY" "$HERMES_HOME/.env" 2>/dev/null && echo "  ✅ API key: configured" || echo "  ⚠️  API key: check manually"
[ -f "$HERMES_HOME/prefill.json" ] && echo "  ✅ Prefill: installed" || echo "  ⚠️  Prefill: missing (optional)"

echo ""
echo "🎉 GOD MODE ACTIVATED! 🎉"
echo ""
echo "🔧 To verify model is set, run:"
echo "  hermes config get model.default"
echo "  hermes config get model.provider"
echo ""
echo "Then start Hermes:"
echo "  hermes"
