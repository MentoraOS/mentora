# MENTORA0015 — `mentora/no-dto-in-domain`

> Forbids Dto/DTO in declaration names inside domain packages; at the edges the ratified word is <X>Payload.

## Justification

DTOs are forbidden in the domain; the edge shape is a Payload.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §9 (« DTO interdits dans le domaine ; aux bords `<X>Payload` »)

## Valid

```ts
class AgreementPayload {}
```

## Invalid

```ts
class AgreementDto {}
class AgreementDTO {}
```

*Permanent diagnostic code: `MENTORA0015`. Codes are never renumbered, never reused.*
