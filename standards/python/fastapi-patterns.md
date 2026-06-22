# FastAPI / Backend Patterns

## Layering (keep concerns separate)
- **routes** — thin: parse/validate input, call a service, return a schema. No business logic.
- **service** — business logic. Takes deps via constructor (optional, for test injection). Returns Pydantic models, never raw DB rows.
- **crud / repository** — DB access only. No business rules.
```python
class OrderService:
    def __init__(self, crud: OrderCRUD | None = None):
        self.crud = crud or OrderCRUD()
    async def get_active(self, user_id: str) -> list[OrderResponse]:
        rows = await self.crud.find_active(user_id)
        return [OrderResponse.model_validate(r) for r in rows]
```

## Rules
- **One router per domain** (`prefix`, `tags`). Don't mix domains in one file.
- **Pydantic validates every boundary** — separate `XCreate` (request) and `XResponse` (response) models; `model_config = {"from_attributes": True}` to read from ORM rows.
- **Dependency injection** for cross-cutting concerns (db session, auth, rate limit) via `Annotated[T, Depends(...)]`. Chain sub-dependencies (`get_admin_user` depends on `get_current_user`).
- **Settings** via `pydantic-settings` with an env prefix; validate at startup. Never `os.getenv` scattered around; never `load_dotenv()`.
- **Don't block the request handler** with side-effects — push background work to a task queue (Celery/RQ/etc). Workers continue on individual item errors, not full-batch failure.
- **Errors:** routes raise `HTTPException` with the right status; services raise domain exceptions; register global handlers. Never return 500 with internal detail.
- **Migrations** are explicit (Alembic autogenerate + review) — never auto-mutate schema at runtime.
