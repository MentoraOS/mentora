# 03 — Build, Versioning & Workspace Policies

## 1. Build pipeline (Turborepo)

Turborepo orchestrates tasks across the dependency graph with content-addressed
caching. The task graph is declared in `turbo.json`:

| Task | `dependsOn` | Meaning |
|------|-------------|---------|
| `build` | `^build` | build all my dependencies first, then me |
| `typecheck` | `^build` | needs upstream `.d.ts` present |
| `lint` | `^build` | type-aware rules need built types |
| `test` | `^build` | tests run against built deps |

- **`^` means "dependencies of".** `build: { dependsOn: ["^build"] }` gives the
  correct topological order for free — the same "dependency points to the
  center" discipline, executed.
- **Inputs/outputs are declared** so caching is correct: change a `src/**` file
  and only the affected packages (and their dependents) rebuild. Everything else
  is a cache hit.
- **`pnpm verify`** runs the whole gate — `typecheck → lint → test → build` —
  and is the single command CI and pre-merge both call.

*Why Turborepo over Nx:* Turborepo is task-runner-only, unopinionated about
framework and code generation, with near-zero config. Nx is more powerful
(generators, module boundaries, graph analytics) but heavier and more
prescriptive. For a foundation that must stay legible for a decade, we prefer
the smaller, less magical tool and encode boundaries in ESLint (portable) rather
than a proprietary graph. Revisit if generator ergonomics become a bottleneck.

## 2. Compilation

- Each package builds with `tsc` against its preset (`@mentora/tsconfig/library`
  or `/nestjs`). Libraries are `composite` and emit declarations + maps.
- **No bundler at the library layer.** Libraries ship `dist/` ESM + `.d.ts`;
  bundling is an *app* concern (an app may use its framework's builder). This
  keeps libraries debuggable and their public types authoritative.
- **Two tsconfigs per package** — a deliberate, standard split:
  - `tsconfig.json` — the IDE / ESLint / `typecheck` project. Includes `src/**`
    **and tests**, so the type-aware linter and `pnpm typecheck` cover specs.
    Emits nothing (`noEmit`).
  - `tsconfig.build.json` — the emit project (`composite`, source only, tests
    excluded). It is the TypeScript **project-reference** target and what
    `pnpm build` runs (`tsc -b tsconfig.build.json`). Its `references` list the
    build projects of its dependencies, so `tsc -b` compiles the graph in order.

  Why split: path-bearing options and file globs cannot live in a shared base
  (relative paths in an extended config resolve to the *base's* directory), and
  the linter needs tests in a project while the shipped `dist/` must not contain
  them. One config cannot satisfy both; two do, cleanly.

## 3. Versioning

- **Internal packages are unversioned** (`0.0.0`, `private: true`) and linked by
  `workspace:*`. There is no semver churn for code that never leaves the repo —
  the monorepo *is* the atomic unit of change.
- **If/when a package is published externally**, it adopts semver and is released
  through Changesets (added in a later lot). Not needed at 0A.
- **The Foundation's version is not the platform's version.** `foundation-v1.0.0`
  versions the *laws*; a platform release versions the *code*. A new code release
  never implies a new Foundation (the R2 rule N°59, honored here). Only Titre VII
  changes a law.
- **Contract evolution follows the Foundation's V-laws (F4.3):** event/command
  types evolve additively; a rename or removal is a new contract, not a version
  bump (V-3).

## 4. Workspace policies

- **Frozen lockfile in CI** (`pnpm install --frozen-lockfile`): the committed
  `pnpm-lock.yaml` is the single source of truth; drift fails the build.
- **No phantom dependencies** (`.npmrc hoist=false`): a package may import only
  what it declares. This is the supply-chain analogue of the Foundation's "one
  truth, one owner."
- **Exact versions** (`save-exact=true`) + a shared **version catalog** in
  `pnpm-workspace.yaml`: shared deps are pinned in one place, upgraded in one
  place.
- **Engine-strict**: the declared Node/pnpm range is enforced, not suggested.
- **Lifecycle-script allowlist**: dependency `postinstall` scripts are denied by
  default (supply-chain defense, aligned with F5.4's chain of proof); each
  exception is added deliberately with review.
- **Prettier owns style; ESLint owns correctness.** They never overlap
  (`eslint-config-prettier` applied last).

## 5. CI (GitHub Actions — shape, wired in a later lot)

The pipeline is: `setup (corepack + pnpm + cache) → install --frozen-lockfile →
pnpm verify`. Turborepo remote cache makes CI incremental. A change to a leaf
package rebuilds/tests only that package and its dependents. The boundary rules
run as part of `lint`, so an illegal import fails CI, not review.

## 6. Definition of "green"

A change is mergeable only when `pnpm verify` is green: types check, boundaries
hold, tests pass, everything builds — the code-level echo of the Foundation's
"fail closed" (P17).
