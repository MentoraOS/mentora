# MENTORA0008 — `mentora/repository-naming`

> Declarations ending in Repository must be <Truth>Repository (≥ 1 word before the suffix).

## Justification

A repository is the registry of exactly one truth; a nameless Repository guards nothing.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §9 (Repositories `<Truth>Repository`)

## Valid

```ts
AgreementRepository
ConsentLedgerRepository
```

## Invalid

```ts
Repository
```

*Permanent diagnostic code: `MENTORA0008`. Codes are never renumbered, never reused.*
