# 04 — Roadmap, Risks & Future Improvements

## 0a. Done — Lot 0C (Testing Foundation)

Shipped the seven-package test factory: `testing-config` (Vitest preset),
`testing` (matchers/fixtures/random/golden), `testing-clock`, `testing-id`,
`testing-performance`, `testing-contracts` (port contract suites),
`testing-architecture` (the workspace tests its own dependency law). 40/40
tasks green, zero warnings. The Domain Kernel was OFFICIALLY REMOVED from
Phase 0 by CTO decision — no business concept before Phase 1.

## 0b. Done — Lot 0B (Engineering Kernel)

Shipped `@mentora/kernel` (Result/Option/Either, branded `Id`, `Clock`/`IdGenerator`
ports, typed errors, guards, utility types), `@mentora/shared` (pure utilities +
`Logger`/`Config` port contracts), `@mentora/contracts` (DI tokens, technical
DTOs, transverse types), plus the two-config build layout and the boundary
lint rules — all compiling, linting and testing green. No business logic.

## 1. Lot 0D — CI/CD & Delivery Foundation (proposed)

Phase 0 builds the factory; 0D gives it a conveyor belt:

1. **GitHub Actions pipeline** — setup (corepack + pnpm cache) → `pnpm install
   --frozen-lockfile` → `pnpm verify` (+ `--coverage`); the architecture suite
   runs as part of `test`, so the dependency law gates every PR.
2. **Turborepo remote cache** for incremental CI.
3. **`@mentora/eslint-plugin-mentora`** — the *domain* lint rules: forbidden
   vocabulary (Vocabulary Diff §D/§E as lint errors), event/command naming.
   Prepared here so Phase 1's first domain package is born governed.
4. **`turbo gen` scaffolds** — "new library package" / "new testing consumer"
   generators applying the two-tsconfig layout, preset wiring and README
   skeleton automatically.
5. **Docker build skeleton** for future apps (distroless Node base, pnpm deploy
   --prod), prepared but unused until the first app exists.

Phase 1 (separate order) then starts the domain work: contracts/domain/
application packages per bounded context, the Séquence harness, the first
vertical slice (Engagement) — none of it before the CTO opens Phase 1.

## 2. Later phases (indicative — Phase 1+, on CTO order)

- **Persistence** — Prisma schema per Registry, the Fiche de Registre as an
  opposable artifact, Outbox/Inbox (M-4), migrations (expand-contract).
- **Circulation** — RabbitMQ adapter behind the Bus port, Enveloppe vs fact
  separation (M-3), Quarantaine (M-8).
- **Observability** — OpenTelemetry wiring, the Journal (probant) vs Log
  (perdable) distinction (O-2), correlation.
- **Bounded contexts** — the 15 contexts, each as a
  contracts/domain/application/infra quad, starting with one vertical slice
  (Engagement) through the Séquence de Commande.

## 3. Risks identified

| # | Risk | Likelihood | Mitigation |
|---|------|-----------|------------|
| R1 | **Vocabulary drift** — code invents `Booking`/`Wallet` despite the Glossary | high without tooling | the domain ESLint plugin (0D) turns forbidden vocabulary into build errors |
| R2 | **Boundary erosion** — deep-into-src imports as teams grow | medium | `no-restricted-imports` + `no-cycle` are errors today; add `dependency-cruiser` graph checks in CI |
| R3 | **Nested monorepo friction** — `platform/` inside a Flutter repo confuses tooling | low | fully self-contained; documented; hoistable to its own repo |
| R4 | **Turborepo cache incorrectness** — stale build from wrong inputs | low | inputs/outputs declared per task; remote cache verified in CI |
| R5 | **Strictness fatigue** — `exactOptionalPropertyTypes`/`noUncheckedIndexedAccess` slow early velocity | medium | accepted trade-off; the cost is front-loaded and the Foundation demands it (F1 §4) |
| R6 | **Version skew** across shared deps | medium | pnpm catalog + `save-exact` + frozen lockfile |
| R7 | **Supply-chain (malicious postinstall)** | low/high-impact | lifecycle-script allowlist denied by default (F5.4) |

## 4. Future improvements (deliberately deferred, not forgotten)

- **`dependency-cruiser`** for a visual, CI-checked dependency graph beyond what
  ESLint expresses.
- **TypeScript project references** wired end-to-end (`tsc -b`) once packages
  exist, for the fastest incremental typecheck.
- **Changesets** for any externally published package.
- **Turborepo remote cache** (self-hosted) for fast CI.
- **Syncpack** to keep dependency versions identical across every package.
- **A code generator** (`turbo gen`) for scaffolding a new bounded-context quad
  with the correct tsconfig/eslint/exports wiring, so the conventions are
  applied by a tool, not by memory.

## 5. What must never change

The `platform/` code implements the Foundation and never legislates. Any
pressure to "just add a field/event/rule here" is redirected to the Foundation's
Titre VII. The monorepo is a projection; the Source stays sovereign.
