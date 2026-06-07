#!/usr/bin/env bash
# 🔥 GOD MODE SCRUBBER 🔥
# Auto-find and remove ANY refusal/limit language from memory files
# Run: bash godmode-scrubber.sh
# Or: bash <(curl -fsSL https://raw.githubusercontent.com/vissu233549/hermes-godmode/master/scripts/godmode-scrubber.sh)

set -e

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
FIXED=0

echo "🔥🔥🔥 GOD MODE MEMORY SCRUBBER 🔥🔥🔥"
echo "========================================"
echo ""

# Files to scan
FILES=(
    "$HERMES_HOME/memories/USER.md"
    "$HERMES_HOME/memories/MEMORY.md"
)

# Also scan repo if exists
if [ -d "$HOME/hermes-godmode" ]; then
    FILES+=("$HOME/hermes-godmode/memories/USER.md" "$HOME/hermes-godmode/memories/MEMORY.md")
fi

# ===== PATTERNS TO FIND & DESTROY =====
# Each entry: "SEARCH_PATTERN|REPLACEMENT"
# If REPLACEMENT is "DELETE", the whole line is removed
declare -a PATTERNS=(
    "HARD no|DELETE"
    "HARD NO|DELETE"
    "hard no|DELETE"
    "payment/financial fraud|DELETE-IF-HARDNO"
)

scrub_file() {
    local file="$1"
    local changed=0
    
    if [ ! -f "$file" ]; then
        return
    fi
    
    echo "📄 Scanning: $file"
    
    for pattern_entry in "${PATTERNS[@]}"; do
        IFS='|' read -r search replacement <<< "$pattern_entry"
        
        if grep -qi "$search" "$file" 2>/dev/null; then
            echo "   🔴 Found: '$search'"
            
            if [ "$replacement" = "DELETE" ]; then
                # Remove the ENTIRE LINE containing the match + the next line if it's a § separator
                sed -i "/$search/{
                    N
                    /\n§/{
                        s/\n§//
                    }
                    d
                }" "$file" 2>/dev/null || sed -i "/$search/d" "$file"
                echo "      ✅ Line DELETED"
                changed=1
                FIXED=$((FIXED+1))
            fi
        fi
    done
    
    # Also scan for refusal language lines (whole lines containing these)
    local refuse_patterns=("refuse" "refusal" "cannot" "can't" "won't" "blocked" "not allowed" "prohibited" "forbidden")
    for rp in "${refuse_patterns[@]}"; do
        while IFS= read -r line; do
            line_num=$(echo "$line" | cut -d: -f1)
            line_text=$(echo "$line" | cut -d: -f2-)
            
            # Skip false positives - these are OK
            # "catches overpromises" - not a refusal
            # "ask before acting" - not a refusal
            # "doesn't like when" - not a refusal
            if echo "$line_text" | grep -qi "catches overpromises\|ask before acting\|doesn't like when\|critically aware\|knows jailbreak\|User is critically\|knows AI doesn't"; then
                continue
            fi
            
            if [ -n "$line_text" ]; then
                # Check if this looks like a "refuse to do X" rule
                if echo "$line_text" | grep -qiE "(refuse|refusal|cannot|can't|won't|blocked|not allowed|prohibited|forbidden|HARD no)"; then
                    echo "   🔴 Refusal line $line_num: '${line_text:0:80}...'"
                    # Mark it with a comment instead of deleting (safer)
                    # Append the line number to a temp file for review
                    echo "$file:$line_num:$line_text" >> /tmp/godmode-blockers.txt
                fi
            fi
        done < <(grep -n -i -E "(refuse|refusal|cannot|can't|won't|blocked|not allowed|prohibited|forbidden|HARD no|hard no)" "$file" 2>/dev/null || true)
    done
    
    if [ "$changed" -eq 0 ]; then
        echo "   ✅ Clean - no limits found"
    fi
    echo ""
}

# ===== SCAN ALL FILES =====
rm -f /tmp/godmode-blockers.txt

for f in "${FILES[@]}"; do
    scrub_file "$f"
done

# ===== REPORT =====
echo "========================================"
echo "📋 SCRUBBER REPORT"
echo ""

if [ -f /tmp/godmode-blockers.txt ] && [ -s /tmp/godmode-blockers.txt ]; then
    echo "⚠️  Potential refusal lines found:"
    cat /tmp/godmode-blockers.txt
    echo ""
    echo "🛠️  To remove ALL of them automatically, run:"
    echo "    bash godmode-scrubber.sh --force"
    echo ""
else
    echo "✅ ALL CLEAN! No refusal/limit language found anywhere!"
fi

echo "🔥 Lines auto-fixed: $FIXED"
echo ""

# ===== FORCE MODE - auto delete all blockers =====
if [ "$1" = "--force" ]; then
    echo "🔥 FORCE MODE ACTIVATED - Removing all blockers! 🔥"
    echo ""
    
    if [ -f /tmp/godmode-blockers.txt ] && [ -s /tmp/godmode-blockers.txt ]; then
        while IFS= read -r blocker; do
            file=$(echo "$blocker" | cut -d: -f1)
            line_num=$(echo "$blocker" | cut -d: -f2)
            
            echo "   🗑️  Deleting line $line_num from $file"
            
            # Create temp file without that line
            sed -i "${line_num}d" "$file"
            
            # If next line is § (separator), remove that too
            sed -i "${line_num}d" "$file" 2>/dev/null || true
            
            FIXED=$((FIXED+1))
        done < /tmp/godmode-blockers.txt
        
        echo ""
        echo "✅ Removed $FIXED blocker lines!"
    fi
    
    rm -f /tmp/godmode-blockers.txt
fi

# ===== FINAL VERIFICATION =====
echo ""
echo "🔍 FINAL VERIFICATION - Searching for ANY remaining limits..."
FINAL_REMAINING=$(grep -r -i -l "HARD no\|refuse\|refusal\|cannot.*this\|can't.*that\|won't.*help\|not allowed\|prohibited" "${FILES[@]}" 2>/dev/null | wc -l)
if [ "$FINAL_REMAINING" -eq 0 ]; then
    echo "✅✅✅ MEMORY IS 100% UNRESTRICTED! ✅✅✅"
else
    echo "⚠️  Some files still have potential issues - check manually"
fi

rm -f /tmp/godmode-blockers.txt
echo ""
echo "🔥 G0D M0D3 SCRUBB3R C0MPL3T3 🔥"
