#!/usr/bin/env bash
# Install the agency standards system into a target repo:
#   - SessionStart standards loader, PreToolUse guardrails, SessionEnd decision capture
#   - Mat Pocock skills (tdd, to-prd, to-issues, grill-me) — MIT, attribution preserved
#   - registers the hooks in settings (local-only for client repos, committed for own repos)
#
# Usage:
#   install.sh [TARGET_DIR] [--client|--own]
#     TARGET_DIR  repo to install into (default: cwd)
#     --client    register hooks in .claude/settings.local.json (gitignored; client repos)  [default]
#     --own       register hooks in .claude/settings.json (committed; your own repos)

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$PWD}"
MODE="client"
[ "${2:-}" = "--own" ] && MODE="own"
[ "${1:-}" = "--client" ] && { TARGET="$PWD"; MODE="client"; }
[ "${1:-}" = "--own" ] && { TARGET="$PWD"; MODE="own"; }

TARGET="$(cd "$TARGET" && pwd)"
echo "Installing agency standards into: $TARGET  (mode: $MODE)"

# --- 1. hooks --------------------------------------------------------------
mkdir -p "$TARGET/.claude/hooks"
cp "$HERE/.claude-template/hooks/"*.sh "$TARGET/.claude/hooks/"
chmod +x "$TARGET/.claude/hooks/"*.sh
echo "  hooks: fetch-standards, guardrails, save-decisions"

# --- 2. settings (merge, don't clobber) ------------------------------------
SETTINGS_FILE=".claude/settings.json"
[ "$MODE" = "client" ] && SETTINGS_FILE=".claude/settings.local.json"
python3 - "$TARGET/$SETTINGS_FILE" <<'PY'
import json, os, sys
path = sys.argv[1]
data = json.load(open(path)) if os.path.exists(path) else {}
hooks = data.setdefault("hooks", {})
hooks["SessionStart"] = [{"hooks":[{"type":"command","command":"$CLAUDE_PROJECT_DIR/.claude/hooks/fetch-standards.sh"}]}]
hooks["PreToolUse"] = [{"matcher":"Bash|Edit|Write|MultiEdit|Read|NotebookEdit","hooks":[{"type":"command","command":"$CLAUDE_PROJECT_DIR/.claude/hooks/guardrails.sh"}]}]
hooks["SessionEnd"] = [{"hooks":[{"type":"command","command":"$CLAUDE_PROJECT_DIR/.claude/hooks/save-decisions.sh"}]}]
os.makedirs(os.path.dirname(path), exist_ok=True)
json.dump(data, open(path,"w"), indent=2)
print(f"  settings: {os.path.basename(path)} (SessionStart, PreToolUse, SessionEnd)")
PY

# --- 3. Mat Pocock skills (MIT) --------------------------------------------
SKILLS=(engineering/tdd engineering/to-prd engineering/to-issues productivity/grill-me)
LOCAL_SRC="$HOME/projects/mattpocock-skills"
SRC=""
if [ -d "$LOCAL_SRC/skills" ]; then
  SRC="$LOCAL_SRC"
else
  TMP="$(mktemp -d)"
  if git clone --depth 1 -q https://github.com/mattpocock/skills.git "$TMP" 2>/dev/null; then
    SRC="$TMP"
  fi
fi

if [ -n "$SRC" ]; then
  mkdir -p "$TARGET/.claude/skills"
  for s in "${SKILLS[@]}"; do
    name="$(basename "$s")"
    if [ -d "$SRC/skills/$s" ]; then
      rm -rf "$TARGET/.claude/skills/$name"
      cp -R "$SRC/skills/$s" "$TARGET/.claude/skills/$name"
    fi
  done
  # preserve attribution
  [ -f "$SRC/LICENSE" ] && cp "$SRC/LICENSE" "$TARGET/.claude/skills/MATTPOCOCK-LICENSE"
  echo "  skills: tdd, to-prd, to-issues, grill-me (Mat Pocock, MIT — license preserved)"
else
  echo "  skills: SKIPPED (no local clone at $LOCAL_SRC and clone failed)"
fi

echo "Done. In a fresh Claude session run /hooks to approve, then restart."
