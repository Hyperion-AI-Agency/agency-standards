# Naming

- Names reveal intent. A reader should understand a variable/function without reading its body.
- **Full names everywhere — including loops, comprehensions, lambdas, and short scopes.** No single letters (`i`, `x`, `a`, `e`). Write `account` not `a`, `index` not `i`, `error` not `e`. The only exception: a coordinate/math context where `x`/`y` ARE the domain meaning.
- Booleans read as predicates: `isActive`, `hasAccess`, `shouldRetry` — never `flag`, `status`, `check`.
- Functions are verb phrases (`fetchUser`, `calculateTotal`); values are noun phrases (`userCount`, `totalPrice`).
- No abbreviations except universally known ones (`id`, `url`, `db`). Not `usrCnt`, `calcTtl`.
- No type/encoding in names: `users` not `userArray`, `name` not `strName`.
- Avoid noise words: `data`, `info`, `manager`, `helper`, `util`, `value`, `object` carry no meaning. Name what it actually is.

## Bad
```py
def proc(d, f):           # proc what? d? f?
    res = []
    for x in d:           # single-letter loop var
        if x['flag']: res.append(x)
    return res
```

## Good
```py
def filter_active_accounts(accounts: list[Account]) -> list[Account]:
    return [account for account in accounts if account.is_active]
```
