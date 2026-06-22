#!/usr/bin/env bash
# Agency coding-standards loader.
# Runs as a Claude Code SessionStart hook. Detects which stacks exist in the
# current repo, fetches ONLY the matching standard files from the agency-standards
# GitHub repo, and prints them to stdout (Claude Code injects stdout into context).
#
# Cost-aware: fetches only relevant topic files, caches them for TTL_MIN minutes,
# and runs once per session — not per prompt.

set -uo pipefail

# --- config -----------------------------------------------------------------
ORG="${AGENCY_STANDARDS_ORG:-Hyperion-AI-Agency}"
REPO="${AGENCY_STANDARDS_REPO:-agency-standards}"
REF="${AGENCY_STANDARDS_REF:-main}"
BASE="https://raw.githubusercontent.com/${ORG}/${REPO}/${REF}/standards"
CACHE_DIR="${HOME}/.cache/agency-standards"
TTL_MIN="${AGENCY_STANDARDS_TTL_MIN:-1440}"   # 24h
# ---------------------------------------------------------------------------

mkdir -p "$CACHE_DIR"

# Always-on craft rules (language-agnostic)
topics=(
  "general/clean-code.md"
  "general/naming.md"
  "general/functions.md"
  "general/comments.md"
  "general/error-handling.md"
  "general/code-structure.md"
  "patterns/anti-bloat.md"
  "patterns/abstractions.md"
)

# TypeScript / JS
if [ -f package.json ]; then
  topics+=( "typescript/naming.md" "typescript/functions.md" )
  grep -q '"next"'  package.json 2>/dev/null && topics+=( "typescript/nextjs.md" )
  grep -q '"react"' package.json 2>/dev/null && topics+=( "typescript/react-patterns.md" )
fi

# Python
if [ -f pyproject.toml ] || [ -f requirements.txt ] || compgen -G "*.py" >/dev/null 2>&1; then
  topics+=( "python/naming.md" "python/functions.md" )
  grep -rqi "fastapi" pyproject.toml requirements.txt 2>/dev/null && topics+=( "python/fastapi-patterns.md" )
fi

# Terraform
if compgen -G "*.tf" >/dev/null 2>&1 || [ -d terraform ]; then
  topics+=( "terraform/structure.md" "terraform/naming.md" )
fi

echo "# Agency Coding Standards (auto-loaded for this repo's detected stack)"
echo "# Follow these. Linters + CI enforce the deterministic subset; these cover craft."
echo

for t in "${topics[@]}"; do
  cache_file="${CACHE_DIR}/$(echo "$t" | tr '/' '_')"
  # refresh if missing or stale
  if [ -z "$(find "$cache_file" -mmin "-${TTL_MIN}" 2>/dev/null)" ]; then
    curl -fsSL "${BASE}/${t}" -o "$cache_file" 2>/dev/null || true
  fi
  if [ -s "$cache_file" ]; then
    echo "----- ${t} -----"
    cat "$cache_file"
    echo
  fi
done
