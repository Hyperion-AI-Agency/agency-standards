# Error Handling

- Prefer exceptions/Result types over error codes. Don't return `null`/`-1` to signal failure where the language has a better mechanism.
- Catch narrow, not broad. Never swallow a generic exception and continue silently.
- Fail fast at boundaries: validate inputs where they enter the system (API edge, function entry), then trust them inward.
- Error messages state what failed and the context needed to act ("user 42 has no active subscription"), not just "error".
- Don't use exceptions for normal control flow.
- Clean up resources deterministically (context managers / `defer` / `finally` / RAII), not by hand.
- Never leak secrets, tokens, or PII into logs or error responses.

## Bad
```ts
try {
  return JSON.parse(input);
} catch (e) {
  return {};               // swallows everything, hides the real bug
}
```

## Good
```ts
try {
  return JSON.parse(input);
} catch (e) {
  throw new InvalidPayloadError(`malformed JSON from ${source}`, { cause: e });
}
```
