# Functions

- Small. A function should do one thing. If you can extract a meaningfully-named sub-function, it was doing two.
- Few arguments. 0-2 ideal, 3 is a smell, 4+ means group them into an object/struct.
- No boolean flag arguments that switch behavior — split into two functions instead.
- No side effects hidden behind an innocent name. `getUser` must not also write to the DB.
- Return early. Guard clauses over nested `if/else` pyramids.
- Keep nesting shallow (max ~2-3 levels). Deep nesting = extract a function.
- Pure where possible: same input → same output, no I/O. Push I/O to the edges.

## Bad
```ts
function save(user, validate, sendEmail, isAdmin) {
  if (user) {
    if (validate) {
      if (user.email) {
        // ... 30 lines mixing validation, persistence, email
      }
    }
  }
}
```

## Good
```ts
function saveUser(user: User): void {
  assertValid(user);
  persist(user);
}
// caller decides about email/admin separately — no flag args
```
