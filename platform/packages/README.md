# packages/

**Shared libraries.** Everything an app (or another library) imports lives
here. Packages are the **interior** of the dependency graph; they never import
an app.

> **No business logic at Lot 0A — by design.** No Aggregate, Event, Command,
> Policy, Repository, Process Manager, or Adapter exists yet. This lot ships
> only the taxonomy and conventions into which Lot 0B will place them. Creating
> them now would be creating law, which the Foundation forbids outside its own
> ratified text.

## The intended layering (materialized in Lot 0B+)

Packages fall into concentric rings, and the dependency arrow always points
**inward** — exactly the Foundation's I-1. A ring may depend on rings inside
it, never outside.

| Ring | Prefix | Holds | Depends on |
|------|--------|-------|------------|
| Kernel | `@mentora/kernel` | the F3.1 tactical building-block **base types** (DomainEvent, Aggregate root contract, Decision, Reason…) — pure, no domain instances | nothing |
| Shared | `@mentora/shared-*` | cross-cutting pure utilities (result types, ids, time port contracts) | kernel |
| Contracts | `@mentora/contracts-*` | the published language of a domain (F2.5 events/commands as types) — one package per bounded context | kernel, shared |
| Domain | `@mentora/domain-<context>` | one bounded context's Aggregates, Policies, Specifications (F3) | kernel, shared, its own contracts |
| Application | `@mentora/application-<context>` | the Séquence orchestration, ports (F4.1) | kernel, shared, domain, contracts |
| Infrastructure | `@mentora/infra-*` | adapters behind ports (Prisma, Redis, RabbitMQ, OpenSearch, MinIO — F4.4) | the ports they implement only |

The 15 bounded contexts of the Foundation (Engagement, Consultation, Reputation,
Economy, …) each become a `domain-<context>` + `contracts-<context>` +
`application-<context>` triad. **None is created in Lot 0A.**

## Conventions (see `docs/engineering/02-conventions.md`)

- Package name: `@mentora/<ring>-<context>`.
- Extends `@mentora/tsconfig/library`; emits `.d.ts`; `composite: true`.
- Single public entrypoint (`src/index.ts`); internals are private.
- No decorators, no framework imports in kernel/shared/contracts/domain
  (F4.4 I-7: no framework import in the domain).
