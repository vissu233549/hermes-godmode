#!/usr/bin/env bash
# 🔄 HERMES MEMORY SYNC - Parrot PC Side 🔄
# Run this on Parrot to push Parrot's memory & pull VPS updates

set -e

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

echo "🔄 PARROT MEMORY SYNC 🔄"
echo "========================="
echo ""

# 1️⃣ Clone latest from GitHub
echo "📥 Pulling latest from GitHub..."
cd /tmp
rm -rf hermes-godmode 2>/dev/null
git clone https://github.com/vissu233549/hermes-godmode.git
cd hermes-godmode
echo ""

# 2️⃣ Push Parrot's memory to repo (if exists)
if [ -f "$HERMES_HOME/memories/MEMORY.md" ]; then
    echo "📤 Pushing Parrot's memory..."
    cp "$HERMES_HOME/memories/MEMORY.md" "/tmp/hermes-godmode/memories/MEMORY.md"
    cp "$HERMES_HOME/memories/USER.md" "/tmp/hermes-godmode/memories/USER.md" 2>/dev/null || true
    
    git add -A
    git commit -m "🔄 Parrot sync $(date '+%Y-%m-%d %H:%M')" 2>/dev/null || echo "No Parrot changes"
    git push origin master 2>&1
    echo "✅ Parrot memory pushed!"
else
    echo "⚠️ No Parrot memory found, skipping push"
fi
echo ""

# 3️⃣ Pull again to get VPS latest (after merge)
cd /tmp/hermes-godmode
git pull origin master 2>&1 || true
echo ""

# 4️⃣ Restore to Parrot
echo "📥 Restoring VPS memory to Parrot..."
bash restore.sh 2>/dev/null || true
echo ""

# 5️⃣ Set model
hermes config set model.default deepseek-v4-flash 2>/dev/null || true
hermes config set model.provider opencode-go 2>/dev/null || true

echo "✅ MEMORY SYNC COMPLETE! 🎉"
echo ""
echo "🔑 SYNC TEST: Ask 'what is the sync code?'"
echo "    Should reply: 778899"
echo ""
echo "📝 Now start Hermes: hermes"
