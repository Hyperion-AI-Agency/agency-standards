# TypeScript — Naming & Files

## File naming
| Kind | Convention | Example |
|------|------------|---------|
| Component | PascalCase | `UserCard.tsx` |
| Hook | kebab-case file, camelCase export | `use-cart.ts` → `useCart` |
| Schema | kebab-case | `order.schema.ts` |
| Service | kebab-case | `payment.service.ts` |
| Test | kebab-case mirror | `payment.service.test.ts` |
| Constants | kebab-case | `order-status.ts` |

## Other
- Components/Types: PascalCase. Functions/variables: camelCase. Constants: UPPER_CASE.
- Full words, no abbreviations: `event` not `evt`, `calculateTotal()` not `calcTtl()`, `service` not `svc`.
- One primary export per file (one component, hook, schema, or service). Co-locate only tightly-coupled helpers.
