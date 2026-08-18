import { describe, expect, it } from 'vitest';

import { CREDENTIAL_REFUSAL_REASONS } from './refusals.js';

describe('contracts-identity — the published language embryo', () => {
  it('exposes the closed refusal-reason list (the R-A reason is a recorded canon gap, absent on purpose)', () => {
    expect(CREDENTIAL_REFUSAL_REASONS).toEqual(['TransitionUnavailable']);
  });
});
