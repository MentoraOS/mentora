# apps/

**Deployable units.** Everything in `apps/*` is a thing you can build into a
container and run: a NestJS HTTP service, a worker, a scheduler, a migration
runner. Nothing here is imported by another package — apps are **leaves** of
the dependency graph (F4.4 I-1: dependency points to the center, and an app is
the outermost ring).

> **Empty at Lot 0A — by design.** This lot ships the engineering substrate
> only. No application, no API, no business logic exists yet. Applications
> arrive in Lot 0B onward.

## The six executable species (from F5.1 §3)

The Foundation already named the only kinds of executable that may exist. Apps
map onto them one-to-one; no seventh kind is ever invented:

| Species (F5.1) | `apps/*` naming | Role |
|----------------|-----------------|------|
| Application | `app-<surface>` | serves the three Séquences to people |
| Relay | `relay-<name>` | carries Outbox of facts/commands to the bus |
| Scheduler | `scheduler` | the Échéancier |
| Worker | `worker-<name>` | Réactions & Séquences off the human path |
| Migration | `migrator` | expand-contract, under change-control |
| Maintenance | `maintenance-<name>` | police & reprises |

## Conventions (see `docs/engineering/02-conventions.md`)

- Package name: `@mentora/app-<name>` (or `@mentora/<species>-<name>`), `private: true`, unversioned.
- Extends `@mentora/tsconfig/nestjs`.
- Depends **only downward** — on `packages/*` and `tooling/*`, never on another app.
- Owns its own `Dockerfile`, `src/main.ts` bootstrap, and deployment manifest.
