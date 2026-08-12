import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { FakeClock } from './fake-clock.js';
import { VirtualScheduler } from './virtual-scheduler.js';

describe('FakeClock', () => {
  it('is frozen until advanced', () => {
    const clock = FakeClock.atEpoch();
    expect(clock.now().epochMillis).toBe(0);
    expect(clock.now().epochMillis).toBe(0);
    clock.advanceMillis(1_500);
    expect(clock.now().epochMillis).toBe(1_500);
  });

  it('never rewinds', () => {
    const clock = FakeClock.at(instantOf(10_000));
    expect(() => {
      clock.advanceMillis(-1);
    }).toThrow();
    expect(() => {
      clock.setTo(instantOf(9_999));
    }).toThrow();
  });
});

describe('VirtualScheduler', () => {
  it('fires tasks in due order, with the clock at each due time', () => {
    const clock = FakeClock.atEpoch();
    const scheduler = new VirtualScheduler(clock);
    const seen: Array<[string, number]> = [];
    scheduler.schedule(2_000, () => seen.push(['b', clock.now().epochMillis]));
    scheduler.schedule(1_000, () => seen.push(['a', clock.now().epochMillis]));
    scheduler.advanceMillis(3_000);
    expect(seen).toEqual([
      ['a', 1_000],
      ['b', 2_000],
    ]);
    expect(clock.now().epochMillis).toBe(3_000);
  });

  it('does not fire tasks beyond the advanced window', () => {
    const clock = FakeClock.atEpoch();
    const scheduler = new VirtualScheduler(clock);
    const seen: string[] = [];
    scheduler.schedule(5_000, () => seen.push('late'));
    scheduler.advanceMillis(1_000);
    expect(seen).toEqual([]);
    expect(scheduler.pendingCount()).toBe(1);
  });

  it('supports cancel and runAll, including tasks scheduled by tasks', () => {
    const clock = FakeClock.atEpoch();
    const scheduler = new VirtualScheduler(clock);
    const seen: string[] = [];
    const id = scheduler.schedule(100, () => seen.push('cancelled'));
    scheduler.schedule(200, () => {
      seen.push('outer');
      scheduler.schedule(50, () => seen.push('inner'));
    });
    expect(scheduler.cancel(id)).toBe(true);
    scheduler.runAll();
    expect(seen).toEqual(['outer', 'inner']);
    expect(scheduler.pendingCount()).toBe(0);
  });
});
