#!/usr/bin/env bash
# Agency PreToolUse guardrails.
# Blocks destructive Bash commands and access to secret files.
# Exit 2 = block the tool call; the stderr message is shown to the agent.
#
# Register for matcher "Bash|Edit|Write|MultiEdit|Read" in .claude/settings.json
# under hooks.PreToolUse.

set -uo pipefail

input=$(cat)

field() { printf '%s' "$input" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('tool_input',{}).get('$1',''))" 2>/dev/null; }
tool=$(printf '%s' "$input" | python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null)

block() { echo "BLOCKED by agency guardrails: $1" >&2; exit 2; }

# ---- secret-file protection (read + write) --------------------------------
check_secret_path() {
  local p="$1"
  [ -z "$p" ] && return
  local base; base=$(basename "$p")
  # allow example/template env files
  case "$base" in
    .env.example|.env.sample|.env.template|*.example|*.sample) return ;;
  esac
  case "$p" in
    *.env|*/.env|.env|*.env.*|*/.ssh/*|*/.aws/credentials|*id_rsa*|*id_ed25519*) \
      block "secret file '$p' — env/keys are off-limits. Reference variable NAMES, never read/write the values." ;;
    *.pem|*.key|*.p12|*.pfx|*.keystore|*.jks|*.npmrc|*.pypirc|*credentials*|*secret*|*.crt) \
      block "credential/key file '$p' — off-limits to agents." ;;
  esac
}

# ---- dangerous bash -------------------------------------------------------
check_bash() {
  local c="$1"
  [ -z "$c" ] && return
  # recursive force-delete of root/home/wildcards
  echo "$c" | grep -Eq 'rm[[:space:]]+(-[a-zA-Z]*[rf][a-zA-Z]*[[:space:]]+)+(-[a-zA-Z]+[[:space:]]+)*(/|~|/\*|\$HOME|\.\.)([[:space:]]|$)' \
    && block "recursive force-delete of a root/home path."
  echo "$c" | grep -Eq '\brm[[:space:]]+-[a-zA-Z]*[rf]' && echo "$c" | grep -Eq '(/\*|[[:space:]]/[[:space:]]?$|~[[:space:]]?$)' \
    && block "dangerous rm target."
  # pipe-to-shell installers
  echo "$c" | grep -Eq '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash|zsh)\b' \
    && block "piping a download straight into a shell (curl|sh). Download, inspect, then run."
  # fork bomb
  echo "$c" | grep -Eq ':\(\)[[:space:]]*\{[[:space:]]*:\|:' && block "fork bomb."
  # disk/filesystem destroyers
  echo "$c" | grep -Eq '\bdd\b[^|]*of=/dev/(sd|nvme|disk|hd)' && block "raw dd write to a block device."
  echo "$c" | grep -Eq '\bmkfs(\.|[[:space:]])' && block "filesystem format (mkfs)."
  echo "$c" | grep -Eq '>[[:space:]]*/dev/(sd|nvme|disk|hd)[a-z]' && block "redirect to a raw block device."
  # recursive 777
  echo "$c" | grep -Eq 'chmod[[:space:]]+(-[a-zA-Z]*R[a-zA-Z]*[[:space:]]+)?777[[:space:]]+/' && block "chmod 777 on a root path."
  # history/secret wipe
  echo "$c" | grep -Eq '\bshred\b|rm[[:space:]]+.*\.bash_history' && block "destroying history/secure-wipe."
  # force push to main/master
  echo "$c" | grep -Eq 'git[[:space:]]+push[[:space:]]+.*(--force|-f)\b' && echo "$c" | grep -Eq '\b(main|master)\b' \
    && block "force-push to main/master."
}

case "$tool" in
  Bash)               check_bash "$(field command)" ;;
  Edit|Write|MultiEdit|Read|NotebookEdit) check_secret_path "$(field file_path)" ;;
esac

exit 0
