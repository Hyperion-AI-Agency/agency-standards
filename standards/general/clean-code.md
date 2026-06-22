# Clean Code

- Write the simplest thing that works. Cleverness is a cost, not a feature.
- Match the surrounding code's style, naming, and structure. Consistency beats personal preference.
- Delete dead code, commented-out blocks, and unused imports/vars. Don't leave them "just in case" — git remembers.
- No speculative generality. Don't build abstractions for cases that don't exist yet (YAGNI).
- Comments explain *why*, never *what*. If the code needs a comment to explain what it does, rewrite the code.
- Fail loud and early. Validate inputs at boundaries; don't swallow errors silently.
- One level of abstraction per function. Don't mix high-level orchestration with low-level detail in the same block.

## Bad
```ts
// loop through users and check if active and send email if active
function p(u: any[]) {
  for (let i = 0; i < u.length; i++) {
    if (u[i].a === true) { /* TODO maybe batch later */ sendEmail(u[i]); }
  }
}
```

## Good
```ts
function notifyActiveUsers(users: User[]): void {
  users.filter(isActive).forEach(sendWelcomeEmail);
}
```
