# Naming

- Names reveal intent. A reader should understand a variable/function without reading its body.
- Length scales with scope: short names for tight loops (`i`, `x`), full descriptive names for module-level things.
- Booleans read as predicates: `isActive`, `hasAccess`, `shouldRetry` — never `flag`, `status`, `check`.
- Functions are verb phrases (`fetchUser`, `calculateTotal`); values are noun phrases (`userCount`, `totalPrice`).
- No abbreviations except universally known ones (`id`, `url`, `db`). Not `usrCnt`, `calcTtl`.
- No type/encoding in names: `users` not `userArray`, `name` not `strName`.
- Avoid noise words: `data`, `info`, `manager`, `helper`, `util`, `value`, `object` carry no meaning. Name what it actually is.

## Bad
```py
def proc(d, f):           # proc what? d? f?
    res = []
    for x in d:
        if x['flag']: res.append(x)
    return res
```

## Good
```py
def filter_active_accounts(accounts: list[Account]) -> list[Account]:
    return [a for a in accounts if a.is_active]
```
