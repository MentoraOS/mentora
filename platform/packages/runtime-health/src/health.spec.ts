import { describe, expect, it } from 'vitest';

import type { HealthCheck } from './health.js';
import { CompositeHealthCheck, HealthRegistry, healthy, unhealthy } from './health.js';

const checkOf = (
  name: string,
  kind: HealthCheck['kind'],
  outcome: 'ok' | 'ko' | 'throws',
): HealthCheck => ({
  name,
  kind,
  check: () => {
    if (outcome === 'throws') {
      return Promise.reject(new Error('well unreachable'));
    }
    return Promise.resolve(outcome === 'ok' ? healthy() : unhealthy('declared reason'));
  },
});

describe('HealthRegistry (closed declared list; fail closed verdicts)', () => {
  it('reports healthy only when EVERY check of the probe is healthy', async () => {
    const registry = new HealthRegistry();
    registry.register(checkOf('sequences', 'readiness', 'ok'));
    registry.register(checkOf('relays', 'readiness', 'ok'));
    registry.register(checkOf('process', 'liveness', 'ok'));
    const report = await registry.report('readiness');
    expect(report.overall.kind).toBe('healthy');
    expect(report.entries).toHaveLength(2);
  });

  it('one unhealthy entry makes the whole probe unhealthy', async () => {
    const registry = new HealthRegistry();
    registry.register(checkOf('sequences', 'readiness', 'ok'));
    registry.register(checkOf('scheduler', 'readiness', 'ko'));
    const report = await registry.report('readiness');
    expect(report.overall).toEqual({ kind: 'unhealthy', reason: 'scheduler' });
  });

  it('a throwing check is a described Failure, never a silent pass (R-10)', async () => {
    const registry = new HealthRegistry();
    registry.register(checkOf('store', 'liveness', 'throws'));
    const report = await registry.report('liveness');
    expect(report.overall.kind).toBe('unhealthy');
    expect(report.entries[0]?.status).toEqual({ kind: 'unhealthy', reason: 'well unreachable' });
  });

  it('probes are separated by kind — readiness never reads liveness checks', async () => {
    const registry = new HealthRegistry();
    registry.register(checkOf('process', 'liveness', 'ko'));
    const report = await registry.report('readiness');
    expect(report.overall.kind).toBe('healthy');
    expect(report.entries).toHaveLength(0);
  });

  it('two checks under one name refuse at assembly', () => {
    const registry = new HealthRegistry();
    registry.register(checkOf('sequences', 'readiness', 'ok'));
    expect(() => registry.register(checkOf('sequences', 'liveness', 'ok'))).toThrow();
  });
});

describe('CompositeHealthCheck', () => {
  it('aggregates member reasons, fail closed', async () => {
    const composite = new CompositeHealthCheck('startup', 'startup', [
      checkOf('config', 'startup', 'ok'),
      checkOf('tables', 'startup', 'ko'),
      checkOf('artifact', 'startup', 'throws'),
    ]);
    const status = await composite.check();
    expect(status).toEqual({
      kind: 'unhealthy',
      reason: 'tables: declared reason · artifact: well unreachable',
    });
  });

  it('is healthy when every member is', async () => {
    const composite = new CompositeHealthCheck('startup', 'startup', [
      checkOf('config', 'startup', 'ok'),
    ]);
    expect((await composite.check()).kind).toBe('healthy');
  });
});

describe('remaining doors', () => {
  it('checks() without a kind returns the whole closed list', () => {
    const registry = new HealthRegistry();
    registry.register(checkOf('a', 'readiness', 'ok'));
    registry.register(checkOf('b', 'liveness', 'ok'));
    expect(registry.checks()).toHaveLength(2);
  });

  it('several unhealthy entries join their names in the overall reason', async () => {
    const registry = new HealthRegistry();
    registry.register(checkOf('a', 'startup', 'ko'));
    registry.register(checkOf('b', 'startup', 'ko'));
    const report = await registry.report('startup');
    expect(report.overall).toEqual({ kind: 'unhealthy', reason: 'a · b' });
  });
});
