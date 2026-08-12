# 05 — Testing Strategy (the Testing Foundation)

## 1. Principles

1. **Deterministic by construction.** Time comes from `FakeClock`, ids from
   seeded generators, data from `RandomFactory(seed)`. An unseeded
   `Math.random()` or ambient `Date.now()` in a test is a defect (F4.1 A-6).
2. **Fast and isolated.** Pure `node` environment, per-file isolation, thread
   pool, no retries — a flaky test fails loudly instead of being papered over.
3. **CI-identical.** CI runs the same `pnpm verify` as a laptop; CI adds
   `--coverage` and reporters via flags, never different semantics.
4. **The pyramid is enforced by cost.** Unit tests (Vitest, everything below the
   ports) are free; contract tests pin the seams; E2E (Playwright, later) is
   reserved for user-visible flows of real apps.

## 2. The seven packages

| Package | Provides |
|---------|----------|
| `@mentora/testing-config` | `nodeVitestPreset()` / `withNodePreset()` — the one-line Vitest config every package uses |
| `@mentora/testing` | custom matchers (`toBeOkWith`, `toBeNone`…), `defineFixture`/`buildMany`, `RandomFactory`, golden files (`toStableJson`, `compareToGoldenFile`) |
| `@mentora/testing-clock` | `FakeClock` (kernel `Clock` port), `VirtualScheduler` (virtual timers, zero real waiting) |
| `@mentora/testing-id` | `SequentialIdGenerator`, `SeededUuidGenerator`, `ConstantIdGenerator` (kernel `IdGenerator` port) |
| `@mentora/testing-performance` | `measure`/`measureAsync`, `benchmark` (median/p95), `expectUnderMillis`, `withHeapDelta` |
| `@mentora/testing-contracts` | `describeContract`/`verifyShape` + the `clockContract` and `idGeneratorContract` suites |
| `@mentora/testing-architecture` | workspace graph loader + `findDependencyCycles`/`findLayerViolations`/`findForbiddenDependencies`/`findNamingViolations` |

## 3. Coverage strategy

- Provider **V8**, reporters `text-summary` + `lcov`; enabled via the preset's
  `coverage` option or `vitest run --coverage` in CI.
- Coverage measures **src/** minus specs and barrels — the numbers describe
  code, not test scaffolding.
- **No global threshold at Phase 0.** Thresholds are set **per package** when a
  package stabilizes (a blanket number invites gaming). The kernel family is
  expected to sit near 100% naturally; thresholds get ratcheted in CI in a later
  lot, never lowered.

## 4. Architecture testing strategy

Two independent nets enforce the same law (ADR-0003, F4.4 I-1/I-12):

- **Import level** — the ESLint boundaries (libs never import apps, package-name
  imports only, no cycles) fail the build on an illegal *statement*.
- **Package level** — `@mentora/testing-architecture` loads every
  `package.json` and asserts, as tests that run today: no dependency cycles, the
  ring layering (arrow inward), kernel depends on nothing, apps are leaves,
  `@mentora/` naming. A new package that breaks the law fails the suite the
  moment it appears — the workspace *tests its own constitution*.

## 5. Performance testing strategy

- `benchmark()` reports **median and p95** (mean is reported but never asserted
  — one GC pause skews it).
- CI perf assertions use `expectUnderMillis` with **generous budgets** (10–100×
  the local median): the target is catching order-of-magnitude regressions, not
  micro-noise on a shared runner.
- Memory checks (`withHeapDelta`) are indicative — for catching egregious
  retention, not byte accounting.

## 6. Contract testing strategy

A port's promises are written **once** as a `ContractSuite` and executed against
**every** implementation — the in-memory fake in unit tests, the real adapter in
integration (F4.4 I-10). Shipped now: `clockContract`, `idGeneratorContract`.
Every future port (Repository, Bus, Deposit…) ships its contract suite in the
same lot as the port. Backward compatibility: a contract case is never removed
or weakened — like the Foundation's V-2, contract evolution is additive; a
breaking change is a new port.

## 7. Prepared (deliberately not installed yet)

These are **staged**, with their integration points ready, and land with their
first real consumer — installing them now would ship dead weight:

- **Playwright** — arrives with the first app in `apps/`. Planned shape:
  `@mentora/testing-e2e` package owning `playwright.config.ts` (projects per
  app, trace-on-first-retry, HTML report in CI), `apps/<name>/e2e/` for specs.
  No app exists, so no E2E layer exists yet.
- **Testing Library** — arrives with the first UI surface (not part of the
  backend platform today).
- **Mock Service Worker (MSW)** — arrives with the first HTTP adapter; will be
  wired via a `setupFiles` entry in `withNodePreset({ setupFiles: [...] })`.
- **Mutation testing (Stryker)** — evaluated once the kernel family is stable;
  will run nightly (not per-PR) against `packages/kernel` + `shared` first.
- **Vitest browser mode** — the preset already isolates environment choice;
  a `browserVitestPreset` will join `nodeVitestPreset` when a browser target
  exists.

## 8. Writing a test in a new package (the whole recipe)

```jsonc
// package.json → devDependencies
{ "@mentora/testing-config": "workspace:*", "@mentora/testing": "workspace:*", "vitest": "catalog:" }
```

```ts
// vitest.config.ts
import { nodeVitestPreset } from '@mentora/testing-config';
export default nodeVitestPreset();
```

```ts
// src/thing.spec.ts
import { registerMentoraMatchers } from '@mentora/testing';
import { beforeAll, describe, expect, it } from 'vitest';
beforeAll(() => registerMentoraMatchers());

describe('thing', () => {
  it('works', () => {
    expect(ok(42)).toBeOkWith(42);
  });
});
```

That is the entire setup. `pnpm test` is green from the first minute.
