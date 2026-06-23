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
  "general/modern-language.md"
  "patterns/anti-bloat.md"
  "patterns/abstractions.md"
)

# Detect deps across root + subdir manifests (monorepo-aware), excluding node_modules.
pkgjson=$(find . -maxdepth 3 -name package.json -not -path '*/node_modules/*' 2>/dev/null)
pydeps=$(find . -maxdepth 3 \( -name pyproject.toml -o -name requirements.txt \) -not -path '*/node_modules/*' 2>/dev/null)
dep_in_pkg() { [ -n "$pkgjson" ] && echo "$pkgjson" | xargs grep -lq "$1" 2>/dev/null; }

# TypeScript / JS
if [ -n "$pkgjson" ]; then
  topics+=( "typescript/naming.md" "typescript/functions.md" )
  dep_in_pkg '"next"'    && topics+=( "typescript/nextjs.md" )
  dep_in_pkg '"react"'   && topics+=( "typescript/react-patterns.md" "typescript/react-components.md" )
  dep_in_pkg '"@nestjs/' && topics+=( "typescript/nestjs.md" )
fi

# Python
if [ -n "$pydeps" ] || compgen -G "*.py" >/dev/null 2>&1; then
  topics+=( "python/naming.md" "python/functions.md" )
  [ -n "$pydeps" ] && echo "$pydeps" | xargs grep -liq "fastapi" 2>/dev/null && topics+=( "python/fastapi-patterns.md" )
fi

# Terraform
if compgen -G "*.tf" >/dev/null 2>&1 || [ -d terraform ]; then
  topics+=( "terraform/structure.md" "terraform/naming.md" )
fi

echo "# Agency Coding Standards (auto-loaded for this repo's detected stack)"
echo "# Follow these. Linters + CI enforce the deterministic subset; these cover craft."
echo "# ON-DEMAND: for code smells, refactoring techniques, and design-pattern choices,"
echo "# query the 'agency-standards' MCP (list_standards / search_standards / get_standard)"
echo "# — e.g. before refactoring or adding any abstraction. Don't guess; look it up."
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

# Surface this project's saved decisions (written by the SessionEnd hook) so the
# session continues with prior architecture / library / pattern choices.
DEC="${CLAUDE_PROJECT_DIR:-.}/.claude/decisions.md"
if [ -s "$DEC" ]; then
  echo "----- project decisions (.claude/decisions.md) — honor these -----"
  cat "$DEC"
  echo
fi
