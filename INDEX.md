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
- `patterns/abstractions.md` — name-it-before-you-add-it; folder roles (lib/utils/services)

## typescript (loaded if package.json present)
- `typescript/naming.md` — file naming, full words, one export/file
- `typescript/functions.md` — explicit return types, named interfaces, satisfies, annotate-when-unclear
- `typescript/react-patterns.md` (if react dep) — server components, no useEffect-fetch, Suspense, parallel fetch
- `typescript/nextjs.md` (if next dep) — route groups, server actions, env validation

## python (loaded if pyproject.toml / requirements.txt / *.py)
- `python/naming.md` — snake_case/PascalCase, full words
- `python/functions.md` — type annotations, docstrings (contract not name), logging discipline
- `python/fastapi-patterns.md` (if fastapi dep) — routes/service/crud layering, Pydantic boundaries, DI, no-block-handler

## terraform (loaded if *.tf / terraform/)
- `terraform/structure.md`
- `terraform/naming.md`

> Framework *correctness* (current API/syntax) is NOT maintained here — it goes stale.
> Use a live-docs MCP (Context7-style) for that. This repo = durable craft rules only.
