# agency-standards

Single source of truth for HyperionAI coding standards. AI agents auto-load the
relevant slice per repo. Durable craft rules only (naming, functions, patterns,
anti-bloat) — NOT framework syntax (that goes stale; use a live-docs MCP).

## How it works

1. This repo is **public** on GitHub. Topic files live under `standards/`.
2. Each client repo carries a **SessionStart hook** (`.claude/hooks/fetch-standards.sh`).
3. On session start the hook detects the repo's stack (package.json / pyproject / *.tf),
   fetches ONLY the matching standard files from this repo's raw URLs, caches them
   (~24h), and injects them into the agent's context. No agent decision = no drift.

## Install into a client repo

```bash
# from the client repo root
mkdir -p .claude/hooks
curl -fsSL https://raw.githubusercontent.com/Hyperion-AI-Agency/agency-standards/main/.claude-template/hooks/fetch-standards.sh \
  -o .claude/hooks/fetch-standards.sh
chmod +x .claude/hooks/fetch-standards.sh
# merge .claude-template/settings.json into the repo's .claude/settings.json
```

Override org/repo/ref/ttl via env: `AGENCY_STANDARDS_ORG`, `AGENCY_STANDARDS_REPO`,
`AGENCY_STANDARDS_REF`, `AGENCY_STANDARDS_TTL_MIN`.

## Add a standard

Drop a markdown file under the right `standards/<stack>/` folder, add it to `INDEX.md`,
and (if it's a new stack/topic) wire detection in `fetch-standards.sh`. Keep each file
tight: a few rules + one bad/good example pair.

## Layers this is part of

- **This (prose, retrieved):** craft rules → shapes agent output.
- **Deterministic gate (separate):** pre-commit + linters + CI rulesets → forces compliance.
Both required. See `plans/2026-06-22-prd-code-quality-standards-system.md` in the ops workspace.
