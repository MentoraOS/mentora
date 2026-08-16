import { instantOf } from '@mentora/kernel';
import { FakeClock } from '@mentora/testing-clock';
import { describe, expect, it, vi } from 'vitest';

import { decodeTraceparent, encodeTraceparent } from './trace-context.js';
import { cryptoTraceIdSource, spanIdOf, traceIdOf } from './trace-ids.js';
import type { TraceIdSource } from './trace-ids.js';
import { MemorySpanSink, RuntimeTrace } from './tracer.js';

const T0 = instantOf(50_000);

const fixedSource = (): TraceIdSource => {
  let spanCounter = 0;
  return {
    newTraceId: () => traceIdOf('a'.repeat(32)),
    newSpanId: () => {
      spanCounter += 1;
      return spanIdOf(spanCounter.toString(16).padStart(16, '0'));
    },
  };
};

describe('trace identities (dialects — F5.3 §10)', () => {
  it('guards the W3C shapes and refuses the all-zero ids', () => {
    expect(() => traceIdOf('not-hex')).toThrow();
    expect(() => traceIdOf('0'.repeat(32))).toThrow();
    expect(() => spanIdOf('0'.repeat(16))).toThrow();
    expect(cryptoTraceIdSource.newTraceId()).toMatch(/^[0-9a-f]{32}$/);
    expect(cryptoTraceIdSource.newSpanId()).toMatch(/^[0-9a-f]{16}$/);
  });
});

describe('traceparent propagation (pure encoding, no SDK)', () => {
  it('round-trips a context', () => {
    const context = {
      traceId: traceIdOf('ab'.repeat(16)),
      spanId: spanIdOf('cd'.repeat(8)),
      sampled: true,
    };
    const decoded = decodeTraceparent(encodeTraceparent(context));
    expect(decoded.some && decoded.value).toEqual(context);
  });

  it('refuses malformed and all-zero headers', () => {
    expect(decodeTraceparent('garbage').some).toBe(false);
    expect(decodeTraceparent(`00-${'0'.repeat(32)}-${'cd'.repeat(8)}-01`).some).toBe(false);
  });
});

describe('RuntimeTrace (spans over the injected clock — deterministic)', () => {
  it('times a span and links parent to child in one trace', () => {
    const clock = FakeClock.at(T0);
    const sink = new MemorySpanSink();
    const tracer = new RuntimeTrace({ clock, source: fixedSource(), sink });
    const parent = tracer.startSpan('boot');
    clock.advanceMillis(100);
    const child = tracer.startSpan('validate', parent.context);
    child.setAttribute('checks', 9);
    clock.advanceMillis(40);
    child.end();
    parent.end();
    expect(sink.spans.map((span) => span.name)).toEqual(['validate', 'boot']);
    const [validate, boot] = sink.spans;
    expect(validate?.context.traceId).toBe(boot?.context.traceId);
    expect(validate?.context.parentSpanId).toBe(boot?.context.spanId);
    expect(validate?.startedAtMs).toBe(T0.epochMillis + 100);
    expect(validate?.endedAtMs).toBe(T0.epochMillis + 140);
    expect(validate?.attributes).toEqual({ checks: 9 });
  });

  it('an unsampled trace records NOTHING — the shadow is perdable (F5.3 §9)', () => {
    const sink = new MemorySpanSink();
    const tracer = new RuntimeTrace({
      clock: FakeClock.at(T0),
      source: fixedSource(),
      sink,
      sampled: false,
    });
    const span = tracer.startSpan('quiet');
    span.end();
    span.end();
    expect(sink.spans).toHaveLength(0);
  });
});

describe('remaining doors', () => {
  it('decodes an unsampled header and defaults new roots to sampled', () => {
    const decoded = decodeTraceparent(`00-${'ab'.repeat(16)}-${'cd'.repeat(8)}-00`);
    expect(decoded.some && decoded.value.sampled).toBe(false);
    const sink = new MemorySpanSink();
    const tracer = new RuntimeTrace({ clock: FakeClock.at(T0), source: fixedSource(), sink });
    const span = tracer.startSpan('rooted');
    expect(span.context.sampled).toBe(true);
    span.end();
    expect(sink.spans).toHaveLength(1);
  });

  it('a child of an UNSAMPLED parent stays silent — the shadow propagates', () => {
    const sink = new MemorySpanSink();
    const tracer = new RuntimeTrace({
      clock: FakeClock.at(T0),
      source: fixedSource(),
      sink,
      sampled: false,
    });
    const parent = tracer.startSpan('quiet');
    const child = tracer.startSpan('still-quiet', parent.context);
    child.end();
    parent.end();
    expect(sink.spans).toHaveLength(0);
  });
});

describe('the all-zero guard of the crypto source', () => {
  it('an adversarial all-zero draw still yields valid, non-zero ids', () => {
    const spy = vi
      .spyOn(globalThis.crypto, 'getRandomValues')
      .mockImplementation(<T extends ArrayBufferView | null>(array: T): T => {
        if (array instanceof Uint8Array) {
          array.fill(0);
        }
        return array;
      });
    try {
      expect(cryptoTraceIdSource.newTraceId()).toBe(`1${'0'.repeat(31)}`);
      expect(cryptoTraceIdSource.newSpanId()).toBe(`1${'0'.repeat(15)}`);
    } finally {
      spy.mockRestore();
    }
  });
});
