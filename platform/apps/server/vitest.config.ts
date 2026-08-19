import { nodeVitestPreset } from '@mentora/testing-config';
import { mergeConfig } from 'vitest/config';


// src/main.ts is the pure process wire (see its doc): zero logic, excluded
// from coverage exactly the way the preset excludes barrel index.ts files.
// Two spec files (server, gateway) boot against the SAME physical test
// databases and truncate the same tables: files must run one at a time.
export default mergeConfig(nodeVitestPreset(), {
  test: {
    fileParallelism: false,
    testTimeout: 30_000,
    hookTimeout: 30_000,
    coverage: { exclude: ['src/main.ts'] },
  },
});
