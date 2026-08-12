# MENTORA0003 — `mentora/event-naming`

> In event files (events/ directories, *.event.ts), every exported PascalCase declaration must be <Truth><PastParticiple> (…ed, or a ratified irregular: Struck, Withdrawn, Kept, Undeliverable).

## Justification

A fact is a constatation: the past participle is mandatory ("préfixe = propriétaire, participe passé obligatoire"). AgreementUpdated-style state events and -Created for business facts are dead.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §4 (Event Dictionary) · source/domain/01-tactical-building-blocks.md (Domain Event)

## Valid

```ts
AgreementConfirmed
ReviewPublished
ConsentWithdrawn
SignalUndeliverable
```

## Invalid

```ts
ConfirmAgreement
AgreementConfirm
AgreementState
```

*Permanent diagnostic code: `MENTORA0003`. Codes are never renumbered, never reused.*
