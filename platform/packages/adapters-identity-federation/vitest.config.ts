import { nodeVitestPreset } from '@mentora/testing-config';
import { mergeConfig } from 'vitest/config';

// Pure protocol adapters — no database, no network in specs (providers are
// SIMULATED via the injectable fetch seam; ADR-0004: never the real ones
// in CI).
export default mergeConfig(nodeVitestPreset(), {
  test: {
    coverage: { exclude: ['dist/**', '*.mjs', 'vitest.config.ts'] },
  },
});
