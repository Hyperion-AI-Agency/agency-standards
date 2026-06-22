# FastAPI / Backend Patterns

## Layering (keep concerns separate)
- **routes** — thin: parse/validate input, call a service, return a schema. No business logic.
- **service** — business logic. Deps declared as fields; use `@dataclass` so there's no hand-written constructor. Returns Pydantic models, never raw DB rows.
- **crud / repository** — DB access only. No business rules.

## Use `@dataclass` — no boilerplate
Don't hand-write `__init__`, getters, `__repr__`, or `__eq__`. Use `dataclasses` (or `pydantic` for validated boundary models). Plain holders/services → `@dataclass`.
```python
from dataclasses import dataclass, field

@dataclass
class OrderService:
    crud: OrderCRUD = field(default_factory=OrderCRUD)   # injectable, default for prod

    async def get_active(self, user_id: str) -> list[OrderResponse]:
        rows = await self.crud.find_active(user_id)
        return [OrderResponse.model_validate(row) for row in rows]
```
No getters/setters — access fields directly. Reach for a property only when access needs real logic.

## Dependency injection — prefer class-based
- **Default: class-based DI.** A callable class as the dependency — FastAPI resolves its `__init__` params (or `__call__`). Keeps related config/state together and is trivially testable.
```python
@dataclass
class Paginator:
    max_limit: int = 100
    def __call__(self, limit: int = 20, offset: int = 0) -> tuple[int, int]:
        return min(limit, self.max_limit), offset

paginate = Paginator(max_limit=200)

@router.get("/orders")
async def list_orders(page: Annotated[tuple[int, int], Depends(paginate)]): ...
```
- **Write a standalone dependency *function* only when it's genuinely needed** — a one-off with no state/config (e.g. `get_db`, `get_current_user`). Don't create a function-and-a-class for the same thing.
- Cross-cutting deps (db session, auth, rate limit) via `Annotated[T, Depends(...)]`. Chain sub-dependencies (`get_admin_user` depends on `get_current_user`).

## Rules
- **One router per domain** (`prefix`, `tags`). Don't mix domains in one file.
- **Pydantic validates every boundary** — separate `XCreate` (request) and `XResponse` (response) models; `model_config = {"from_attributes": True}` to read from ORM rows.
- **Settings** via `pydantic-settings` with an env prefix; validate at startup. Never `os.getenv` scattered around; never `load_dotenv()`.
- **Don't block the request handler** with side-effects — push background work to a task queue (Celery/RQ/etc). Workers continue on individual item errors, not full-batch failure.
- **Errors:** routes raise `HTTPException` with the right status; services raise domain exceptions; register global handlers. Never return 500 with internal detail.
- **Migrations** are explicit (Alembic autogenerate + review) — never auto-mutate schema at runtime.
