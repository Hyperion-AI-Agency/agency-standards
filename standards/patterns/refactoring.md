# Refactoring Techniques

Problem → technique lookup. Each: **Technique** — what it does · **WHEN** the trigger. Distilled from refactoring.guru; full write-up per group is linked. Default: reach for the smallest technique that removes the present problem — don't refactor speculatively.

## When to refactor (gate)
- Refactor when you can **name a code smell** (see `code-smells.md`). No named smell → leave it.
- Refactor in **small steps**, behavior-preserving, tests green between steps.
- Refactor the code you're already touching (Boy Scout) — not a drive-by rewrite of unrelated code.
- Do NOT refactor for hypothetical future needs (that's Speculative Generality).

## Composing Methods
[ref](https://refactoring.guru/refactoring/techniques/composing-methods)
- **Extract Method** — fragment → new named method. · WHEN: a method is too long, or a fragment groups together.
- **Inline Method** — replace calls with the body, delete the method. · WHEN: the body is as clear as the name; indirection adds nothing.
- **Extract Variable** — name a sub-expression. · WHEN: an expression is hard to read.
- **Inline Temp** — replace a temp with its expression. · WHEN: a temp holds a simple expression and gets in the way.
- **Replace Temp with Query** — move expression into a method, call it. · WHEN: a temp's result is reused and blocks Extract Method.
- **Split Temporary Variable** — one variable per distinct value. · WHEN: a temp is reused for unrelated intermediate values.
- **Remove Assignments to Parameters** — use a local instead. · WHEN: a parameter is reassigned in the body.
- **Replace Method with Method Object** — method → its own class, locals become fields. · WHEN: long method's locals are too tangled to Extract Method.
- **Substitute Algorithm** — swap in a clearer algorithm. · WHEN: existing logic can be replaced by a simpler equivalent.

## Moving Features Between Objects
[ref](https://refactoring.guru/refactoring/techniques/moving-features-between-objects)
- **Move Method** — relocate to the class that uses it most. · WHEN: Feature Envy — used more elsewhere.
- **Move Field** — relocate field to the class that uses it most. · WHEN: a field is used more in another class.
- **Extract Class** — split related fields/methods into a new class. · WHEN: one class does the work of two.
- **Inline Class** — merge a near-empty class into another. · WHEN: a class does almost nothing.
- **Hide Delegate** — server exposes a method so clients don't reach through. · WHEN: client calls `a.getB().doX()` (message chain).
- **Remove Middle Man** — client calls the delegate directly. · WHEN: a class is mostly pass-through methods.
- **Introduce Foreign Method** — add the missing method in the client, pass the util as arg. · WHEN: a util class lacks one method you can't add.
- **Introduce Local Extension** — wrap/subclass the util to add methods. · WHEN: a util class lacks several methods you can't add.

## Organizing Data
[ref](https://refactoring.guru/refactoring/techniques/organizing-data)
- **Replace Magic Number with Symbolic Constant** — literal → named constant. · WHEN: a number with special meaning appears.
- **Encapsulate Field** — public field → private + accessors. · WHEN: a field is public.
- **Encapsulate Collection** — return read-only view; add/remove via methods. · WHEN: a class exposes a collection via plain getter/setter.
- **Replace Data Value with Object** — field → its own class. · WHEN: a field has its own behavior + data.
- **Replace Type Code with Class** — type-code value → class instance. · WHEN: type codes hurt type safety but don't drive behavior.
- **Replace Type Code with Subclasses** — subclass per type-code. · WHEN: an immutable type code directly drives behavior.
- **Replace Type Code with State/Strategy** — type code → state/strategy object. · WHEN: type code drives behavior but changes at runtime / subclassing blocked.
- **Replace Array with Object** — positional array → named fields. · WHEN: an array holds mixed types by position.
- **Replace Subclass with Fields** — collapse subclasses into fields. · WHEN: subclasses differ only in constant-returning methods.
- **Self Encapsulate Field** — access own field via getter/setter. · WHEN: direct field access needs override/lazy logic.
- **Change Value to Reference / Reference to Value** — share one instance / make immutable value. · WHEN: identical instances should be shared / a small reference object isn't worth lifecycle management.

## Simplifying Conditional Expressions
[ref](https://refactoring.guru/refactoring/techniques/simplifying-conditional-expressions)
- **Decompose Conditional** — extract condition + branches into named methods. · WHEN: a complex if/switch is hard to read.
- **Consolidate Conditional Expression** — combine checks with the same result. · WHEN: multiple conditions lead to the same action.
- **Consolidate Duplicate Conditional Fragments** — hoist code common to all branches out. · WHEN: identical code in every branch.
- **Replace Nested Conditional with Guard Clauses** — early-exit guards, flatten nesting. · WHEN: nesting hides the normal path.
- **Remove Control Flag** — use break/continue/return. · WHEN: a boolean flag governs loop flow.
- **Replace Conditional with Polymorphism** — each branch → overridden method. · WHEN: a conditional dispatches on type.
- **Introduce Null Object** — return a default-behavior object. · WHEN: null checks are scattered everywhere.
- **Introduce Assertion** — make an assumed condition explicit. · WHEN: code only works if an unstated condition holds.

## Simplifying Method Calls
[ref](https://refactoring.guru/refactoring/techniques/simplifying-method-calls)
- **Rename Method** — clearer name. · WHEN: the name doesn't explain the method.
- **Add / Remove Parameter** — supply missing data / drop unused. · WHEN: method lacks needed data / has an unused param.
- **Separate Query from Modifier** — split returns-value from changes-state. · WHEN: a method both returns and mutates.
- **Parameterize Method** — merge near-identical methods via a parameter. · WHEN: several methods differ only by an internal value.
- **Replace Parameter with Explicit Methods** — one method per fixed param value. · WHEN: a method branches on a small fixed set of param values.
- **Preserve Whole Object** — pass the object, not extracted values. · WHEN: you pull several values off one object and pass them separately.
- **Replace Parameter with Method Call** — drop a param the method can compute. · WHEN: a passed value is derivable inside the method.
- **Introduce Parameter Object** — group a recurring param set into an object. · WHEN: the same param group recurs (Data Clump).
- **Remove Setting Method** — delete a setter for a set-once field. · WHEN: a field must not change after creation.
- **Hide Method** — reduce visibility. · WHEN: a method isn't used outside its class.
- **Replace Constructor with Factory Method** — factory instead of constructor. · WHEN: construction does more than set fields (e.g. type selection).
- **Replace Error Code with Exception** — throw instead of returning a sentinel. · WHEN: a method returns a special error value.
- **Replace Exception with Test** — pre-check instead of catch. · WHEN: a simple test could prevent the exception.

## Dealing with Generalization
[ref](https://refactoring.guru/refactoring/techniques/dealing-with-generalization)
- **Pull Up Field / Method / Constructor Body** — move shared member to superclass. · WHEN: subclasses duplicate it.
- **Push Down Field / Method** — move to the subclass(es) that use it. · WHEN: only some subclasses use it.
- **Extract Subclass** — subclass for case-specific features. · WHEN: features used only in some instances.
- **Extract Superclass** — shared parent for common members. · WHEN: two classes share fields/methods.
- **Extract Interface** — shared interface subset. · WHEN: clients use the same part of a class's interface.
- **Collapse Hierarchy** — merge sub+super. · WHEN: a subclass barely differs from its parent.
- **Form Template Method** — skeleton in superclass, varying steps overridden. · WHEN: subclasses share an algorithm's steps/order.
- **Replace Inheritance with Delegation** — field + delegating methods instead of extends. · WHEN: a subclass uses only part of its parent / shouldn't inherit data.
- **Replace Delegation with Inheritance** — extend the delegate. · WHEN: a class is many simple methods delegating to all of another's.

> Reminder: techniques serve smells. Detect the smell first (`code-smells.md`), apply the smallest technique, keep behavior identical. Don't add inheritance/patterns the code doesn't yet need.
