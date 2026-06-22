# Comments

**Keep comments VERY light. Default to none.** AI massively over-comments — narrating every line, restating the obvious, adding section banners. Don't. A comment is a last resort, used only when the code genuinely cannot express the *why*.

The bar before writing a comment: "would a competent developer be confused without this?" If no → delete it.

- **Default: write zero comments.** Let names and structure carry the meaning. Only comment a genuinely non-obvious *why* (a workaround, a surprising trade-off, a spec/external quirk).
- Explain **why**, never **what**. Never narrate what the code does — the reader can see it.
- **No** redundant comments (`i++ // increment`), section banners (`# ---- helpers ----`), restating-the-name comments, changelog/attribution comments (`// added by X`), or "what changed" notes.
- Delete commented-out code. Git is the history.
- TODOs: rare and actionable, or a tracked issue. No vague `# TODO: improve`.
- Docstrings on PUBLIC API only (contracts: inputs→outputs, raises, surprising behavior). Private/internal: skip unless the name truly can't carry it. Don't docstring obvious one-liners.

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
