# MENTORA0011 — `mentora/adapter-naming`

> Declarations ending in Adapter must be <Provider><Capability>Adapter (≥ 2 words before the suffix).

## Justification

An adapter serves one frontier for one provider; provider names appear at the Adapter rank and nowhere else.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §9 (Adapters `<Provider><Capability>Adapter`)

## Valid

```ts
LivekitRoomAdapter
StripeSettlementAdapter
```

## Invalid

```ts
StripeAdapter
Adapter
```

*Permanent diagnostic code: `MENTORA0011`. Codes are never renumbered, never reused.*
