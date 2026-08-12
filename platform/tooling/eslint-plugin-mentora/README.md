# @mentora/eslint-plugin-mentora

The Constitution's architecture laws as **executable lint rules**. Every rule
derives from the frozen R2 corpus, carries a **permanent diagnostic code**
(`MENTORA0001`…), and cites the chapter that owns the law. **Rules without an R2
source do not exist** — that is this plugin's own constitution.

## Usage

```js
// eslint.config.mjs
import mentora from '@mentora/eslint-config';
import boundaries from '@mentora/eslint-config/boundaries';
import mentoraPlugin from '@mentora/eslint-plugin-mentora';

export default [...mentora, ...boundaries, ...mentoraPlugin.configs.constitution];
```

## The four configurations

| Config | Level | Purpose |
|--------|-------|---------|
| `recommended` | warn | adoption mode — see the violations before enforcing |
| `strict` | error | every rule an error |
| `constitution` | error | the constitutional default for Mentora packages |
| `enterprise` | error | constitution + org-level extensions (today ≡ constitution — no law invented beyond R2) |

Import boundaries (I-1/I-12) live in `@mentora/eslint-config/boundaries`;
compose both, as above.

## The sixteen rules

See [docs/INDEX.md](docs/INDEX.md) — generated from the rule catalog
(`pnpm build && pnpm docs:generate`), one file per permanent code, each with
description, justification, **R2 reference**, valid and invalid examples.

| Code | Rule |
|------|------|
| MENTORA0001 | `forbidden-vocabulary` — the Glossary's banned words |
| MENTORA0002 | `no-forbidden-suffixes` — Manager/Helper/Util/Impl/Base-/bare Service |
| MENTORA0003 | `event-naming` — `<Truth><PastParticiple>` |
| MENTORA0004 | `command-naming` — `<Verb><Truth>`, no Set/Save |
| MENTORA0005–0014 | the building-block suffix laws (Query, Policy, Specification, Repository, Projection/ReadModel, Process, Adapter, Port, ApplicationService, Exception) |
| MENTORA0015 | `no-dto-in-domain` — DTOs die in the domain; edges use `<X>Payload` |
| MENTORA0016 | `no-framework-import-in-domain` — F4.4 I-7 executable |

## Maintenance rules

1. **A new rule requires an R2 source.** No source → no rule → signal it to the
   CTO (Titre VII), never invent.
2. **Codes are permanent** — never renumbered, never reused (the VD-NNNN
   discipline).
3. **The catalog is the single source of truth** (`src/catalog.ts`): rules, docs
   and tests all derive from it; a drift fails the test suite.
4. After changing the catalog: `pnpm build && pnpm docs:generate && pnpm test`.
