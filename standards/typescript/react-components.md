# React Components (2026)

Decision-oriented. Pick the lowest-complexity tool that draws the boundary cleanly; let the compiler handle micro-optimization.

## 2026 baseline (invalidates older advice)
- **React Compiler is stable (v1.0).** It auto-memoizes at build time. `useMemo`/`useCallback`/`React.memo` are **escape hatches, not defaults** — don't write them by default with the compiler on.
- **Server Components are the default** in App Router setups; a component is server unless it opts out with `"use client"`.
- **Server state ≠ client state.** Server data → TanStack Query (or RSC fetch). Leftover UI state → `useState`/Zustand. Don't treat cached API responses as "global state."

## What "scale-grade" means
One reason to exist · honest prop APIs (describe *what*, not `isSpecialModeV2` flags) · composition over configuration · state at the right altitude · predictable (same props/state → same output, no side effects in render) · replaceable. The real skill = **boundary-drawing**.

## Server/client boundary (first cut)
- **Default to Server Components** — data fetching, content, non-interactive, heavy deps (markdown/date/syntax libs) you don't want in the bundle. They can `await` data directly; ship 0 KB.
- **Push `"use client"` to the leaves.** It marks a boundary — everything imported below becomes client code. Isolate the interactive island; keep the rest server.
- **Can't import a Server Component into a Client Component — but can pass one as `children`/prop.** The client component decides *where* already-rendered server output goes, it doesn't render it.
- **Fetch in parallel** (`Promise.all` / independent `<Suspense>`); don't recreate request waterfalls on the server. Wrap independent slow sections in their own Suspense + skeleton so the shell streams immediately.
- Plain Vite SPA (no RSC): everything is client; fetch with TanStack Query. The rest of this file still applies.

## Splitting components — split when:
more than one reason to change · JSX repeats with small variations · lots of state, only some used by some markup · a prop tunnels through 3+ layers untouched · the name needs "and" · a `useEffect` syncs two pieces of state (→ usually derived state, compute in render).
**Don't over-split:** single-use markup with no independent reason to change stays inline. Rule of three — tolerate duplication twice, abstract on the third when the variation is understood.
Modern container/presentational = Server Component fetches (container), Client Component is the interactive leaf. SPA equivalent: **logic in a custom hook, markup in the component** — don't make a wrapper component just to fetch.

## Reuse ladder (lowest rung that works)
1. **Props (90%)** — model the domain not UI states (`variant: "primary"|"danger"`, make illegal states unrepresentable); spread `...rest` to the underlying element; accept `children` aggressively.
2. **Custom hooks** — the key pattern for sharing *stateful logic* (debounce, subscriptions, fetching). Most "HOC or render prop?" questions answer to "make it a hook."
3. **Compound components** — coordinated UI families (tabs, accordion, select) sharing state via context; consumer composes structure, no prop drilling. How Radix/Headless UI work.
4. **Headless / polymorphic** — design-system territory only (behavior + a11y, no styling; `as` prop). TS gets hairy — only for true libraries.
Legacy: **HOCs** → replaced by hooks (except error boundaries, which must be class components); **render props** → usually a hook is cleaner. Don't add in new code unless you hit their specific case.

## State — decision tree
First question: **server state or client state?** (getting this wrong is the #1 mistake)
- **Server state** (from API/DB, goes stale, needs cache/refetch) → **TanStack Query, always.** Never `useState`+`useEffect`, never Redux. (In RSC, much is handled by fetching in Server Components; Query covers client fetch, mutations, infinite scroll, refetch-on-interaction.)
- **Client state** → climb lowest-first:

| Need | Tool |
|---|---|
| One component | `useState` |
| Several values update together / complex transitions | `useReducer` |
| Shared by a few neighbors | Lift to common parent |
| Survive refresh / shareable / bookmarkable (filters, tabs, pagination) | **URL** — `useSearchParams` / `nuqs` |
| App-wide, rarely changes (theme, locale, auth, flags) | `useContext` |
| App-wide, changes often | **Zustand** |
| Lots of fine-grained derived state | **Jotai** |
| 50+ engineers, enforced conventions | Redux Toolkit |

Two traps: (1) **Context for hot state** — every consumer re-renders on every change (no selectors); fine for theme/auth, a perf bug for frequent updates → use Zustand/Jotai. (2) **Reaching for a global store too early** — most apps ship on `useState` + TanStack Query + URL state, no client-state lib. Add Zustand when prop-drilling genuinely-global UI state hurts.
Boring default stack: TanStack Query + Zustand + nuqs + React Hook Form + Zod.

## Loading/error: Suspense boundaries vs inline status — split by intent
The query lives in the component either way (`useSuspenseQuery` co-locates too) — what moves to a boundary is only fallback rendering, not data ownership. Choose by intent:
- **Initial reads → `useSuspenseQuery` + Suspense/error boundaries.** `data` is typed non-undefined (no `T | undefined` everywhere), errors throw to the nearest error boundary, loading/error branches deleted from every component. Control reveal granularity by boundary placement: one boundary around three components → they appear together; three boundaries → independent. Composes with Next streaming + `loading.tsx`.
- **Mutations, background refetch, stale-while-revalidate → inline status flags** (`isFetching`, mutation `isPending`). Suspense only fires on the *first* load (no data yet); it cannot express refetch/mutation states — those MUST be inline. Not optional.
- Default: Suspense for reads, manual flags for mutations + refetch indicators. Staying fully in-component is also legitimate (most Query apps do) — just watch the two footguns below.
- **Popcorn vs coordinated loading:** per-component branches = each widget pops in independently (often janky — layout shift, spinners out of sync). Suspense lets you group reveal declaratively.
- **Early-return waterfall (footgun, both patterns):** a parent that `if (isPending) return <Skeleton/>` before rendering children delays children's *independent* queries until the parent resolves — silently serializes parallel requests. Fix: hoist queries to the same level, prefetch in the parent, or `useQueries`/`useSuspenseQueries` for parallel fetches.

## Hooks guide
- **`useState` vs `useReducer`** — reducer when 3+ related values change together, next-depends-on-prev, or you want centralized testable transitions (reducer = pure fn, trivially unit-tested).
- **`useRef`** — mutable box, persists across renders, no re-render on change. Three jobs: (1) DOM access/3rd-party lib integration, (2) hold non-render value (timer id, prev value, "ran once" flag), (3) escape stale closures. Decision: UI must update on change? → `useState`. No (behind-the-scenes/DOM handle)? → `useRef`.
- **`useMemo`/`useCallback`** — **with the compiler on (recommended), don't write by default.** Escape hatches only: a value feeding a `useEffect` dep array that must be referentially stable; a genuinely expensive computation the compiler isn't caching; library/uncompiled code; 3rd-party `===` reference checks. **Migrating:** turn the compiler on but DON'T mass-delete existing ones (can change output / cause effects to over-fire) — verify per-usage with the lint plugin. Compiler does NOT fix: expensive work whose inputs change every render, waterfalls, Rules-of-React violations.
- **`useEffect`** — strong bias against. NOT for: derived state (compute in render), responding to an event (put it in the handler), fetching (TanStack Query / Server Component), transforming data for render. It's ONLY for **synchronizing with systems outside React** (subscriptions, event listeners, manually-controlled DOM/widgets, analytics, timers). Always return cleanup for subscriptions/timers.
- **`useTransition` / `useDeferredValue`** — keep UI responsive during a heavy subtree update (tab switch, typeahead). Only when you have an actual responsiveness problem.
- **Smaller:** `useId` (a11y IDs stable server↔client — don't hand-roll), `useLayoutEffect` (measure-then-mutate before paint only; blocks paint), `useImperativeHandle` (rare imperative API like `.focus()`; React 19 takes `ref` as a normal prop so `forwardRef` is mostly gone), `use` (read promise/context, Suspense — mostly via frameworks).

## Performance — in priority order
1. **Render less on the client** — the server/client boundary is the biggest lever; 0 KB shipped can't be slow.
2. **Fix data waterfalls** — sequential/dependent awaits dominate perceived load far more than render cost. Parallelize + Suspense.
3. **Enable the React Compiler** — kills the "re-render from unstable references" category automatically.
4. **Then profile** — React DevTools Profiler, optimize the *measured* hotspot. Adding `useCallback` "to be safe" without profiling usually does nothing.
5. **Virtualize long lists** (`@tanstack/react-virtual`).
6. **Stable `key`s** — real IDs, never array index for dynamic lists (index keys cause state-association bugs on reorder, not just perf).
Compiler on ≠ performance solved — it removes reference churn only.

## Closing principle
Patterns are means, not ends. The skill is drawing boundaries — server/client, one responsibility/next, behavior/markup, kinds of state. Lowest-complexity tool that draws it cleanly; add sophistication only when you feel the specific pain it solves.
