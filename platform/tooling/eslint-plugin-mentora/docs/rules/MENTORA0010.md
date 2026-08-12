# MENTORA0010 — `mentora/process-manager-naming`

> Declarations ending in Process must be <Journey>Process (≥ 1 word before the suffix).

## Justification

A Process Manager is a named transverse journey (e.g. ErasureProcess), never a generic engine.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §9 (Process Managers `<Journey>Process`)

## Valid

```ts
ErasureProcess
```

## Invalid

```ts
Process
```

*Permanent diagnostic code: `MENTORA0010`. Codes are never renumbered, never reused.*
