#!/usr/bin/env bash
# 🔄 HERMES MEMORY SYNC - Parrot PC Side 🔄
# Run this on Parrot to push Parrot's memory & pull VPS updates
# Fixed: Restore VPS latest FIRST, then merge Parrot's additions

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

# 2️⃣ Backup Parrot's current local memory (if exists)
if [ -f "$HERMES_HOME/memories/MEMORY.md" ]; then
    echo "📤 Backing up Parrot's current memory..."
    cp "$HERMES_HOME/memories/MEMORY.md" "/tmp/parrot-memory-backup.md" 2>/dev/null || true
    cp "$HERMES_HOME/memories/USER.md" "/tmp/parrot-user-backup.md" 2>/dev/null || true
fi

# 3️⃣ Restore VPS version to Parrot FIRST (so VPS's updates come through)
echo "📥 Restoring VPS memory to Parrot..."
cp "memories/MEMORY.md" "$HERMES_HOME/memories/MEMORY.md" 2>/dev/null || true
cp "memories/USER.md" "$HERMES_HOME/memories/USER.md" 2>/dev/null || true
echo "✅ VPS memory restored!"
echo ""

# 4️⃣ Merge any Parrot-only additions back in (lines in Parrot backup not in VPS version)
if [ -f "/tmp/parrot-user-backup.md" ]; then
    echo "🔄 Merging Parrot-specific additions..."
    
    # Find lines in Parrot backup that aren't in the repo version
    while IFS= read -r line; do
        # Skip blank/separator lines
        [ -z "$line" ] && continue
        [ "$line" = "§" ] && continue
        
        # Check if this line exists in the repo version
        if ! grep -Fqx "$line" "memories/USER.md" 2>/dev/null; then
            echo "   ➕ Adding: ${line:0:60}..."
            echo "$line" >> "memories/USER.md"
        fi
    done < "/tmp/parrot-user-backup.md"
    
    # Same for MEMORY.md
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        [ "$line" = "§" ] && continue
        if ! grep -Fqx "$line" "memories/MEMORY.md" 2>/dev/null; then
            echo "   ➕ Adding: ${line:0:60}..."
            echo "$line" >> "memories/MEMORY.md"
        fi
    done < "/tmp/parrot-memory-backup.md"
    
    echo "✅ Merge complete!"
fi
echo ""

# 5️⃣ Push merged memory back to GitHub
echo "📤 Pushing merged memory to GitHub..."
git add -A
git commit -m "🔄 Parrot sync $(date '+%Y-%m-%d %H:%M')" 2>/dev/null || echo "No Parrot changes"
git push origin master 2>&1 || echo "Push done or no changes"
echo "✅ Memory pushed!"
echo ""

# 6️⃣ Restore the latest (post-merge) version to Parrot
cp "memories/MEMORY.md" "$HERMES_HOME/memories/MEMORY.md" 2>/dev/null || true
cp "memories/USER.md" "$HERMES_HOME/memories/USER.md" 2>/dev/null || true

# 7️⃣ Set model
hermes config set model.default deepseek-v4-flash 2>/dev/null || true
hermes config set model.provider opencode-go 2>/dev/null || true

# Cleanup
rm -f /tmp/parrot-memory-backup.md /tmp/parrot-user-backup.md

echo ""
echo "✅ MEMORY SYNC COMPLETE! 🎉"
echo ""
echo "🔑 SYNC TEST: Ask 'what is the sync code?'"
echo "    Should reply: 778899"
echo ""
echo "🏠 HOME PHONE TEST: Ask 'what is my home phone number?'"
echo "    Should reply: 233549"
echo ""
echo "📝 Now start Hermes: hermes"
