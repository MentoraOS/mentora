import { instantOf } from '@mentora/kernel';
import { FakeClock } from '@mentora/testing-clock';
import { describe, expect, it } from 'vitest';

import { createMetricsRegistry, MemoryMetricsSink } from './metrics-registry.js';

const T0 = instantOf(10_000);

describe('MetricsRegistry (closed, readable, deterministic)', () => {
  it('same identity (name + labels) yields the same instrument', () => {
    const registry = createMetricsRegistry(FakeClock.at(T0));
    registry.counter('boot.attempts', { species: 'relay' }).increment();
    registry.counter('boot.attempts', { species: 'relay' }).increment(2);
    registry.counter('boot.attempts', { species: 'worker' }).increment();
    const snapshot = registry.snapshot();
    expect(snapshot.counters).toEqual({
      'boot.attempts{species=relay}': 3,
      'boot.attempts{species=worker}': 1,
    });
  });

  it('label order never changes the identity and the snapshot is sorted', () => {
    const registry = createMetricsRegistry(FakeClock.at(T0));
    registry.gauge('pool.size', { b: '2', a: '1' }).set(8);
    registry.gauge('pool.size', { a: '1', b: '2' }).set(9);
    expect(registry.snapshot().gauges).toEqual({ 'pool.size{a=1,b=2}': 9 });
  });

  it('histograms summarize count, sum, min, max — empty stays zeroed', () => {
    const registry = createMetricsRegistry(FakeClock.at(T0));
    const histogram = registry.histogram('drain.millis');
    expect(histogram.summary()).toEqual({ count: 0, sum: 0, min: 0, max: 0 });
    histogram.observe(5);
    histogram.observe(15);
    expect(histogram.summary()).toEqual({ count: 2, sum: 20, min: 5, max: 15 });
  });

  it('the Timer measures over the INJECTED clock — deterministic (A-6)', () => {
    const clock = FakeClock.at(T0);
    const registry = createMetricsRegistry(clock);
    const stop = registry.timer('sequence.millis').start();
    clock.advanceMillis(250);
    stop();
    expect(registry.snapshot().histograms['sequence.millis']).toEqual({
      count: 1,
      sum: 250,
      min: 250,
      max: 250,
    });
  });

  it('a blank metric name is refused (a name is an operations word)', () => {
    const registry = createMetricsRegistry(FakeClock.at(T0));
    expect(() => registry.counter('  ')).toThrow();
  });

  it('the sink receives whole snapshots', () => {
    const registry = createMetricsRegistry(FakeClock.at(T0));
    registry.counter('probe').increment();
    const sink = new MemoryMetricsSink();
    sink.deliver(registry.snapshot());
    expect(sink.deliveries).toHaveLength(1);
    expect(sink.deliveries[0]?.counters['probe']).toBe(1);
  });
});
