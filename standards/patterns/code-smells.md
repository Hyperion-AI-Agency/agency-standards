# Code Smells — Self-Detection

Check your own output against this. Each: **SIGN** (mechanical tell) · **FIX** (techniques from `refactoring.md`). Distilled from refactoring.guru; full page linked per smell. Detecting a smell is the trigger to refactor — no smell, no refactor.

## Bloaters
- **Long Method** [↗](https://refactoring.guru/smells/long-method) · SIGN: body more than ~10-40 lines, or you want a comment mid-body. · FIX: Extract Method; Replace Temp with Query; Decompose Conditional; Method Object (last resort).
- **Large Class** [↗](https://refactoring.guru/smells/large-class) · SIGN: many fields/methods + multiple responsibilities. · FIX: Extract Class / Subclass / Interface.
- **Primitive Obsession** [↗](https://refactoring.guru/smells/primitive-obsession) · SIGN: primitives for domain concepts (money, phone), int/string type-codes, string keys into arrays. · FIX: Replace Data Value with Object; Replace Type Code with Class/Subclasses/Strategy; Introduce Parameter Object.
- **Long Parameter List** [↗](https://refactoring.guru/smells/long-parameter-list) · SIGN: more than 3-4 params. · FIX: Introduce Parameter Object; Preserve Whole Object; Replace Parameter with Method Call.
- **Data Clumps** [↗](https://refactoring.guru/smells/data-clumps) · SIGN: same 3+ vars/params travel together; one alone is meaningless. · FIX: Extract Class; Introduce Parameter Object; Preserve Whole Object.

## Object-Orientation Abusers
- **Switch Statements** [↗](https://refactoring.guru/smells/switch-statements) · SIGN: switch/if-else on a type field; same switch duplicated. · FIX: Replace Conditional with Polymorphism; Replace Type Code with Subclasses/Strategy; Introduce Null Object.
- **Temporary Field** [↗](https://refactoring.guru/smells/temporary-field) · SIGN: field set/used only during one algorithm, empty otherwise. · FIX: Extract Class (method object); Introduce Null Object.
- **Refused Bequest** [↗](https://refactoring.guru/smells/refused-bequest) · SIGN: subclass uses few inherited members, overrides rest to throw. · FIX: Replace Inheritance with Delegation; Extract Superclass.
- **Alternative Classes w/ Different Interfaces** [↗](https://refactoring.guru/smells/alternative-classes-with-different-interfaces) · SIGN: two classes do the same thing, different method names. · FIX: Rename/Move Method, Parameterize Method; Extract Superclass; delete the dup.

## Change Preventers
- **Divergent Change** [↗](https://refactoring.guru/smells/divergent-change) · SIGN: one class edited for many unrelated reasons. · FIX: Extract Class (split responsibilities).
- **Shotgun Surgery** [↗](https://refactoring.guru/smells/shotgun-surgery) · SIGN: one logical change forces edits across many classes. · FIX: Move Method/Field to consolidate; Inline Class.
- **Parallel Inheritance Hierarchies** [↗](https://refactoring.guru/smells/parallel-inheritance-hierarchies) · SIGN: new subclass here always forces a matching subclass there. · FIX: reference one hierarchy from the other, then Move Method/Field to collapse.

## Dispensables
- **Comments** [↗](https://refactoring.guru/smells/comments) · SIGN: comments narrating what the next lines do. · FIX: Extract Variable; Extract Method + Rename. (Keep only genuine *why* — see `../general/comments.md`.)
- **Duplicate Code** [↗](https://refactoring.guru/smells/duplicate-code) · SIGN: two near-identical fragments. · FIX: Extract Method (same class); Pull Up / Form Template Method (siblings); Extract Superclass (different classes); Consolidate Conditional Fragments.
- **Data Class** [↗](https://refactoring.guru/smells/data-class) · SIGN: only fields + getters/setters, no behavior; others operate on its data. · FIX: Move Method (pull logic in); Encapsulate Field/Collection. (NOTE: a `@dataclass`/Pydantic DTO at a boundary is fine and intentional — this smell is about anemic *domain* objects whose behavior lives elsewhere.)
- **Dead Code** [↗](https://refactoring.guru/smells/dead-code) · SIGN: unused var/param/field/method/class or unreachable branch. · FIX: delete it; Remove Parameter; Inline Class.
- **Lazy Class** [↗](https://refactoring.guru/smells/lazy-class) · SIGN: class does too little to justify itself. · FIX: Inline Class; Collapse Hierarchy.
- **Speculative Generality** [↗](https://refactoring.guru/smells/speculative-generality) · SIGN: unused "just in case" abstraction/hook/param; only tests call it. · FIX: Collapse Hierarchy; Inline; Remove Parameter; delete. (This is the big AI smell — see `anti-bloat.md`.)

## Couplers
- **Feature Envy** [↗](https://refactoring.guru/smells/feature-envy) · SIGN: a method uses another object's data more than its own. · FIX: Move Method; Extract Method then move.
- **Inappropriate Intimacy** [↗](https://refactoring.guru/smells/inappropriate-intimacy) · SIGN: a class reaches into another's internals; two classes over-know each other. · FIX: Move Method/Field; Hide Delegate; make association unidirectional.
- **Incomplete Library Class** [↗](https://refactoring.guru/smells/incomplete-library-class) · SIGN: need a method on a 3rd-party class you can't edit. · FIX: Introduce Foreign Method (one); Introduce Local Extension (many).
- **Message Chains** [↗](https://refactoring.guru/smells/message-chains) · SIGN: `a.b().c().d()` navigation. · FIX: Hide Delegate; Extract+Move Method toward the chain head.
- **Middle Man** [↗](https://refactoring.guru/smells/middle-man) · SIGN: a class whose methods just delegate. · FIX: Remove Middle Man. (Keep if it's an intentional Proxy/Decorator.)

> Self-review loop: wrote code → scan for these signs → if one matches, apply the linked technique → re-scan. Stop when none match. Don't invent smells that aren't there.
