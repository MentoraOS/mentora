# ADR 0001 — Monorepo foundation & tooling

- **Status:** Accepted (R3 Phase 0, Lot 0A)
- **Deciders:** Principal Engineer, under the authority of the frozen Foundation
- **Context version:** `foundation-v1.0.0` (`8d095ee`)

## Context

R2 produced the frozen Constitution of Mentora (Titles F1→F5). R3 implements it
in running code. We need an engineering foundation that will carry hundreds of
packages, dozens of apps, several teams, for ~10 years, and that mechanically
respects the Foundation's structural laws (ownership, acyclic inward
dependencies, one-word-one-meaning). This ADR records the load-bearing tooling
choices. It touches no law and creates no domain concept.

## Decisions & alternatives

### D1 — Location: a self-contained `platform/` directory

The repo root is the existing Flutter client. **Chosen:** put the entire Node
platform under `platform/`, importing nothing outside it. *Alternatives:*
root-level mixed monorepo (rejected — toolchain collision); a separate git repo
now (deferred — `platform/` is hoistable later, keeping the decision reversible).

### D2 — Package manager: pnpm

**Chosen:** pnpm. Content-addressed store (fast, disk-cheap at scale), strict
`node_modules` that **forbids phantom dependencies** by default, first-class
workspaces + version catalog. *Alternatives:* npm workspaces (no strictness, slow
at scale); Yarn Berry PnP (powerful but higher friction with the Node/NestJS
ecosystem). pnpm's strictness directly serves the Foundation's "declare what you
depend on" discipline.

### D3 — Task runner: Turborepo

**Chosen:** Turborepo — minimal, framework-agnostic task graph + caching.
*Alternative:* Nx (richer: generators, enforced module boundaries, graph
analytics) — rejected for the *foundation* because it is heavier and more
prescriptive; we encode boundaries in portable ESLint instead. Revisit if
generator ergonomics dominate.

### D4 — Language: TypeScript, strictest-safe

**Chosen:** all correctness flags on, plus `noUncheckedIndexedAccess`,
`exactOptionalPropertyTypes`, `verbatimModuleSyntax`, `isolatedModules`. The
compiler carries contracts the runtime will not have to rediscover (F1 §4). Cost:
more ceremony early. Accepted.

### D5 — Cross-package references by name, not `tsconfig.paths`

**Chosen:** packages resolve by their real name (`@mentora/kernel`) via pnpm's
symlinks — one resolution mechanism every tool understands. *Alternative:* a
global `@mentora/*` → `packages/*/src` paths map — rejected: it duplicates the
resolver, breaks encapsulation (imports reach into `src/`), and couples every
tool to the folder layout.

### D6 — Boundaries as lint errors

**Chosen:** encode the dependency-direction invariants (libs never import apps;
cross-package imports via package name; no cycles) as **error-level** ESLint
rules. A boundary that only warns is already crossed. This is the code
realization of F4.4 I-1 and I-12.

### D7 — Backing services via Docker Compose (dev only)

**Chosen:** Postgres/Redis/RabbitMQ/OpenSearch/MinIO/Jaeger as local mechanisms,
owned by operations, holding no truth (the F5 stance). Production topology (K8s,
cells) is out of scope for 0A.

## Consequences

- **Positive:** legible, enforceable, portable foundation; strictness front-loads
  defect detection; boundaries can't silently rot; the platform version is
  cleanly decoupled from the Foundation version.
- **Negative / accepted:** early velocity tax from strict TS; a nested monorepo
  is slightly unusual (mitigated by full self-containment); Turborepo lacks
  generators (deferred via `turbo gen` later).

## Compliance with the Foundation

This ADR creates no law, no Aggregate, no Event, no Command, no Policy. It records
engineering decisions only. When code and Foundation disagree, the Foundation is
authoritative (PG-3); law changes go through Titre VII, never through this repo.
