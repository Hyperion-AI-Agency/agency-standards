# Anti-Bloat

The most common AI-codegen failure: too much code. Fight it.

- Don't add error handling, logging, config options, or abstractions that weren't asked for. Solve the actual task.
- No premature layering: no repository/service/factory wrapper around a 3-line DB call.
- Prefer standard library + the framework's built-ins over new dependencies or hand-rolled utilities.
- Don't reimplement what the language/framework gives you (no custom `groupBy` if the stdlib has one).
- One way to do a thing in a codebase. Don't introduce a second pattern for something already solved.
- If a file crosses ~300 lines or a function ~40, stop and ask whether it should be split — don't auto-generate giant files.
- Delete more than you add when refactoring. Net-negative diffs are good diffs.

## No backward compatibility unless asked
- **Do NOT write backward-compat shims, fallbacks, deprecation layers, version checks, or "old + new" dual code paths by default.** When changing something, change it — update all callers, delete the old path.
- No keeping a deprecated function "just in case." No `_v2` alongside `_v1`. No optional params that only exist to not break old callers.
- No "legacy" branches, no compatibility aliases, no shimming removed APIs.
- This is internal/agency code under our control — we refactor freely. Only add compatibility when the user explicitly asks (e.g. a published library/public API with external consumers).

## Smell checklist (reject your own output if any are true)
- Helper functions used exactly once that don't aid readability → inline them.
- Wrapper classes that only forward calls → delete the wrapper.
- `try/except` that catches everything and re-raises or logs-and-continues → handle the specific error or let it propagate.
- Config flags with only one caller passing the default → remove the flag.
- Comments restating the code → delete.
