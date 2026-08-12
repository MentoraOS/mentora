# MENTORA0001 — `mentora/forbidden-vocabulary`

> Forbids the banned words of the official Glossary (Booking, User, Wallet, Rating…) in declaration names.

## Justification

One concept, one word: the forbidden vocabulary is law, and a banned word in code is lexical drift the Constitution forbids.

## R2 reference (the law this rule executes)

R2 source/constitution/04-bilingual-dictionary.md §10 (Forbidden Vocabulary) · projection/glossary/02-vocabulary-diff.md VD-0066→VD-0082 · F2.9 P16

## Valid

```ts
class Agreement {}
const person = 1;
class AvailableFunds {}
```

## Invalid

```ts
class Booking {}
const user = 1;
class WalletView {}
class RatingBar {}
```

*Permanent diagnostic code: `MENTORA0001`. Codes are never renumbered, never reused.*
