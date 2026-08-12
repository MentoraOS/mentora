# MENTORA0005 — `mentora/query-naming`

> Declarations ending in Query must be <Truth><Aspect>Query (≥ 2 words before the suffix).

## Justification

A read is a contract with a named truth and aspect, never an anonymous fetch.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §9 (Queries `<Truth><Aspect>Query`)

## Valid

```ts
ConsentValidityQuery
AgreementStateQuery
```

## Invalid

```ts
DataQuery
Query
```

*Permanent diagnostic code: `MENTORA0005`. Codes are never renumbered, never reused.*
