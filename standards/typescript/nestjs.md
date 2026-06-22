# NestJS

Conventions for NestJS backends. Each rule links the canonical doc for spot-checking current API.

## Structure & file naming
- One concern per file, named `<name>.<role>.ts`. Roles: `*.module.ts`, `*.controller.ts`, `*.service.ts`, `*.repository.ts`, `*.entity.ts`, `*.dto.ts`, `*.spec.ts` (colocated).
- Each feature = its own directory with a single `*.module.ts` wiring its controllers + providers. Root `AppModule` imports feature modules. Entry point `main.ts`.
- Providers are NOT global by default — to reuse one elsewhere, `exports` it and `imports` the module. Export only what other modules need.
```
src/
  main.ts  app.module.ts
  orders/
    orders.module.ts  orders.controller.ts  orders.service.ts
    entities/order.entity.ts  dto/create-order.dto.ts
```
[docs](https://docs.nestjs.com/modules)

## Providers & DI
- Mark injectables `@Injectable()`, register in module `providers`, inject via constructor `private readonly`. Never `new` a service.
- Custom providers: `provide` (token) + `useValue`/`useClass`/`useExisting`/`useFactory` (with `inject` for factory deps).
- Async dynamic-module config = `forRootAsync` + `useFactory` + `inject`. App-wide: `forRoot`/`forRootAsync`; per-feature: `forFeature`/`forFeatureAsync`.
- Providers are singletons (`Scope.DEFAULT`). Use `Scope.REQUEST`/`TRANSIENT` only when genuinely needed — request scope bubbles up and costs performance.
[docs](https://docs.nestjs.com/providers) · [custom providers](https://docs.nestjs.com/fundamentals/custom-providers)

## Configuration
- `ConfigModule.forRoot({ isGlobal: true, validate })` — validate env on boot.
- Read via typed `ConfigService<EnvVars, true>` with `{ infer: true }`; the `true` generic marks env validated so `get` won't widen to `T | undefined`.
[docs](https://docs.nestjs.com/techniques/configuration#schema-validation)

## Database (TypeORM)
- Connection once: `TypeOrmModule.forRootAsync` (factory from ConfigService). Per feature: `TypeOrmModule.forFeature([Entity])`. Inject repos with `@InjectRepository`.
- `synchronize: false` always in prod — use migrations.
- Keep entities dumb; put non-trivial save/load orchestration in a `*.repository.ts` provider (Repository pattern).
[docs](https://docs.nestjs.com/techniques/database)

## DTOs & validation
- Request shapes are **classes** (not interfaces) in `*.dto.ts` so decorators survive at runtime. Annotate with `class-validator`.
- Global pipe: `app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }))`.
```ts
export class CreateOrderDto {
  @IsString() reference: string;
  @IsInt() @Min(0) quantity: number;
}
```
[docs](https://docs.nestjs.com/techniques/validation)

## Controllers
- `@Controller('prefix')` + method decorators (`@Get`/`@Post`/`@Patch`/`@Delete`). Extract inputs with `@Body()`, `@Param('id')`, `@Query()`. Return plain objects — Nest serializes to JSON. Streams: `@Sse()` returning `Observable<MessageEvent>`.
- Throw built-in HTTP exceptions (`NotFoundException`, `BadRequestException`) — never ad-hoc errors. `@Catch()` filters for cross-cutting error shaping.
[docs](https://docs.nestjs.com/controllers) · [exceptions](https://docs.nestjs.com/exception-filters)

## Queues (BullMQ)
- `@nestjs/bullmq`: `BullModule.forRoot` (Redis) + `BullModule.registerQueue({ name })`. Add jobs by injecting `Queue` with `@InjectQueue`. Process in a class `@Processor('queue')` extending `WorkerHost`.
[docs](https://docs.nestjs.com/techniques/queues)

## Style
- One provider/controller per file (matches `nest g` + colocated `*.spec.ts`).
- `async/await` over raw promise chains.
- Domain errors → custom `HttpException` subclasses.
- Barrel `index.ts` optional; keep shallow to avoid circular deps.
- Run ESLint + Prettier in CI; don't fight Prettier.
