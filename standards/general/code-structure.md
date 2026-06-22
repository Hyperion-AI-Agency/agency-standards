# Code Structure & Design

Cross-language design rules drawn from Clean Code (Robert C. Martin) and Google's engineering practices.

## DRY, but not WET-phobic
- Don't repeat knowledge. Extract a shared function when the SAME logic appears 3+ times.
- But duplication is cheaper than the wrong abstraction. Don't unify two things that merely look alike today — wait until the pattern is real.

## SOLID (apply with judgment, not dogma)
- **S** — Single Responsibility: a module/class/function has one reason to change.
- **O** — Open/Closed: extend behavior without editing stable code (where it pays off).
- **L** — Liskov: subtypes must be substitutable for their base.
- **I** — Interface Segregation: many small interfaces over one fat one.
- **D** — Dependency Inversion: depend on abstractions; inject dependencies, don't hardcode them.

## Other durable rules
- **Boy Scout Rule:** leave code cleaner than you found it. Small opportunistic cleanups, not drive-by rewrites.
- **Law of Demeter:** a unit talks to its direct collaborators only. Avoid `a.getB().getC().doThing()` train-wrecks.
- **No magic values:** name every literal that isn't self-evidently 0/1/"". `MAX_RETRIES = 3`.
- **Keep related code close:** colocate things that change together; don't scatter one feature across ten files.
- **Composition over inheritance** by default.

## Small changes (Google eng-practices)
- Make **small, self-contained commits/PRs** — one logical change each. Easier to review, less likely to hide bugs, faster to merge.
- A PR that "does one thing" is the unit of work. If you can split it, split it.
- The bar for any change: it **measurably improves overall code health**, even if not perfect.

## Bad
```ts
class OrderManager {
  // 600 lines: validation + pricing + persistence + email + pdf + analytics
}
```

## Good
```ts
// each with one reason to change, composed by a thin orchestrator
validateOrder(order);
const priced = priceOrder(order);
persist(priced);
queueReceipt(priced);   // email/pdf handled downstream, decoupled
```
