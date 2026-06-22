# Next.js (App Router)

- **Server Components by default**; `"use client"` only when needed (see react-patterns).
- **Route groups** `(group)/` organize without affecting URLs. **Private folders** `_components/` are excluded from routing.
- **Server Actions** (`"use server"`) for mutations; call `revalidatePath`/`revalidateTag` after writes.
- **Streaming:** wrap slow sections in `<Suspense>` so the shell renders immediately.
- **Env vars:** validate at build/startup (e.g. `@t3-oss/env-nextjs`). `NEXT_PUBLIC_` only for values safe in the browser; server-only vars never reach the client.
- Use the framework's data/caching primitives — don't hand-roll fetch caching.
- Track the current major's API (it moves fast). For exact current syntax, consult live docs, not memory.
