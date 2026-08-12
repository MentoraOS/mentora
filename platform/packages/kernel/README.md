# @mentora/kernel

The fundamental, **dependency-free** abstractions every Mentora package uses.
The fixed center of the dependency graph (ADR 0003): it imports nothing, so
nothing it could import could import it back — acyclicity by construction.

> **No business logic.** No Aggregate, Event, Command, Policy, or I/O. Just the
> universal building blocks.

## What's inside

| Area | Exports |
|------|---------|
| **Result** | `Result<T,E>`, `ok`, `err`, `isOk`, `isErr`, `map`, `mapErr`, `andThen`, `unwrapOr`, `matchResult`, `fromThrowable` |
| **Option** | `Option<T>`, `some`, `none`, `isSome`, `isNone`, `fromNullable`, `mapOption`, `flatMapOption`, `getOrElse`, `toResult` |
| **Either** | `Either<L,R>`, `left`, `right`, `isLeft`, `isRight`, `mapEither`, `mapLeft`, `matchEither` |
| **Identity** | `Id<TBrand>`, `Uuid`, `IdGenerator` (port), `isUuid` |
| **Time** | `Instant`, `EpochMillis`, `Clock` (port), `instantOf`, `isBefore`, `isAfter`, `isEqualInstant` |
| **Diagnostics** | `KernelError`, `InvariantViolationError`, `GuardError`, `invariant`, `guardDefined`, `isDefined`, `assertNever`, `isNonEmptyArray` |
| **Types** | `Brand`, `DeepReadonly`, `Prettify`, `NonEmptyArray`, `Primitive`, `UnknownRecord` |

## Design rules

- **Failure is a value, never an exception.** Domain-style refusals use `Result`
  (F3.1.14). Exceptions (`KernelError`) are reserved for *programmer* errors —
  broken invariants — and are thrown.
- **Impurity is a port.** `Clock` and `IdGenerator` are interfaces; their
  implementations live in adapters. The kernel stays pure (F4.1 A-6).
- **Immutable-first.** Every value is `readonly`; helpers are free functions
  (tree-shakable), not methods.
- **Opaque identity.** `Brand`/`Id` make ids un-confusable at compile time, at
  zero runtime cost (F3.1.99 §4).

## Layout

```
src/
├── index.ts        the single public barrel (the contract)
├── core/           result · option · either
├── ports/          clock · id
├── diagnostics/    errors · guard
└── types/          brand · utility-types
```

Import only from the package name: `import { ok, err } from '@mentora/kernel';`.
