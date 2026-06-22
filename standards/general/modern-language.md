# Use Modern Language Features

Write idiomatic modern code for the language version in use. Old-style constructs read as dated and are usually more error-prone. Prefer the expressive built-in over the manual loop.

## General
- **Iterate with higher-order methods**, not index-counting loops. `map`/`filter`/`reduce`/`forEach` (JS/TS), comprehensions (Python). Reach for a raw `for (let i=0; ...)` only when you genuinely need the index or early-exit performance.
- **Use the right data structure:** a **Set** for membership/uniqueness (not an array + `includes`), a **Map/dict** for keyed lookup (not parallel arrays or object-as-map when keys aren't strings).
- Prefer immutable transforms over mutating in place where it's clear.
- Use destructuring, spread/rest, and optional chaining / null-coalescing instead of manual checks.
- Use `async/await` over raw promise/callback chains.

## TypeScript / JS
```ts
// NO — dated, manual, mutation
const ids = [];
for (let i = 0; i < users.length; i++) { if (users[i].active) ids.push(users[i].id); }
const seen = {}; for (const id of ids) seen[id] = true;

// YES — modern, expressive
const ids = users.filter(user => user.active).map(user => user.id);
const seen = new Set(ids);
```
- `Set`/`Map` over object-as-dictionary; `Array.from`, `Object.entries/values`, `at(-1)`, `??`, `?.`, template literals.
- `const`/`let` only (never `var`).

## Python
```python
# NO
result = []
for user in users:
    if user.active:
        result.append(user.id)

# YES
result = [user.id for user in users if user.active]
seen = set(result)                       # set for membership
by_id = {user.id: user for user in users}  # dict for lookup
```
- Comprehensions, `set`/`dict`, `enumerate`/`zip` (never `range(len(...))`), f-strings, `pathlib` over `os.path`, dataclasses (see `functions.md`), `match` where it reads clearer than an if-chain.

## Caveat
Modern ≠ clever. Don't chain ten `.reduce()`s into something unreadable — clarity still wins. Use the modern feature when it's *clearer*, which is almost always.
