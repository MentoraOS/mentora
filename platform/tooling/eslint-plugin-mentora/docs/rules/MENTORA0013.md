# MENTORA0013 — `mentora/application-service-naming`

> Declarations ending in ApplicationService must be <UseCase>ApplicationService (≥ 1 word before the suffix).

## Justification

One use case = one Command = one Application Service; the name carries the use case.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §9 (Application Services `<UseCase>ApplicationService`) · source/application/01-application-core-sequence.md §8

## Valid

```ts
ConfirmAgreementApplicationService
```

## Invalid

```ts
ApplicationService
```

*Permanent diagnostic code: `MENTORA0013`. Codes are never renumbered, never reused.*
