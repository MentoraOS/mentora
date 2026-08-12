# 04 — Roadmap, Risks & Future Improvements

## 1. Lot 0B — Kernel & the first vertical slice

Lot 0A ships the substrate. Lot 0B begins turning the Foundation into code,
**bottom-up and thin-first**:

1. **`@mentora/kernel`** — the F3.1 building-block **base types** (no domain
   instances): `DomainEvent`, `AggregateRoot` contract, `Decision`/`Reason`,
   `Result`, opaque `Id<T>`, the `Clock` port. Pure, dependency-free, 100% typed.
2. **`@mentora/eslint-plugin-mentora`** — the *domain* lint rules: forbidden
   vocabulary (Vocabulary Diff §D/§E as lint errors), event naming
   `<Truth><PastParticiple>`, command naming `<Verb><Truth>`, "no framework
   import in domain" (I-7). This makes the Glossary executable.
3. **One vertical slice, end to end, for a single bounded context** — proposed:
   **Engagement** (the `Agreement`), because it is the richest state machine and
   exercises R-A (registry key), R-B (new unit after terminal), and the Séquence:
   `contracts-engagement` → `domain-engagement` → `application-engagement` →
   `infra-engagement-prisma` → `app-api` (one command path only).
4. **The Séquence de Commande (F4.1) as a reusable application harness** — the
   ten steps encoded once so every use case is "boring by construction."

The goal of 0B is *one command flowing through all ten steps of the Séquence*,
proving the architecture, before breadth.

## 2. Later lots (indicative)

- **0C** — persistence: Prisma schema per Registry, the Fiche de Registre as an
  opposable artifact, Outbox/Inbox (M-4), migrations (expand-contract).
- **0D** — circulation: RabbitMQ adapter behind the Bus port, Enveloppe vs fact
  separation (M-3), Quarantaine (M-8).
- **0E** — observability: OpenTelemetry wiring, the Journal (probant) vs Log
  (perdable) distinction (O-2), correlation.
- **0F** — CI/CD, Changesets (if any package is published), Docker images,
  Turborepo remote cache.
- **1.x** — the remaining 14 bounded contexts, each as a
  contracts/domain/application/infra quad.

## 3. Risks identified

| # | Risk | Likelihood | Mitigation |
|---|------|-----------|------------|
| R1 | **Vocabulary drift** — code invents `Booking`/`Wallet` despite the Glossary | high without tooling | the domain ESLint plugin (0B) turns forbidden vocabulary into build errors |
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
