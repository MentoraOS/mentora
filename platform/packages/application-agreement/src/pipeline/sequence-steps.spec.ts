import { describe, expect, it } from 'vitest';

import { SEQUENCE_STEPS, sequenceStepIndex } from './sequence-steps.js';

describe('the frozen Séquence (A-2: ten steps, this order, no other)', () => {
  it('has exactly ten steps', () => {
    expect(SEQUENCE_STEPS).toHaveLength(10);
  });

  it('Loading PRECEDES SourceValidities (the F4.1.99 corrected order)', () => {
    expect(sequenceStepIndex('Loading')).toBeLessThan(sequenceStepIndex('SourceValidities'));
  });

  it('the injections precede the loading; the act precedes retention (A-2)', () => {
    expect(sequenceStepIndex('IdentityInjection')).toBeLessThan(sequenceStepIndex('Loading'));
    expect(sequenceStepIndex('TimeInjection')).toBeLessThan(sequenceStepIndex('Loading'));
    expect(sequenceStepIndex('Act')).toBeLessThan(sequenceStepIndex('AtomicRetention'));
  });

  it('publication reads retention — never the inverse, never before (A-4)', () => {
    expect(sequenceStepIndex('AtomicRetention')).toBeLessThan(sequenceStepIndex('Publication'));
  });

  it('no ProjectionStage and no AuthorizationStage exist (R2 wins over the mandate)', () => {
    const steps: readonly string[] = SEQUENCE_STEPS;
    expect(steps).not.toContain('Projection');
    expect(steps).not.toContain('ProjectionStage');
    expect(steps).not.toContain('Authorization');
    expect(steps).not.toContain('AuthorizationStage');
  });
});
