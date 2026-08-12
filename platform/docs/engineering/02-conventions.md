# 02 — Conventions (naming · packages · apps · libraries · imports · aliases)

Conventions are only real if a machine enforces them. Where a rule below can be
linted or type-checked, it is; the prose here is the rationale, not the
enforcement.

## 1. Naming

| Thing | Rule | Example |
|-------|------|---------|
| npm package | `@mentora/<ring>-<context>` (kebab-case) | `@mentora/domain-engagement` |
| app package | `@mentora/app-<name>` or `@mentora/<species>-<name>` | `@mentora/app-api`, `@mentora/worker-notifications` |
| directory | matches the package's short name | `packages/domain-engagement/` |
| file | `kebab-case.ts`; one primary export per file | `agreement.repository.ts` |
| test file | `*.spec.ts` (unit), `*.e2e-spec.ts` (e2e) | `agreement.spec.ts` |
| type-only barrel | `src/index.ts` — the single public entrypoint | |

Domain words come **exclusively from the Foundation's bilingual dictionary**
(F2.5 / the Glossary). `Agreement`, never `Booking`. `Payout`, never
`Withdrawal`. The forbidden-vocabulary list (Vocabulary Diff §D/§E) applies to
identifiers: a symbol named `Booking` is a lint-level defect once the
domain-lint rule lands in 0B.

## 2. Package conventions (`packages/*`)

- `private` unless a package is genuinely published; versioned only if published.
- Extends `@mentora/tsconfig/library`. Emits `.d.ts` + declaration maps.
  `composite: true` so `tsc -b` and editors resolve project references fast.
- **One public entrypoint**: `src/index.ts`. Everything else under `src/` is
  private. This is the code form of F3.1's "referenced by identity, never
  reached into."
- `exports` map in `package.json` points to `dist/index.js` + `dist/index.d.ts`;
  no `main` reaching into source.
- A package declares **every** dependency it imports (no phantom deps — enforced
  by `.npmrc hoist=false`).

## 3. Application conventions (`apps/*`)

- `private: true`, unversioned (apps are deployed, not published).
- Extends `@mentora/tsconfig/nestjs` (decorators + metadata).
- Owns `src/main.ts` (bootstrap), `Dockerfile`, and its deployment manifest.
- Depends only **downward** (packages, tooling). An app importing another app is
  an error.
- An app is thin: it wires modules from `packages/*` and owns no domain truth.

## 4. Library conventions (the ring model)

Libraries are layered; the dependency arrow points inward (F4.4 I-1):

```
kernel → shared → contracts → domain → application → infrastructure
```

- **kernel** — base building-block types (DomainEvent, Aggregate root contract,
  Decision, Reason, Result, Id). Pure; imports nothing; no domain instances.
- **shared** — cross-cutting pure utilities and **port contracts** (e.g. a
  `Clock` port), never their adapters.
- **contracts-<context>** — a domain's *published language* as types (its Events
  and Commands from F2.5). One per bounded context.
- **domain-<context>** — the Aggregates, Policies, Specifications of one context
  (F3). No framework imports (F4.4 I-7).
- **application-<context>** — the Séquence orchestration and ports (F4.1).
- **infra-<adapter>** — adapters behind ports (Prisma, Redis, RabbitMQ…). The
  only ring allowed to import a vendor SDK.

## 5. Import rules

1. **Package name, not path.** Reach another package by `@mentora/kernel`, never
   `../../kernel/src/...`. Enforced by `no-restricted-imports` (boundaries.mjs).
2. **Inward only.** Libraries never import apps. Enforced.
3. **No cycles.** Enforced by `import-x/no-cycle`.
4. **Type-only imports are explicit** (`import type`), so the emit is clean and
   `verbatimModuleSyntax` is satisfied. Enforced by
   `@typescript-eslint/consistent-type-imports`.
5. **Ordered, grouped imports** (builtin → external → internal → relative).
   Auto-fixed by `import-x/order`.

## 6. TypeScript "aliases" — the deliberate decision

**We do not use `tsconfig.paths` for cross-package aliases.** In a pnpm
workspace, packages already resolve by their real name through the
`node_modules` symlinks pnpm creates. `tsconfig.paths` would be a *second,
parallel* resolution map that the bundler, Node, Jest/Vitest, and `tsc` each
have to be told about separately — a well-known source of "resolves in the
editor, fails at runtime" drift.

Decision:

- **Cross-package** references use the **package name** (`@mentora/kernel`).
  One resolution mechanism, understood by every tool, checked by the linter.
- **Within a single package**, a package *may* define one intra-package alias
  `@/*` → `src/*` in its own tsconfig if it improves local readability — but it
  is optional and never leaks across a package boundary.

*Alternative considered:* a global `@mentora/*` → `packages/*/src` paths map.
Rejected — it re-introduces deep-into-src imports (breaking encapsulation),
duplicates the resolver, and couples every tool's config to the folder layout.

## 7. Environment & configuration

- Config is read once at the composition root and injected (F4.1 A-6: identity,
  time, config are injected, never ambient). No `process.env` reads scattered
  through libraries.
- Three config kinds (F4.4 I-5): product (a published Policy), technical
  (runtime), secret (the vault). Secrets never appear in a committed file.
