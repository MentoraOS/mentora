# MENTORA0006 — `mentora/policy-naming`

> Declarations ending in Policy must carry a named rule (≥ 1 word before the suffix) — the ratified catalogue includes single-stem policies (ReschedulePolicy, ConfirmationPolicy, F3.3 §6).

## Justification

A policy is a published rule about a named truth; a bare XPolicy names no rule.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §9 (Policies `<Truth><Rule>Policy`)

## Valid

```ts
AgreementCancellationPolicy
ReschedulePolicy
ConfirmationPolicy
```

## Invalid

```ts
Policy
```

*Permanent diagnostic code: `MENTORA0006`. Codes are never renumbered, never reused.*
