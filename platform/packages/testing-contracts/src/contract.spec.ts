import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { describeContract, verifyShape } from './contract.js';
import { clockContract } from './suites/clock-contract.js';
import { idGeneratorContract } from './suites/id-generator-contract.js';

// In-package minimal fakes (this package cannot depend on testing-clock/-id:
// they are siblings, and a contract package must not import its future
// verification subjects — consumers run the suites against their own impls).
const fixedClock = (epochMillis: number) => ({ now: () => instantOf(epochMillis) });

const sequentialGen = () => {
  let n = 0;
  return {
    generate: () => {
      n += 1;
      return `t-${String(n)}`;
    },
  };
};

describe('verifyShape', () => {
  it('accepts a conforming object and rejects a drifting one', () => {
    expect(verifyShape(fixedClock(0), { now: 'function' })).toEqual([]);
    expect(verifyShape({}, { now: 'function' })).toEqual([
      'expected .now to be a function, got undefined',
    ]);
    expect(verifyShape(null, { now: 'function' })).toHaveLength(1);
  });
});

// The suites registered against compliant subjects — these run as real tests.
describeContract(clockContract, () => fixedClock(1_000));
describeContract(idGeneratorContract, sequentialGen);
