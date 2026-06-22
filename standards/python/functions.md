# Python — Types, Docstrings, Logging

## Type annotations
- Always annotate function/method signatures (params + return).
- Annotate variables when the type isn't obvious from the right side; skip when it is.
```python
async def get_active_orders(user_id: str) -> list[Order]: ...
orders: list[Order] = await service.get_active(user_id)   # not obvious → annotate
count = 0                                                 # obvious → don't
```

## Docstrings
Every module, class, and public function/method gets one. Private (`_`-prefixed) helpers may skip it when name + signature are self-explanatory.
- **Document the contract**, not the name: inputs → outputs, side effects, exceptions raised.
- Never restate the name. `"""Get user."""` on `get_user` is noise — write real content or omit (private only).
```python
def odds_to_index(price: Decimal) -> int:
    """Return the ladder index closest to `price`. Ties break toward the lower index."""
```

## Logging
- One logger per module: `logger = logging.getLogger(__name__)`.
- Log lifecycle (INFO), recoverable surprises (WARNING), failures the caller should notice (ERROR). Skip DEBUG spam.
- **Don't** log in pure helpers/hot paths, CRUD/schema parsing, or exceptions you're about to raise (the catch site logs).
- **Never** log secrets, tokens, or PII — log an id or hash, not the value.
- Structured over formatted: `logger.warning("verification failed", extra={"service": "x", "reason": r})`.
