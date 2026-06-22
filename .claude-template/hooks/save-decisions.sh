#!/usr/bin/env bash
# Agency SessionEnd decision-capture.
# Runs a headless `claude -p` pass over the session transcript and records ONLY
# durable decisions (layout, architecture, libraries, code patterns) into
# .claude/decisions.md, so future sessions continue with the right context.
#
# Register under hooks.SessionEnd in .claude/settings.json.

set -uo pipefail

# Re-entry guard: the claude -p call below itself ends a session and would
# re-trigger this hook. The env var (set when we invoke claude) stops the loop.
[ -n "${AGENCY_DECISIONS_RUNNING:-}" ] && exit 0

input=$(cat)
get() { printf '%s' "$input" | python3 -c "import sys,json;print(json.load(sys.stdin).get('$1',''))" 2>/dev/null; }
TRANSCRIPT=$(get transcript_path)
PROJECT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT" 2>/dev/null || exit 0

# need a transcript + a git repo (skip throwaway dirs)
[ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ] || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
# skip trivial sessions (cheap guard against paying for read-only chats)
[ "$(wc -l < "$TRANSCRIPT" 2>/dev/null || echo 0)" -ge 20 ] || exit 0
command -v claude >/dev/null 2>&1 || exit 0

DOC=".claude/decisions.md"
mkdir -p .claude
[ -f "$DOC" ] || printf '# Codebase Decisions\n\nDurable decisions for future sessions. Append-only; update an entry only if it changed.\n\n## Layout\n\n## Architecture\n\n## Libraries\n\n## Patterns\n' > "$DOC"

TODAY=$(date +%Y-%m-%d)
read -r -d '' PROMPT <<EOF
You maintain this project's decision log for future AI coding sessions.

Read the session transcript at: $TRANSCRIPT
Then update the decision log at: $DOC

Record ONLY durable, important decisions made in this session about:
- project layout / file structure
- architecture
- library / framework / tool choices (include what was REJECTED and why)
- code patterns / conventions adopted

Rules:
- Organize under the existing sections: Layout, Architecture, Libraries, Patterns.
- Each entry concise: "- $TODAY: <decision>. Why: <reason>."
- Update an existing entry if this session changed it; never duplicate.
- Skip routine edits, bug fixes, exploration, and anything transient.
- If nothing durable was decided, make NO changes and write nothing.
Edit only $DOC.
EOF

# Run bounded + detached so session exit isn't delayed. Guard env stops recursion.
AGENCY_DECISIONS_RUNNING=1 nohup timeout 180 claude -p "$PROMPT" \
  --allowedTools "Read,Edit,Write" >/dev/null 2>&1 &

exit 0
