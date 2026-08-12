/**
 * @mentora/testing-config — shared Vitest configuration presets.
 *
 * One place that decides how tests run everywhere: fast, deterministic,
 * reproducible, isolated, identical locally and in CI. A package's
 * vitest.config.ts is one line: `export default nodeVitestPreset();`
 */

import { defineConfig, mergeConfig } from 'vitest/config';
import type { UserConfig } from 'vitest/config';

/** Options a package may tweak without forking the preset. */
export interface NodePresetOptions {
  /** Extra setup files, run before each test file. */
  readonly setupFiles?: readonly string[];
  /** Enable coverage collection (CI turns this on via --coverage as well). */
  readonly coverage?: boolean;
}

/**
 * The platform default for Node library tests.
 *
 * - **Deterministic & isolated**: each test file runs in its own isolated
 *   worker; no shared mutable state between files.
 * - **Fast**: thread pool, no environment emulation (pure `node`).
 * - **Reproducible**: no retries (a flaky test must fail, not be papered over),
 *   fake-timer friendly, `passWithNoTests` so a fresh package is green on day 0.
 * - **CI-identical**: nothing here branches on CI; CI adds `--coverage` and
 *   reporters via flags, never different semantics.
 */
export const nodeVitestPreset = (options: NodePresetOptions = {}): UserConfig =>
  defineConfig({
    test: {
      include: ['src/**/*.spec.ts'],
      environment: 'node',
      passWithNoTests: true,
      isolate: true,
      pool: 'threads',
      retry: 0,
      clearMocks: true,
      restoreMocks: true,
      unstubEnvs: true,
      unstubGlobals: true,
      setupFiles: options.setupFiles ? [...options.setupFiles] : [],
      coverage: {
        enabled: options.coverage ?? false,
        provider: 'v8',
        reporter: ['text-summary', 'lcov'],
        include: ['src/**'],
        exclude: ['src/**/*.spec.ts', 'src/index.ts'],
      },
    },
  });

/** Merge a package-specific override onto the node preset. */
export const withNodePreset = (override: UserConfig, options: NodePresetOptions = {}): UserConfig =>
  mergeConfig(nodeVitestPreset(options), override);
