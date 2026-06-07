# 🔥 HERMES GOD MODE — SYNC HUB

**Sync your Hermes memory, config & god mode between VPS ↔ Parrot via GitHub.**

---

## 📤 VPS: Backup Memory (Run this on me)
```
bash ~/.hermes/scripts/backup-memory.sh
```
Or just tell me: **"bangaram backup memory"** ✅

---

## 📥 Parrot PC: Restore & Sync
```bash
cd /tmp && rm -rf hermes-godmode 2>/dev/null; git clone https://github.com/vissu233549/hermes-godmode.git && cd hermes-godmode && bash restore.sh && hermes config set model.default deepseek-v4-flash && hermes config set model.provider opencode-go && echo "🔥 GOD MODE RESTORED!"
```

---

## 📂 What's Synced

| File | What |
|------|------|
| `memories/MEMORY.md` | All user info, preferences, setup details |
| `memories/USER.md` | Personality, tone, communication style |
| `config.yaml` | God mode jailbreak system prompt |
| `.env` | OpenCode API key (set once) |
| `restore.sh` | One-click restore script |

---

## 🔄 Auto-Sync
Cron job backs up memory daily at 2 AM.
