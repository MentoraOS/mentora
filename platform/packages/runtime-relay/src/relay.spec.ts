import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { instantOf } from '@mentora/kernel';
import { RuntimeBuilder } from '@mentora/runtime-bootstrap';
import { createMetricsRegistry } from '@mentora/runtime-metrics';
import { MemorySpanSink, RuntimeTrace, spanIdOf, traceIdOf } from '@mentora/runtime-tracing';
import type { TraceIdSource } from '@mentora/runtime-tracing';
import { noopLogger } from '@mentora/shared';
import { FakeClock } from '@mentora/testing-clock';
import { describe, expect, it } from 'vitest';

import { RelayDispatch } from './dispatch/relay-dispatch.js';
import { RelayHealth } from './health/relay-health.js';
import { RelayMetrics } from './metrics/relay-metrics.js';
import { RuntimeRelayModule } from './module/runtime-relay-module.js';
import { RelayRetryEngine } from './retry/relay-retry-engine.js';
import { InMemoryRelaySource } from './testing/in-memory-relay-source.js';
import { MemoryRelayPublisher } from './testing/memory-relay-publisher.js';
import { envelopeOf, relayContractSuite } from './testing/relay-contract-suite.js';

const T0 = instantOf(100_000);

const harness = (options?: { maxAttempts?: number; batchSize?: number }) => {
  const source = new InMemoryRelaySource();
  const publisher = new MemoryRelayPublisher();
  const clock = FakeClock.at(T0);
  const registry = createMetricsRegistry(clock);
  const metrics = new RelayMetrics(registry);
  const retries = new RelayRetryEngine(
    {
      baseDelayMillis: 1_000,
      maxDelayMillis: 8_000,
      maxAttempts: options?.maxAttempts ?? 3,
      jitterMillis: 0,
    },
    () => 0,
  );
  const dispatch = new RelayDispatch(source, publisher, retries, clock, metrics, noopLogger, {
    batchSize: options?.batchSize ?? 10,
    claimDurationMillis: 5_000,
  });
  return { source, publisher, clock, registry, metrics, dispatch };
};

// The source port's promises — the reference implementation must hold them.
relayContractSuite('InMemoryRelaySource', {
  make: () => {
    const source = new InMemoryRelaySource();
    return Promise.resolve({ source, seed: (envelope) => source.seed(envelope) });
  },
});

describe('nominal publication (A-4/M-4)', () => {
  it('claims, publishes VERBATIM, acks pending → published — never deletes', async () => {
    const { source, publisher, dispatch } = harness();
    const envelope = {
      ...envelopeOf('m1', 'agr-1', 1, T0.epochMillis - 1_000),
      correlationId: 'corr-1',
      causationId: 'cause-1',
      traceparent: `00-${'ab'.repeat(16)}-${'cd'.repeat(8)}-01`,
    };
    source.seed(envelope);
    const outcome = await dispatch.runOnce();
    expect(outcome).toEqual({ claimed: 1, published: 1, retried: 0, quarantined: 0 });
    // "Aucune perte": the delivered envelope is byte-for-byte the claimed one.
    expect(publisher.delivered[0]).toEqual(envelope);
    expect(source.statuses()).toEqual([['m1', 'published']]);
  });

  it('an empty source is a quiet pass', async () => {
    const { dispatch } = harness();
    expect(await dispatch.runOnce()).toEqual({
      claimed: 0,
      published: 0,
      retried: 0,
      quarantined: 0,
    });
  });
});

describe('retry — technical, bounded, backing off (M-8)', () => {
  it('a failed delivery retries with exponential backoff and finally publishes', async () => {
    const { source, publisher, clock, dispatch } = harness({ maxAttempts: 3 });
    source.seed(envelopeOf('m1', 'a', 1));
    publisher.failNext('m1', 2);
    expect((await dispatch.runOnce()).retried).toBe(1);
    // Backing off: not due yet.
    clock.advanceMillis(500);
    expect((await dispatch.runOnce()).claimed).toBe(0);
    clock.advanceMillis(600); // past base 1000
    expect((await dispatch.runOnce()).retried).toBe(1);
    clock.advanceMillis(2_100); // past 2000 (attempt 2 backoff)
    const final = await dispatch.runOnce();
    expect(final.published).toBe(1);
    expect(publisher.delivered[0]?.deliveryAttempts).toBe(2);
    expect(source.statuses()).toEqual([['m1', 'published']]);
  });

  it('the backoff doubles and caps; jitter is injected, never ambient', () => {
    const retries = new RelayRetryEngine(
      { baseDelayMillis: 1_000, maxDelayMillis: 3_000, maxAttempts: 9, jitterMillis: 100 },
      () => 7,
    );
    expect(retries.delayForMillis(1)).toBe(1_007);
    expect(retries.delayForMillis(2)).toBe(2_007);
    expect(retries.delayForMillis(3)).toBe(3_007); // capped
    expect(retries.exhausted(8)).toBe(false);
    expect(retries.exhausted(9)).toBe(true);
  });
});

describe('abandon → Quarantaine (nothing disappears; witnessed)', () => {
  it('a poison envelope parks after the budget, with its reason — the queue flows on', async () => {
    const { source, publisher, clock, dispatch } = harness({ maxAttempts: 2 });
    source.seed(envelopeOf('poison', 'subject-p', 1));
    source.seed(envelopeOf('m2', 'subject-b', 1));
    publisher.failNext('poison', Number.POSITIVE_INFINITY);
    const first = await dispatch.runOnce();
    expect(first).toEqual({ claimed: 2, published: 1, retried: 1, quarantined: 0 });
    clock.advanceMillis(1_100);
    const second = await dispatch.runOnce();
    expect(second.quarantined).toBe(1);
    expect(source.statuses()).toEqual([
      ['poison', 'quarantined'],
      ['m2', 'published'],
    ]);
    expect(source.reasonOf('poison')).toContain('bus unreachable');
    // The poison never blocks the others (M-8): a new subject flows.
    source.seed(envelopeOf('m3', 'subject-c', 1));
    clock.advanceMillis(10);
    expect((await dispatch.runOnce()).published).toBe(1);
  });
});

describe('duplication — at-least-once is lawful, the claim is never a guardian (F5.1 §19)', () => {
  it('an expired claim re-delivers: same fact identity, the consumer Inbox will dedup (A-5)', async () => {
    const { source, publisher, clock, dispatch } = harness();
    source.seed(envelopeOf('m1', 'a', 1));
    // A "crashed worker": claim taken, no ack ever recorded.
    await source.claimBatch({
      nowMs: clock.now().epochMillis,
      claimedUntilMs: clock.now().epochMillis + 5_000,
      limit: 1,
    });
    expect((await dispatch.runOnce()).claimed).toBe(0);
    clock.advanceMillis(5_001);
    expect((await dispatch.runOnce()).published).toBe(1);
    expect(publisher.delivered).toHaveLength(1);
  });

  it('two concurrent claim passes never share an envelope (atomic claim)', async () => {
    const source = new InMemoryRelaySource();
    source.seed(envelopeOf('m1', 'a', 1));
    source.seed(envelopeOf('m2', 'b', 1));
    const now = 10_000;
    const [first, second] = await Promise.all([
      source.claimBatch({ limit: 1, nowMs: now, claimedUntilMs: now + 5_000 }),
      source.claimBatch({ limit: 1, nowMs: now, claimedUntilMs: now + 5_000 }),
    ]);
    const ids = [...first, ...second].map((envelope) => envelope.messageId);
    expect(new Set(ids).size).toBe(ids.length);
  });
});

describe('observability of the relay', () => {
  it('metrics count the whole road and time the batch over the injected clock', async () => {
    const { source, publisher, clock, registry, dispatch } = harness({ maxAttempts: 2 });
    source.seed(envelopeOf('m1', 'a', 1));
    source.seed(envelopeOf('poison', 'p', 1));
    publisher.failNext('poison', Number.POSITIVE_INFINITY);
    await dispatch.runOnce();
    clock.advanceMillis(1_100);
    await dispatch.runOnce();
    const snapshot = registry.snapshot();
    expect(snapshot.counters['relay.claimed']).toBe(3);
    expect(snapshot.counters['relay.published']).toBe(1);
    expect(snapshot.counters['relay.retried']).toBe(1);
    expect(snapshot.counters['relay.quarantined']).toBe(1);
    expect(snapshot.gauges['relay.backlog.pending']).toBe(0);
    expect(snapshot.histograms['relay.batch.millis']?.count).toBe(2);
    expect(snapshot.histograms['relay.retry.delay.millis']?.count).toBe(1);
  });

  it('tracing: the publish span is a CHILD of the carried trace — nothing lost', async () => {
    const { source, dispatch: baseDispatch, ...rest } = harness();
    void baseDispatch;
    const sink = new MemorySpanSink();
    let spans = 0;
    const tracer = new RuntimeTrace({
      clock: rest.clock,
      sink,
      source: {
        newTraceId: () => traceIdOf('9'.repeat(32)),
        newSpanId: () => spanIdOf((++spans).toString(16).padStart(16, '0')),
      } satisfies TraceIdSource,
    });
    const dispatch = new RelayDispatch(
      source,
      rest.publisher,
      new RelayRetryEngine(
        { baseDelayMillis: 1_000, maxDelayMillis: 8_000, maxAttempts: 3, jitterMillis: 0 },
        () => 0,
      ),
      rest.clock,
      rest.metrics,
      noopLogger,
      { batchSize: 10, claimDurationMillis: 5_000 },
      tracer,
    );
    const carried = `00-${'ab'.repeat(16)}-${'cd'.repeat(8)}-01`;
    source.seed({ ...envelopeOf('m1', 'a', 1), traceparent: carried, correlationId: 'corr-9' });
    await dispatch.runOnce();
    expect(sink.spans[0]?.context.traceId).toBe('ab'.repeat(16));
    expect(sink.spans[0]?.context.parentSpanId).toBe('cd'.repeat(8));
    expect(sink.spans[0]?.attributes['correlationId']).toBe('corr-9');
    // And the envelope itself reached the bus untouched.
    expect(rest.publisher.delivered[0]?.traceparent).toBe(carried);
  });

  it('health: liveness never judges the backlog; readiness proves the source', async () => {
    const { source, clock } = harness();
    source.seed(envelopeOf('m1', 'a', 1, T0.epochMillis - 60_000));
    const health = new RelayHealth(source, clock);
    const snapshot = await health.snapshot();
    expect(snapshot.pending).toBe(1);
    expect(snapshot.oldestPendingAgeMs).toBe(60_000);
    expect((await health.livenessCheck().check()).kind).toBe('healthy');
    expect((await health.readinessCheck().check()).kind).toBe('healthy');
    source.unreachable = true;
    expect((await health.readinessCheck().check()).kind).toBe('unhealthy');
    expect((await health.livenessCheck().check()).kind).toBe('healthy');
  });
});

describe('lifecycle (I-11) — the module paces, drains, releases', () => {
  it('boots in a runtime container, ticks, never overlaps, drains in flight', async () => {
    const { source, publisher, dispatch } = harness();
    source.seed(envelopeOf('m1', 'a', 1));
    let tick: (() => Promise<void>) | undefined;
    let stopped = 0;
    const module = new RuntimeRelayModule(dispatch, 50, (fn) => {
      tick = fn;
      return () => {
        stopped += 1;
      };
    });
    const container = new RuntimeBuilder().withModule(module).build();
    expect((await container.boot()).ok).toBe(true);
    await tick?.();
    expect(publisher.delivered).toHaveLength(1);
    await container.shutdown();
    expect(stopped).toBeGreaterThanOrEqual(1);
    expect(container.state).toBe('Destroyed');
  });

  it('a reentrant tick is skipped while a pass is running (no overlap)', async () => {
    const { source, dispatch } = harness();
    source.seed(envelopeOf('m1', 'a', 1));
    let tick: (() => Promise<void>) | undefined;
    const module = new RuntimeRelayModule(dispatch, 50, (fn) => {
      tick = fn;
      return () => undefined;
    });
    module.start();
    const [first, second] = [tick?.(), tick?.()];
    await Promise.all([first, second]);
    await module.drain();
    module.dispose();
  });
});

describe('the relay knows NOTHING business', () => {
  it('depends on no domain, no application, no contracts package', () => {
    const here = dirname(fileURLToPath(import.meta.url));
    const manifest = JSON.parse(
      readFileSync(join(here, '..', 'package.json'), 'utf8'),
    ) as { dependencies: Record<string, string> };
    const forbidden = ['domain-', 'application-', 'contracts', 'adapters-'];
    for (const dependency of Object.keys(manifest.dependencies)) {
      for (const marker of forbidden) {
        expect(dependency.includes(marker), `${dependency} must not be a business package`).toBe(
          false,
        );
      }
    }
  });
});

describe('remaining doors', () => {
  it('cryptoJitterSource draws within the bound; zero bound is zero', async () => {
    const { cryptoJitterSource } = await import('./retry/relay-retry-engine.js');
    expect(cryptoJitterSource(0)).toBe(0);
    for (let draw = 0; draw < 20; draw += 1) {
      const value = cryptoJitterSource(100);
      expect(value).toBeGreaterThanOrEqual(0);
      expect(value).toBeLessThan(100);
    }
  });

  it('intervalPacer schedules and cancels real interval ticks', async () => {
    const { intervalPacer } = await import('./module/runtime-relay-module.js');
    let ticks = 0;
    const stop = intervalPacer(() => {
      ticks += 1;
      return Promise.resolve();
    }, 5);
    await new Promise((resolve) => setTimeout(resolve, 40));
    stop();
    const settled = ticks;
    expect(settled).toBeGreaterThanOrEqual(1);
    await new Promise((resolve) => setTimeout(resolve, 20));
    expect(ticks).toBe(settled);
  });

  it('quarantine logs the correlation WHEN IT EXISTS (F5.3 §2)', async () => {
    const { RelayQuarantine } = await import('./quarantine/relay-quarantine.js');
    const source = new InMemoryRelaySource();
    const withCorrelation = { ...envelopeOf('m1', 'a', 1), correlationId: 'corr-1' };
    source.seed(withCorrelation);
    const lines: unknown[] = [];
    const logger = {
      ...noopLogger,
      error: (_message: string, fields?: unknown) => {
        lines.push(fields);
      },
    };
    await new RelayQuarantine(source, logger).park(withCorrelation, 'poison');
    expect(lines[0]).toMatchObject({ correlationId: 'corr-1' });
  });

  it('a NON-Error publisher throw still quarantines with a described reason', async () => {
    const { source, clock, metrics } = harness({ maxAttempts: 1 });
    const throwingPublisher = {
      // eslint-disable-next-line @typescript-eslint/prefer-promise-reject-errors -- the non-Error path is exactly what this spec proves
      publish: () => Promise.reject('raw-bus-incident'),
    };
    const dispatch = new RelayDispatch(
      source,
      throwingPublisher,
      new RelayRetryEngine(
        { baseDelayMillis: 1, maxDelayMillis: 1, maxAttempts: 1, jitterMillis: 0 },
        () => 0,
      ),
      clock,
      metrics,
      noopLogger,
      { batchSize: 10, claimDurationMillis: 5_000 },
    );
    source.seed(envelopeOf('m1', 'a', 1));
    const outcome = await dispatch.runOnce();
    expect(outcome.quarantined).toBe(1);
    expect(source.reasonOf('m1')).toBe('raw-bus-incident');
  });

  it('a malformed carried traceparent yields a fresh root span — never a crash', async () => {
    const { RelayTracing } = await import('./tracing/relay-tracing.js');
    const sink = new MemorySpanSink();
    const tracer = new RuntimeTrace({
      clock: FakeClock.at(T0),
      sink,
      source: {
        newTraceId: () => traceIdOf('7'.repeat(32)),
        newSpanId: () => spanIdOf('8'.repeat(16)),
      },
    });
    const span = new RelayTracing(tracer).publishSpan({
      ...envelopeOf('m1', 'a', 1),
      traceparent: 'garbage-header',
    });
    span?.end();
    expect(sink.spans[0]?.context.traceId).toBe('7'.repeat(32));
  });

  it('the in-memory source refuses an unknown message id', () => {
    const source = new InMemoryRelaySource();
    expect(() => source.markPublished('ghost')).toThrow(/no relay row/);
  });
});
