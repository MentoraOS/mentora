import { describe, expect, it } from 'vitest';

import { expectUnderMillis, withHeapDelta } from './assertions.js';
import { benchmark } from './benchmark.js';
import { measure, measureAsync } from './timer.js';

describe('timer', () => {
  it('measure returns the value and a non-negative elapsed time', () => {
    const m = measure(() => 21 * 2);
    expect(m.value).toBe(42);
    expect(m.elapsedMillis).toBeGreaterThanOrEqual(0);
  });

  it('measureAsync times awaited work', async () => {
    const m = await measureAsync(() => Promise.resolve('done'));
    expect(m.value).toBe('done');
    expect(m.elapsedMillis).toBeGreaterThanOrEqual(0);
  });
});

describe('benchmark', () => {
  it('reports coherent robust statistics', () => {
    const result = benchmark('sum-1k', () => {
      let acc = 0;
      for (let i = 0; i < 1_000; i += 1) {
        acc += i;
      }
      return acc;
    });
    expect(result.iterations).toBe(100);
    expect(result.minMillis).toBeLessThanOrEqual(result.medianMillis);
    expect(result.medianMillis).toBeLessThanOrEqual(result.p95Millis);
    expect(result.p95Millis).toBeLessThanOrEqual(result.maxMillis);
  });
});

describe('assertions', () => {
  it('expectUnderMillis passes generous budgets and returns the value', () => {
    expect(expectUnderMillis(5_000, () => 'fast')).toBe('fast');
  });

  it('expectUnderMillis throws when the budget is blown', () => {
    expect(() =>
      expectUnderMillis(0, () => {
        const until = performance.now() + 5;
        while (performance.now() < until) {
          // spin ~5ms
        }
      }),
    ).toThrow(/expected execution under/);
  });

  it('withHeapDelta reports a number and the value', () => {
    const { value, heapDeltaBytes } = withHeapDelta(() => new Array(1_000).fill(1).length);
    expect(value).toBe(1_000);
    expect(typeof heapDeltaBytes).toBe('number');
  });
});
