import { describe, expect, it } from 'vitest';

import { CLOCK, CONFIG, ID_GENERATOR, LOGGER } from './platform-tokens.js';
import { createToken } from './token.js';

describe('token', () => {
  it('createToken produces a unique key and keeps its description', () => {
    const a = createToken<number>('a');
    const b = createToken<number>('a');
    expect(a.description).toBe('a');
    expect(a.key).not.toBe(b.key); // same description, distinct identity
  });

  it('platform tokens are distinct and described', () => {
    const keys = new Set([CLOCK.key, ID_GENERATOR.key, LOGGER.key, CONFIG.key]);
    expect(keys.size).toBe(4);
    expect(CLOCK.description).toBe('mentora.kernel.Clock');
    expect(LOGGER.description).toBe('mentora.shared.Logger');
  });
});
