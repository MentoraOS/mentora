# MENTORA0009 — `mentora/projection-naming`

> Declarations ending in Projection must be <Name>Projection and those ending in ReadModel must be <Name>ReadModel (≥ 1 word before the suffix).

## Justification

A projection/read model is a named, recalculable derivation — never anonymous.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §9 (Projections `<Name>Projection`, Read Models `<Name>ReadModel`)

## Valid

```ts
AgreementHonoredProjection
CalendarProjection
AgendaReadModel
```

## Invalid

```ts
Projection
ReadModel
```

*Permanent diagnostic code: `MENTORA0009`. Codes are never renumbered, never reused.*
