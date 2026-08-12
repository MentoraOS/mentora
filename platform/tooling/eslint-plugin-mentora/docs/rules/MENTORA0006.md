# MENTORA0006 — `mentora/policy-naming`

> Declarations ending in Policy must be <Truth><Rule>Policy (≥ 2 words before the suffix).

## Justification

A policy is a published rule about a named truth; a bare XPolicy names no rule.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §9 (Policies `<Truth><Rule>Policy`)

## Valid

```ts
AgreementCancellationPolicy
ConsentDefinitivenessPolicy
```

## Invalid

```ts
AgreementPolicy
Policy
```

*Permanent diagnostic code: `MENTORA0006`. Codes are never renumbered, never reused.*
