# React Patterns

- **Server Components by default.** Add `"use client"` only for real interactivity (event handlers, state, effects).
- **No `useEffect` for data fetching.** Fetch in server components, or use a query lib (React Query / SWR) in client components. `useEffect`-fetch causes waterfalls and races.
- **Suspense for loading states**, not manual `isLoading` flags.
- **Parallel-fetch independent data** — start requests together, await once:
```tsx
const ordersP = getOrders();
const statsP = getStats();
const [orders, stats] = await Promise.all([ordersP, statsP]);
```
- Lift state only as far as needed. Don't put everything in global state.
- Keep components small and presentational where possible; push data/logic up or into hooks.
- Icons from a single icon set (e.g. `lucide-react`) — no ad-hoc inline SVGs.
