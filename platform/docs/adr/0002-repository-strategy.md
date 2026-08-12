# ADR 0002 — Repository Strategy

- **Status:** Accepted (R3 Phase 0, Lot 0B)
- **Deciders:** Principal Engineer, under the authority of the frozen Foundation
- **Context version:** `foundation-v1.0.0` (`8d095ee`)
- **Supersedes:** refines D1 of ADR 0001

## Context

The Mentora repository already contains a **Flutter client** at its root (Dart:
`lib/`, `pubspec.yaml`, `android/`, `ios/`, `web/`, `windows/`) plus the frozen
constitutional corpus at `docs/canon/`. R3 introduces a **Node/TypeScript
backend**. We must decide, officially and durably, where that backend lives and
why. This is an engineering decision only — it creates no law and no domain
concept.

## Decision

**The Flutter client stays at the repository root. The entire backend lives in a
single, self-contained `platform/` directory.** The two are siblings in one git
repository but are otherwise independent: neither imports the other, and each
owns its own toolchain, ignore rules, and formatter.

```
mentora/                     (git root)
├── lib/ · android/ · ios/ · web/ · pubspec.yaml   ← Flutter client (Dart)
├── docs/canon/                                     ← frozen Constitution (R2)
└── platform/                                       ← backend monorepo (this ADR)
    ├── apps/ · packages/ · tooling/ · infra/ · docs/
    └── package.json · pnpm-workspace.yaml · turbo.json · tsconfig.base.json
```

## Why the Flutter client stays at the root

1. **It is already there, and it works.** Moving a live Flutter app disturbs
   IDE projects (`.idea`, `mentora.iml`), platform folders, Firebase config, and
   CI. Churn without benefit violates the Foundation's own reduction rule (F1
   §2: *"aucune réduction reportée"* is about doing needed reductions early —
   the converse is not inventing unneeded ones).
2. **Root is the natural home of a mobile/web app.** Flutter tooling
   (`flutter run`, Gradle, Xcode, `pub`) expects the app at a project root; it is
   not designed to be a nested package.
3. **The client is one consumer of the platform, not part of it.** In DDD terms
   it is a *surface* (F2), downstream of the published contracts — it belongs
   outside the backend's dependency graph by definition.

## Why the backend lives in `/platform`

1. **Toolchain isolation.** pnpm/Turborepo/tsc and Flutter/pub/Gradle have
   different lockfiles, ignore rules, formatters, and CI steps. A shared root
   would force them to coexist in one `.gitignore` and one format regime, which
   fight (`build/` means different things to each; `pubspec.lock` vs
   `pnpm-lock.yaml`; Dart format vs Prettier).
2. **A monorepo needs a clean root of its own.** `pnpm-workspace.yaml`,
   `turbo.json`, and `tsconfig.base.json` are workspace-root artifacts. Putting
   them at the git root would make the git root simultaneously a Flutter app root
   and a pnpm workspace root — two incompatible identities.
3. **One dependency graph, one boundary.** Everything the backend needs lives
   under `platform/`; nothing reaches outside it. That single boundary is what
   makes the graph analyzable and the extraction below trivial.

## Why this separation is preferable

- **Legibility.** Anyone opening the repo sees two obvious, labeled worlds
  instead of an interleaved one.
- **Independent evolution.** The backend can adopt a new Node major, a new
  bundler, or a new CI shape without touching the Flutter app, and vice versa.
- **Blast-radius containment.** A backend tooling change cannot break a Flutter
  build, because they share no configuration.

## How it eases a future extraction

Because `platform/` imports nothing outside itself and owns all its config, it
can become its own git repository with a single `git filter-repo --subdirectory-filter platform`
(or `git subtree split`) — **no code change required**. The `platform/` root is
already a valid standalone monorepo root today. This keeps the strategic
"monorepo vs. polyrepo" question **reversible**: we get the day-one convenience
of one repo, without paying a migration tax if we later split.

## How it avoids pub / pnpm / gradle conflicts

| Concern | Flutter (root) | Backend (`platform/`) |
|---------|----------------|------------------------|
| Manifest | `pubspec.yaml` | `package.json` |
| Lockfile | `pubspec.lock` | `pnpm-lock.yaml` |
| Deps dir | `.dart_tool/`, `build/` | `node_modules/`, `dist/`, `.turbo/` |
| Ignore | root `.gitignore` | `platform/.gitignore` |
| Format | `dart format` | Prettier |
| Build | Gradle / Xcode / `flutter build` | Turborepo / `tsc` |

Each lives under a different directory with a different ignore file, so no tool
ever scans the other's artifacts. Gradle (invoked only under `android/`) never
sees `node_modules`; pnpm (scoped to `platform/`) never sees `.dart_tool`.

## Why this decision is durable

The decision rests on a property that will not change: **Dart and TypeScript are
different ecosystems with different build tools.** As long as that is true —
i.e., for the life of the project — keeping them in separate, self-contained
roots is correct. If Mentora ever unifies on one language, this ADR is revisited;
until then, the separation is stable, and the reversibility clause means we are
never locked in.

## Consequences

- **Positive:** clean isolation; independent evolution; trivial future
  extraction; no cross-toolchain conflicts.
- **Negative / accepted:** a nested monorepo (`platform/` inside a Flutter repo)
  is slightly unusual and requires contributors to know the two roots exist —
  mitigated by this ADR and the root/README pointers.

## Compliance with the Foundation

This ADR records an engineering decision only. It creates no law, no Aggregate,
no Event, no Command, no Policy. The Flutter client remains a *surface* of the
Constitution; the backend a *projection* of it into services. The Source stays
sovereign (PG-2/PG-3).
