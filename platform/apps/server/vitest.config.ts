import { nodeVitestPreset } from '@mentora/testing-config';
import { mergeConfig } from 'vitest/config';


// src/main.ts is the pure process wire (see its doc): zero logic, excluded
// from coverage exactly the way the preset excludes barrel index.ts files.
export default mergeConfig(nodeVitestPreset(), {
  test: { coverage: { exclude: ['src/main.ts'] } },
});
