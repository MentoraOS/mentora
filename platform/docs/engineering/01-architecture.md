# 01 — Technical Architecture of the Monorepo

## 1. Vision

The Mentora platform is the running-code **projection** of a Constitution that is
already complete and frozen (`docs/canon/`, `foundation-v1.0.0`). The monorepo's
job is therefore narrow and durable: give every part of that Constitution a
single, well-bounded home in code, and make the boundaries between those homes
**mechanically enforced** rather than merely documented.

Three properties drive every decision in Lot 0A:

1. **Longevity over speed.** This foundation must carry Mentora for ~10 years,
   hundreds of packages, dozens of apps, several teams. We optimize for the cost
   of the 500th package, not the 1st.
2. **The dependency graph is the architecture.** In a monorepo, architecture
   *is* who-may-import-whom. We make that graph explicit, acyclic, and
   linter-enforced (mirroring the Foundation's F4.4 I-1/I-12).
3. **The compiler carries the contracts.** Strictest-safe TypeScript so that
   invariants are caught at build time, not in production — the code analogue of
   F1 §4.

## 2. Why a self-contained `platform/` directory

The repository root is the existing **Flutter client** (Dart, `lib/`, `pubspec`,
`android/ios/web`). The R3 stack is a Node/TypeScript backend. Mixing a pnpm
workspace into a Flutter app root would entangle two unrelated toolchains
(`.gitignore`, formatters, CI). So the entire Node platform lives under
`platform/`, fully self-contained:

- **Isolation** — Flutter tooling and Node tooling never collide.
- **Portability** — because nothing reaches outside `platform/`, the directory
  can be lifted into its own git repository later with zero code changes. This
  is deliberate: it keeps the "one repo vs. many repos" decision reversible.

*Alternative considered:* root-level monorepo containing both Flutter and Node.
Rejected — Turborepo/pnpm do not manage Dart packages, so the Flutter app would
be a foreign body in the workspace, and the two `.gitignore`/format regimes
would fight.

## 3. Repository structure (complete tree)

```
platform/
├── .editorconfig            editor defaults (LF, 2-space, final newline)
├── .gitignore               node/turbo ignores (scoped to platform/)
├── .npmrc                   pnpm policy: no hoist, strict peers, frozen lockfile
├── .nvmrc                   Node 22.23.2 (LTS Jod — baseline corrigée par le smoke CI R5)
├── package.json             workspace root: scripts + dev toolchain only
├── pnpm-workspace.yaml       workspace globs + shared version catalog
├── turbo.json               task graph, inputs/outputs, caching
├── tsconfig.base.json        the strict compiler baseline
├── tsconfig.json            root solution file (owns no sources)
├── README.md                workspace entrypoint
│
├── apps/                    DEPLOYABLE UNITS — leaves of the graph (empty at 0A)
│   └── README.md            the six executable species (F5.1) + conventions
│
├── packages/               SHARED LIBRARIES — interior of the graph (empty at 0A)
│   └── README.md            the ring model (kernel→shared→contracts→domain→…)
│
├── tooling/                ENGINEERING CONFIG PACKAGES (real, shipped at 0A)
│   ├── tsconfig/            @mentora/tsconfig — base/library/nestjs presets
│   ├── eslint-config/       @mentora/eslint-config — correctness + boundaries
│   └── prettier-config/     @mentora/prettier-config — one formatter
│
├── infra/                  LOCAL DEV INFRASTRUCTURE (mechanisms, not domains)
│   ├── docker-compose.dev.yml   postgres/redis/rabbitmq/opensearch/minio/jaeger
│   └── README.md
│
└── docs/
    ├── engineering/        this documentation set
    └── adr/                architecture decision records
```

## 4. Folder-by-folder

- **`apps/`** — every deployable. An app is a **leaf**: nothing imports it. Apps
  map one-to-one onto the Foundation's six executable species (F5.1 §3):
  Application, Relay, Scheduler, Worker, Migration, Maintenance. No seventh kind
  is ever invented. *Empty at 0A.*
- **`packages/`** — every importable library, organized in concentric rings
  (kernel → shared → contracts → domain → application → infrastructure). The
  dependency arrow always points inward, exactly F4.4 I-1. *Empty of business
  logic at 0A.*
- **`tooling/`** — configuration-as-packages. Shared tsconfig, eslint, prettier.
  These are pure engineering (no domain concepts) and therefore legitimately
  shipped now; they are what make the conventions executable.
- **`infra/`** — the local backing services. Interchangeable mechanisms owned by
  operations, never holding a business truth (the F5 stance made concrete).
- **`docs/`** — engineering documentation and ADRs. (The *constitutional*
  documentation is elsewhere and frozen: `docs/canon/` at the repo root.)

## 5. The dependency graph (the load-bearing decision)

```
                 apps/*  (leaves — deployables)
                    │  may import ▼, never ▲
   ┌────────────────┼───────────────────────────┐
   │            packages/* (rings, arrow points inward)
   │   infrastructure → application → domain → contracts → shared → kernel
   └────────────────┬───────────────────────────┘
                    │ everything may import ▼
                 tooling/*  (config only; imported at build time)
```

Rules (enforced by `@mentora/eslint-config/boundaries` + `import-x/no-cycle`):

1. **Apps are leaves.** A library importing an app is an error.
2. **Arrow points inward.** A ring imports rings inside it, never outside.
3. **No cycles.** `import-x/no-cycle` fails the build on any dependency cycle
   (F4.4 I-12: the graph is acyclic by construction).
4. **Cross-package imports go through the package name**, never a deep relative
   path into another package's `src/`.

Turborepo reads the real dependency edges from each `package.json` and
schedules `build`/`typecheck`/`lint`/`test` in topological order with caching
(`^build` = "build my dependencies first").

## 6. What Lot 0A deliberately does NOT contain

No Aggregate, Event, Command, Query, Policy, Repository, Process Manager,
Adapter, or API. Creating any of these would be creating law, which lives only
in the frozen Foundation. Lot 0A ships the **substrate**; Lot 0B begins placing
the Foundation's contents into it (see `04-roadmap.md`).
