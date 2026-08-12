# MENTORA0012 — `mentora/port-naming`

> Declarations ending in Port must be <Capability>Port (≥ 1 word before the suffix).

## Justification

A port names the capability its consumer commands, never the technology behind it.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §9 (Ports `<Capability>Port`)

## Valid

```ts
SettlementPort
SignalDeliveryPort
```

## Invalid

```ts
Port
```

*Permanent diagnostic code: `MENTORA0012`. Codes are never renumbered, never reused.*
