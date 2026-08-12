# MENTORA0004 — `mentora/command-naming`

> In command files (commands/ directories, *.command.ts), every exported declaration must be <Verb><Truth> (at least two words) and never start with the banned generics Set/Save.

## Justification

A command is an imperative verb applied to a truth, always refusable. Set/Save are storage verbs, not business acts; a one-word command names no truth.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §5 (Command Dictionary, interdits)

## Valid

```ts
ConfirmAgreement
RequestPayout
DismissSuggestion
```

## Invalid

```ts
SetAgreement
SaveAgreement
Confirm
```

*Permanent diagnostic code: `MENTORA0004`. Codes are never renumbered, never reused.*
