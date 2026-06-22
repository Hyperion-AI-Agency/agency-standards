# Abstractions — Name It Before You Add It

The cheapest way to stop AI over-engineering: require a *name* for every abstraction before introducing it.

- **Before adding a design pattern**, name it (Factory, Strategy, Observer, Adapter, Template Method). If you can't name a real pattern that fits, you probably don't need the abstraction — write the direct code.
- **Before refactoring**, name the smell first (Long Method, Feature Envy, Primitive Obsession, Switch-on-type). Then apply the matching technique (Extract Method, Move Method, Replace-with-Object, Polymorphism). No named smell → don't refactor.
- Reference for both: refactoring.guru (design-patterns, refactoring/smells).
- Default to the simplest direct code. Patterns earn their place by removing real, present duplication or variation — not anticipated future variation.

## Folder roles (when a project separates them)
- **lib/** — reusable, well-structured building blocks (clients, SDKs, integrations).
- **utils/** — small, stateless, generic helpers (formatting, parsing, dates).
- **services/** — business logic and external integrations, one folder per domain.

Quick test: mini-package → `lib/`; generic helper → `utils/`; business logic/integration → `services/`.
