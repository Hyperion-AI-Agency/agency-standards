# Design Patterns — "Should I Use One?"

**Default to direct code. Use a pattern only when (1) you can NAME it, (2) the duplication/variation it removes is ALREADY present in the code or explicit requirements, and (3) the indirection it adds is less than the complexity it removes.** If any fails, ship the plain code. "We might need it later" is not a trigger — it's the #1 cause of over-engineering.

Each pattern adds classes, indirection, reading cost. Distilled from refactoring.guru; full page linked.

## Creational
- **Factory Method** [↗](https://refactoring.guru/design-patterns/factory-method) · 2+ concrete types and the choice must defer to subclasses/plugins. · NOT when types are fixed — just call the constructor. · Tell: "let users plug in their own type without editing existing code."
- **Abstract Factory** [↗](https://refactoring.guru/design-patterns/abstract-factory) · multiple *families* of related products that must stay consistent. · NOT for one family — Factory Method suffices. · Tell: "cross-platform / themes / matching product families."
- **Builder** [↗](https://refactoring.guru/design-patterns/builder) · telescoping constructor (many optional params) or several representations from the same steps. · NOT for a few fields — use named/optional args or a config object. · Tell: "step-by-step assembly with many optional parts."
- **Prototype** [↗](https://refactoring.guru/design-patterns/prototype) · clone objects whose concrete class is unknown. · NOT if you know the class or rarely copy. · Tell: "clone a preconfigured complex object without knowing its type."
- **Singleton** [↗](https://refactoring.guru/design-patterns/singleton) · genuinely exactly one shared instance (rare). · **Default NO** — global state breaks testing/mocking, hides coupling. Prefer dependency injection. · Tell: "the one shared X" → pass it as a dependency instead.

## Structural
- **Adapter** [↗](https://refactoring.guru/design-patterns/adapter) · make an unmodifiable library/legacy interface fit yours. · NOT if you can just change the source. · Tell: "integrate a third-party lib / make X work with Y."
- **Bridge** [↗](https://refactoring.guru/design-patterns/bridge) · two *orthogonal* axes of variation causing class explosion (Shape × Color). · NOT if the axes aren't truly independent. · Tell: "N platforms × M variants, adding one shouldn't touch the other."
- **Composite** [↗](https://refactoring.guru/design-patterns/composite) · data is genuinely a tree; one op runs over leaves + containers. · NOT if data isn't tree-shaped or leaf/container differ greatly. · Tell: "nested structures / recursive operation."
- **Decorator** [↗](https://refactoring.guru/design-patterns/decorator) · combine optional behaviors at runtime in varying combos. · NOT for one fixed extra behavior — subclass or inline. · Tell: "stack/combine optional features dynamically."
- **Facade** [↗](https://refactoring.guru/design-patterns/facade) · a small stable front door to a complex subsystem used in many places. · NOT if it grows into a god object hiding needed features. · Tell: "give the app a simple way to use this messy system."
- **Flyweight** [↗](https://refactoring.guru/design-patterns/flyweight) · *measured* RAM problem from millions of similar objects with shared immutable state. · NOT without a real memory bottleneck — premature optimization. · Tell: "millions of objects / running out of RAM."
- **Proxy** [↗](https://refactoring.guru/design-patterns/proxy) · transparent lazy-init/cache/access-control/logging around an object. · NOT if the service is cheap and always available. · Tell: "wrap access to an expensive/remote resource, same interface."

## Behavioral
- **Chain of Responsibility** [↗](https://refactoring.guru/design-patterns/chain-of-responsibility) · several handlers, set/order varies at runtime (middleware). · NOT for a fixed short sequence — just call the steps. · Tell: "check then forward / escalate / pluggable pipeline."
- **Command** [↗](https://refactoring.guru/design-patterns/command) · undo/redo, queue/schedule, or same action from many triggers. · NOT for a simple one-shot call. · Tell: "undo/redo / same action from several UI entry points."
- **Iterator** [↗](https://refactoring.guru/design-patterns/iterator) · traverse a complex structure many ways, hiding internals. · NOT for simple lists — use the language's built-in iteration. · Tell: "traverse a tree/graph multiple ways."
- **Mediator** [↗](https://refactoring.guru/design-patterns/mediator) · a messy web of many-to-many component comms. · NOT for a couple of interactions; risks a god object. · Tell: "many components react to each other and direct deps are a mess."
- **Memento** [↗](https://refactoring.guru/design-patterns/memento) · undo/rollback/snapshot without exposing internals. · NOT if copying public state works. · Tell: "restore previous state / snapshot."
- **Observer** [↗](https://refactoring.guru/design-patterns/observer) · one change must update an unknown/changing set of dependents (pub/sub). · NOT for one fixed listener — call it directly. · Tell: "notify/subscribe/publish," subscribers not known up front.
- **State** [↗](https://refactoring.guru/design-patterns/state) · many states with distinct behavior; big conditionals on a state field. · NOT for a few states — enum + switch is clearer. · Tell: "behaves differently by mode with many state branches."
- **Strategy** [↗](https://refactoring.guru/design-patterns/strategy) · interchangeable algorithms, swappable at runtime; large algo-selecting conditionals. · NOT for one or two stable algos — pass a function/lambda. · Tell: "swap algorithms at runtime (payment, sort, routing)."
- **Template Method** [↗](https://refactoring.guru/design-patterns/template-method) · several classes run a near-identical algorithm differing in a few steps. · NOT if steps vary a lot — use Strategy (composition over inheritance). · Tell: "similar procedures differing in a couple of steps."
- **Visitor** [↗](https://refactoring.guru/design-patterns/visitor) · repeatedly add new *operations* over a stable set of diverse types. · NOT if the type set changes (forces editing every visitor) — heavy. · Tell: "add operations across many types without changing them," types stable, operations growing.

> The three-gate test beats any single pattern. Most code needs zero patterns. When unsure, write the plain code and revisit when a *second concrete case* actually appears.
