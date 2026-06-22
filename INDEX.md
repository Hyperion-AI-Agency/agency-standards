# Standards Index

Topic files under `standards/`. The SessionStart hook auto-loads the ones matching a repo's stack.

## general (always loaded — language-agnostic, Clean Code + Google eng-practices)
- `general/clean-code.md` — simplicity, consistency, dead code
- `general/naming.md` — intent-revealing names, conventions
- `general/functions.md` — small, few args, no flag args, early return
- `general/comments.md` — why-not-what, comments as last resort
- `general/error-handling.md` — narrow catches, fail-fast, no swallowing
- `general/code-structure.md` — DRY, SOLID, Law of Demeter, small PRs, code health
- `patterns/anti-bloat.md` — fight AI over-generation; smell checklist

## typescript (loaded if package.json present)
- `typescript/naming.md`
- `typescript/functions.md`
- `typescript/react-patterns.md` (if react dep)
- `typescript/nextjs.md` (if next dep)

## python (loaded if pyproject.toml / requirements.txt / *.py)
- `python/naming.md`
- `python/functions.md`
- `python/fastapi-patterns.md` (if fastapi dep)

## terraform (loaded if *.tf / terraform/)
- `terraform/structure.md`
- `terraform/naming.md`

> Framework *correctness* (current API/syntax) is NOT maintained here — it goes stale.
> Use a live-docs MCP (Context7-style) for that. This repo = durable craft rules only.
