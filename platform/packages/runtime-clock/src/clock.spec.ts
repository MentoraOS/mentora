import { describe, expect, it } from 'vitest';

import { clockFactory } from './clock-factory.js';
import { MonotonicClock } from './monotonic-clock.js';
import { SystemClock } from './system-clock.js';

describe('SystemClock (the one lawful ambient read — A-6)', () => {
  it('yields the machine instant as an Instant value', () => {
    const before = Date.now();
    const instant = new SystemClock().now();
    const after = Date.now();
    expect(instant.epochMillis).toBeGreaterThanOrEqual(before);
    expect(instant.epochMillis).toBeLessThanOrEqual(after);
  });
});

describe('MonotonicClock (technical durations only)', () => {
  it('never decreases', () => {
    const clock = new MonotonicClock();
    const first = clock.elapsedMillis();
    const second = clock.elapsedMillis();
    expect(first).toBeGreaterThanOrEqual(0);
    expect(second).toBeGreaterThanOrEqual(first);
  });
});

describe('clockFactory', () => {
  it('builds both species', () => {
    expect(clockFactory.system()).toBeInstanceOf(SystemClock);
    expect(clockFactory.monotonic()).toBeInstanceOf(MonotonicClock);
  });
});
