# MENTORA0007 — `mentora/specification-naming`

> Declarations ending in Specification must carry a named question (≥ 1 word before the suffix).

## Justification

A Specification is a named, composable business predicate — never anonymous.

## R2 reference (the law this rule executes)

R2 source/domain/01-tactical-building-blocks.md (Specification, Naming Constitution `<Question>Specification`)

## Valid

```ts
DismissedSuggestionSpecification
PayableAmountSpecification
```

## Invalid

```ts
Specification
```

*Permanent diagnostic code: `MENTORA0007`. Codes are never renumbered, never reused.*
