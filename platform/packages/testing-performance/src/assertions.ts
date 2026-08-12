import { InvariantViolationError } from '@mentora/kernel';

import { measure } from './timer.js';

/**
 * Assert `fn` completes within `budgetMillis`. Use GENEROUS budgets in CI
 * (10-100x the local median): the goal is catching order-of-magnitude
 * regressions, not micro-variations on a noisy runner.
 */
export const expectUnderMillis = <T>(budgetMillis: number, fn: () => T): T => {
  const { value, elapsedMillis } = measure(fn);
  if (elapsedMillis > budgetMillis) {
    throw new InvariantViolationError(
      `expected execution under ${String(budgetMillis)}ms, took ${elapsedMillis.toFixed(2)}ms`,
    );
  }
  return value;
};

/** Current V8 heap usage, in bytes. */
export const heapUsedBytes = (): number => process.memoryUsage().heapUsed;

export interface HeapDelta<T> {
  readonly value: T;
  readonly heapDeltaBytes: number;
}

/**
 * Run `fn` and report the heap growth around it. Indicative, not exact (GC may
 * or may not run) — useful for catching egregious accidental retention, not for
 * byte-precise accounting.
 */
export const withHeapDelta = <T>(fn: () => T): HeapDelta<T> => {
  const before = heapUsedBytes();
  const value = fn();
  const after = heapUsedBytes();
  return { value, heapDeltaBytes: after - before };
};
