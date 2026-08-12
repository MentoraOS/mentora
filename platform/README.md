# Mentora Platform

The TypeScript/NestJS engineering monorepo that **implements** the Mentora
Foundation. The Foundation (`docs/canon/`, frozen at `foundation-v1.0.0`) is the
sole authority; this repository is one of its projections into running code. No
line here may create, rename, or modify a law, a domain, an Aggregate, an Event,
a Command, or a Policy — code only implements what the Foundation already
ratified.

> **Status — R3 Phase 0, Lot 0A (Monorepo Foundation).** This lot ships the
> engineering substrate only: workspace, conventions, boundaries, build system,
> shared configuration, dev infrastructure. **There is no business logic and no
> application yet — by design.**

## Stack

pnpm · Turborepo · TypeScript (strict) · NestJS · Prisma · PostgreSQL · Redis ·
RabbitMQ · OpenSearch · MinIO · OpenTelemetry · Docker · GitHub Actions.

## Layout

```
platform/
├── apps/            deployable units (services, workers…) — empty until 0B
├── packages/        shared libraries (kernel, domains…) — empty until 0B
├── tooling/         engineering config packages (tsconfig, eslint, prettier)
├── infra/           local dev infrastructure (docker compose)
├── docs/            engineering docs (architecture, conventions, ADRs)
├── package.json     workspace root (scripts, dev toolchain)
├── pnpm-workspace.yaml
├── turbo.json       task graph & caching
└── tsconfig.base.json  strict compiler baseline
```

Every folder is explained in
[`docs/engineering/01-architecture.md`](docs/engineering/01-architecture.md).

## Getting started

```bash
corepack enable            # pins pnpm from package.json > packageManager
pnpm install               # install the toolchain (frozen lockfile in CI)
pnpm infra:up              # start Postgres/Redis/RabbitMQ/OpenSearch/MinIO/Jaeger
pnpm verify                # typecheck + lint + test + build (all via Turborepo)
```

> `pnpm install` has not been run in this lot; the lockfile is generated on
> first install. Node **22.11.0** (`.nvmrc`), pnpm **9.12.x** (`packageManager`).

## Commands

| Command | Does |
|---------|------|
| `pnpm build` | build every package in dependency order (cached) |
| `pnpm typecheck` | `tsc --noEmit` across the graph |
| `pnpm lint` | ESLint (correctness + architectural boundaries) |
| `pnpm test` | run the test task across the graph |
| `pnpm format` | Prettier write |
| `pnpm verify` | the full gate: typecheck → lint → test → build |

## Documentation

- [Architecture & repository structure](docs/engineering/01-architecture.md)
- [Conventions (naming, packages, apps, libraries, imports, TS aliases)](docs/engineering/02-conventions.md)
- [Build, versioning & workspace policies](docs/engineering/03-build-versioning-policies.md)
- [Roadmap — Lot 0B and beyond](docs/engineering/04-roadmap.md)
- [ADR 0001 — Monorepo foundation & tooling](docs/adr/0001-monorepo-foundation.md)

## The one rule that governs everything here

**Code implements the Foundation; it never legislates.** When code and Foundation
disagree, the Foundation is right and the code is a defect (mirrors PG-3). Any
change to a law goes through the Foundation's Titre VII, never through a commit
in this repo.
