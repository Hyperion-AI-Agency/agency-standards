# TypeScript — Types & Functions

## Explicit return types on exported functions
Signals intent and catches drift. (Inference is fine for locals/callbacks — don't annotate what's obvious.)
```ts
// YES
async function getActiveOrders(userId: string): Promise<Order[]> { ... }
// NO
async function getActiveOrders(userId: string) { ... }
```

## Annotate when the type isn't obvious from the right-hand side
```ts
const orders: Order[] = await orderService.getActive(userId);   // not obvious → annotate
const countByDate: Map<string, number> = new Map();             // annotate
const name = "Acme";                                            // obvious → don't
```
Do NOT annotate every `const` — that fights idiomatic inference and adds noise.

## Named interfaces for complex shapes — never inline
```ts
// YES
interface PriceSnapshot { vendor: string; price: number; at: Date; }
const snapshots: Map<string, PriceSnapshot> = new Map();
// NO
const snapshots: Map<string, { vendor: string; price: number; at: Date }> = new Map();
```

## Prefer `satisfies` for literal objects that must match a type
```ts
return { total: items.length, active: activeCount } satisfies OrderSummary;
```

## Errors
- Never expose internal errors to clients. Return a generic message + proper status; log the detail.
- Structured log prefixes per subsystem: `[ORDERS]`, `[AUTH]`.
