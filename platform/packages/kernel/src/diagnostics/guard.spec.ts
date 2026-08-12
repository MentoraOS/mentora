import { describe, expect, it } from 'vitest';

import { GuardError, InvariantViolationError } from './errors.js';
import { guardDefined, invariant, isDefined, isNonEmptyArray } from './guard.js';

describe('guard', () => {
  it('isDefined narrows out null/undefined', () => {
    expect(isDefined(0)).toBe(true);
    expect(isDefined('')).toBe(true);
    expect(isDefined(null)).toBe(false);
    expect(isDefined(undefined)).toBe(false);
  });

  it('invariant throws InvariantViolationError when false', () => {
    expect(() => {
      invariant(false, 'must hold');
    }).toThrow(InvariantViolationError);
    expect(() => {
      invariant(true, 'ok');
    }).not.toThrow();
  });

  it('guardDefined returns the value or throws GuardError', () => {
    expect(guardDefined(42, 'answer')).toBe(42);
    expect(() => guardDefined(null, 'answer')).toThrow(GuardError);
  });

  it('isNonEmptyArray detects non-empty tuples', () => {
    expect(isNonEmptyArray([1])).toBe(true);
    expect(isNonEmptyArray([])).toBe(false);
  });

  it('KernelError carries a stable code', () => {
    expect(new InvariantViolationError('x').code).toBe('KERNEL.INVARIANT_VIOLATION');
    expect(new GuardError('x').code).toBe('KERNEL.GUARD');
  });
});
