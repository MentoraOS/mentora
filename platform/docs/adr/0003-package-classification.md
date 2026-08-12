# ADR 0003 — Package Classification

- **Status:** Accepted (R3 Phase 0, Lot 0B)
- **Deciders:** Principal Engineer, under the authority of the frozen Foundation
- **Context version:** `foundation-v1.0.0` (`8d095ee`)

## Context

A monorepo of hundreds of packages is only maintainable if **every package has a
declared kind**, and each kind has fixed rules about what it may depend on. Without
this, the dependency graph rots into a ball of mud. This ADR defines the official
package **families**, their responsibilities and owners, and — most importantly —
the **allowed and forbidden dependencies** for each. The graph is then enforced by
`@mentora/eslint-config/boundaries` + `import-x/no-cycle`, not by memory.

The classification is the code realization of the Foundation's F4.4 **I-1**
("dependency points to the center") and **I-12** ("the graph is acyclic by
construction"), and of the F2 idea that a *surface* is downstream of a *domain*.

## The nine families

Families are ordered from the **center** (most stable, most depended-upon) to the
**edge** (most volatile, depended-upon by no one). **The dependency arrow always
points toward the center.**

| # | Family | Package name pattern | Ownership |
|---|--------|----------------------|-----------|
| 1 | **Tooling** | `@mentora/tsconfig`, `@mentora/eslint-config`, … | Platform / DX |
| 2 | **Kernel** | `@mentora/kernel` | Platform / DX |
| 3 | **Shared** | `@mentora/shared`, `@mentora/shared-*` | Platform / DX |
| 4 | **Contracts** | `@mentora/contracts` (technical), `@mentora/contracts-<context>` (domain) | Platform (technical) / domain team (per context) |
| 5 | **Domain** | `@mentora/domain-<context>` | the owning domain team |
| 6 | **Application** | `@mentora/application-<context>` | the owning domain team |
| 7 | **Infrastructure** | `@mentora/infra-<capability>` | Platform / infra team |
| 8 | **Adapters** | `@mentora/adapter-<provider>-<capability>` | Platform / infra team |
| 9 | **Apps** | `@mentora/app-*`, `@mentora/worker-*`, … | the owning delivery team |

> **Tooling** is drawn as family #1 because it is a build-time dependency of
> everything, but it carries no runtime code and is not part of the runtime
> dependency graph; it never *imports* anything from the workspace.

### 1. Kernel — `@mentora/kernel`

- **Responsibility.** The fundamental, universal abstractions every other package
  uses: `Result`, `Option`, `Either`, branded `Id`, `Brand`, the `Clock` and
  `IdGenerator` **port interfaces**, typed errors, guards/invariants, utility
  types. No domain concepts, no I/O, no framework.
- **Owner.** Platform / DX.
- **May depend on.** Nothing (zero runtime dependencies). This is the fixed point
  of the graph.
- **Must never depend on.** Anything. A kernel with a dependency is not a kernel.
- **Examples.** `Result<T,E>`, `Option<T>`, `Id<Brand>`, `invariant()`,
  `DeepReadonly<T>`.
- **Justification.** A single, dependency-free center gives the whole graph a
  stable foundation and guarantees acyclicity by construction (nothing the kernel
  could import could import it back).

### 2. Shared — `@mentora/shared`

- **Responsibility.** Pure, reusable utilities and cross-cutting **port
  contracts** (Logger, Config): functional helpers, array/object/string/math
  helpers, pure datetime helpers over kernel's `Instant`, validation helpers
  returning `Result`, retry *policy* descriptions. No I/O, no business logic.
- **Owner.** Platform / DX.
- **May depend on.** `kernel`.
- **Must never depend on.** contracts, domain, application, infrastructure,
  adapters, apps. (Nothing more central-adjacent than kernel.)
- **Examples.** `pipe()`, `chunk()`, `clamp()`, `Logger` (port), `RetryPolicy`.
- **Justification.** A place for genuinely universal code that is richer than the
  kernel but still domain-free and I/O-free.

### 3. Contracts — `@mentora/contracts` (+ `@mentora/contracts-<context>`)

- **Responsibility.** *Interfaces only, no implementation.* Two sub-kinds:
  - **Technical contracts** (`@mentora/contracts`): dependency-injection tokens,
    cross-cutting technical ports, technical DTOs (`Page<T>`, `Sort`), transverse
    types (`CorrelationId`).
  - **Domain contracts** (`@mentora/contracts-<context>`, later lots): a bounded
    context's *published language* — its Events and Commands as types (F2.5). One
    package per context.
- **Owner.** Platform (technical) / the domain team (per context).
- **May depend on.** `kernel`, `shared`. A domain-contracts package may also
  depend on the technical `contracts`.
- **Must never depend on.** domain, application, infrastructure, adapters, apps,
  or any *other* domain's contracts (a context's language is its own).
- **Examples.** `TOKEN.Clock`, `Page<T>`, `CorrelationId`; later
  `AgreementConfirmed` (type, in `contracts-engagement`).
- **Justification.** Contracts are the seams of the system. Keeping them
  implementation-free means a consumer compiles against a promise, and the
  implementation can change behind it without a ripple (F4.4 I-4: a port belongs
  to its consumer).

### 4. Domain — `@mentora/domain-<context>`

- **Responsibility.** One bounded context's Aggregates, Entities, Value Objects,
  Policies, Specifications, Domain Events, Decisions (F3). **Pure business truth,
  no I/O, no framework.**
- **Owner.** The domain team.
- **May depend on.** `kernel`, `shared`, its own `contracts-<context>`, the
  technical `contracts`.
- **Must never depend on.** application, infrastructure, adapters, apps, or
  **another domain** (F2 P5: no domain writes into another; cross-domain facts
  are published contracts consumed as types). No framework import (F4.4 I-7).
- **Examples (later lots).** `Agreement` (Aggregate), `AgreementCancellationPolicy`.
- **Justification.** The center of gravity of the business. Isolating it from I/O
  and frameworks is what makes it testable without doubles and durable across
  infrastructure changes.

### 5. Application — `@mentora/application-<context>`

- **Responsibility.** The use-case orchestration — the Séquence de Commande (F4.1)
  — and the **port interfaces** it commands. Orchestration only; never business
  decisions, never I/O directly.
- **Owner.** The domain team.
- **May depend on.** `kernel`, `shared`, `contracts` (technical),
  `contracts-<context>`, `domain-<context>`.
- **Must never depend on.** infrastructure, adapters, apps, another context's
  application. Never calls another Application Service (F3.1.10 / A-1).
- **Examples (later lots).** `ConfirmAgreementApplicationService` (the ten-step
  Séquence), the `AgreementRepository` **port**.
- **Justification.** The application ring is where the Séquence lives; keeping
  adapters out of it preserves the "boring by construction" property (F4.1 §7).

### 6. Infrastructure — `@mentora/infra-<capability>`

- **Responsibility.** Implementations of technical/application ports that are
  **not** tied to a single third-party product: an in-memory bus, an outbox
  relay skeleton, a unit-of-work implementation over a generic transaction port.
- **Owner.** Platform / infra team.
- **May depend on.** `kernel`, `shared`, `contracts`, and the specific
  `application-<context>` **ports** it implements.
- **Must never depend on.** domain internals (only the ports), apps, another
  infra's internals.
- **Examples (later lots).** `infra-outbox`, `infra-unit-of-work`.
- **Justification.** Separates "how we do plumbing" from "which vendor" (next
  family), so a vendor swap touches only adapters.

### 7. Adapters — `@mentora/adapter-<provider>-<capability>`

- **Responsibility.** The vendor-specific implementations behind a port: Prisma
  for a Registry, RabbitMQ for the Bus, Redis for a cache, OpenSearch for search,
  MinIO for Deposits. **The only family allowed to import a third-party SDK**
  (F4.4 I-4: an adapter serves one frontier).
- **Owner.** Platform / infra team.
- **May depend on.** `kernel`, `shared`, `contracts`, the ports they implement,
  and their one vendor SDK.
- **Must never depend on.** domain internals, application internals (only ports),
  apps, another adapter.
- **Examples (later lots).** `adapter-prisma-postgres`, `adapter-rabbitmq-bus`.
- **Justification.** Vendors are mechanisms (F5): interchangeable, quarantined to
  the outermost importable ring, so replacing one is a local change.

### 8. Apps — `@mentora/app-*`, `@mentora/worker-*`, …

- **Responsibility.** Deployable units: the composition root that wires modules
  (F4.4 I-2/I-3), the NestJS bootstrap, the Dockerfile. Maps onto the six
  executable species (F5.1). **Owns no business truth.**
- **Owner.** The delivery team.
- **May depend on.** any package family (it is the outermost ring).
- **Must never depend on.** **another app** (apps are leaves).
- **Examples (later lots).** `app-api`, `worker-notifications`, `migrator`.
- **Justification.** The one place concrete types are known (the composition
  root); everything above receives, never searches (F4.4 I-2).

### 9. Tooling — `@mentora/tsconfig`, `@mentora/eslint-config`, …

- **Responsibility.** Build-time configuration as packages. No runtime code.
- **Owner.** Platform / DX.
- **May depend on.** peer tools (eslint, prettier) only.
- **Must never depend on.** any runtime workspace package.
- **Justification.** Makes the conventions executable and versioned in one place.

## The dependency graph (demonstrated)

```
                                  ┌─────────┐
      may import ▼ only           │ kernel  │   (center — imports nothing)
                                  └────▲────┘
                                       │
                                  ┌────┴────┐
                                  │ shared  │
                                  └────▲────┘
                                       │
                              ┌────────┴────────┐
                              │    contracts    │  (technical + per-context)
                              └───▲────────▲────┘
                                  │        │
                     ┌────────────┘        └───────────┐
                ┌────┴─────┐                     ┌──────┴──────┐
                │  domain  │◀────────────────────│ application │
                └──────────┘   (application uses  └──────▲──────┘
                                domain + contracts)      │ (implements its ports)
                                                  ┌──────┴──────┐
                                                  │    infra    │
                                                  └──────▲──────┘
                                                         │
                                                  ┌──────┴──────┐
                                                  │  adapters   │  (+ one vendor SDK)
                                                  └──────▲──────┘
                                                         │
                                                  ┌──────┴──────┐
                                                  │    apps     │  (leaves; wire everything)
                                                  └─────────────┘
```

**Invariants (linter-enforced):**

1. Every arrow points up (toward the center). A downward import is an error.
2. `kernel` imports nothing; `apps` are imported by nothing.
3. No cycles (`import-x/no-cycle`), so the graph is a DAG (F4.4 I-12).
4. Cross-package imports go through the package **name**, never a deep path into
   another package's `src/`.
5. A domain never imports another domain; contexts speak only through published
   contracts consumed as types (F2 P5).
6. Only **adapters** import third-party SDKs.

## Consequences

- **Positive:** every package's allowed dependencies are knowable from its family
  alone; the graph is a DAG by construction; vendor and framework coupling is
  quarantined at the edge; the Foundation's structural laws are mechanically true
  in code.
- **Negative / accepted:** more packages than a flat structure, and a contributor
  must place a new package in the right family — mitigated by a future
  `turbo gen` scaffold that applies the family's wiring automatically.

## Compliance with the Foundation

This ADR classifies engineering packages; it creates no law, Aggregate, Event,
Command, or Policy. It makes F4.4's I-1/I-12 and F2's P5 executable. Law changes
go through Titre VII, never through package placement.
