# Comments

Comments are a last resort, not a goal. Clean Code: "The proper use of comments is to compensate for our failure to express ourselves in code." Every comment is a small failure of naming or structure — try to fix the code first.

- Explain **why**, never **what**. The code says what; a comment justifies a non-obvious decision, trade-off, or workaround.
- Delete commented-out code. Git is the history.
- No redundant comments (`i++ // increment i`), no changelog comments, no attribution comments (`// added by X`).
- Keep TODOs actionable and rare; prefer a tracked issue. A stale TODO is noise.
- Public API docstrings are fine and encouraged (they're contracts, not what-comments): document params, returns, raises, and surprising behavior.

## Bad
```python
# check if the user is an adult
if user.age >= 18:  # 18 is the age
    ...
```

## Good
```python
LEGAL_ADULT_AGE = 18
if user.age >= LEGAL_ADULT_AGE:
    ...

# Stripe rounds half-up; we mirror it here so totals reconcile with their dashboard.
total = round_half_up(subtotal)
```
