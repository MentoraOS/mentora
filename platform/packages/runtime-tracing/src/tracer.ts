import type { Clock } from '@mentora/kernel';

import type { TraceContext } from './trace-context.js';
import type { TraceIdSource } from './trace-ids.js';

/**
 * The runtime Tracer — abstractions only, no OpenTelemetry SDK (O-10: the
 * emission is neutral and OURS; platforms are interchangeable mechanisms —
 * "aucun vendor ne possède la télémétrie"). Spans time over the INJECTED
 * clock (A-6) and flow to an injected sink; attributes carry identifiers
 * and codes — never a matter, never a secret (O-2).
 */

export type SpanAttributeValue = string | number | boolean;

export interface Span {
  readonly name: string;
  readonly context: TraceContext;
  setAttribute(key: string, value: SpanAttributeValue): void;
  end(): void;
}

export interface FinishedSpan {
  readonly name: string;
  readonly context: TraceContext;
  readonly startedAtMs: number;
  readonly endedAtMs: number;
  readonly attributes: Readonly<Record<string, SpanAttributeValue>>;
}

export interface SpanSink {
  record(span: FinishedSpan): void;
}

export class MemorySpanSink implements SpanSink {
  readonly spans: FinishedSpan[] = [];

  record(span: FinishedSpan): void {
    this.spans.push(span);
  }
}

export interface Tracer {
  startSpan(name: string, parent?: TraceContext): Span;
}

export interface RuntimeTraceOptions {
  readonly clock: Clock;
  readonly source: TraceIdSource;
  readonly sink: SpanSink;
  /** Sampling is a declared operations choice on the PERDABLE only (F5.3 §9). */
  readonly sampled?: boolean;
}

export class RuntimeTrace implements Tracer {
  constructor(private readonly options: RuntimeTraceOptions) {}

  startSpan(name: string, parent?: TraceContext): Span {
    const { clock, source, sink } = this.options;
    const context: TraceContext = parent
      ? {
          traceId: parent.traceId,
          spanId: source.newSpanId(),
          parentSpanId: parent.spanId,
          sampled: parent.sampled,
        }
      : {
          traceId: source.newTraceId(),
          spanId: source.newSpanId(),
          sampled: this.options.sampled ?? true,
        };
    const startedAtMs = clock.now().epochMillis;
    const attributes: Record<string, SpanAttributeValue> = {};
    let ended = false;
    return {
      name,
      context,
      setAttribute: (key, value) => {
        attributes[key] = value;
      },
      end: () => {
        if (ended) {
          return;
        }
        ended = true;
        if (context.sampled) {
          sink.record({
            name,
            context,
            startedAtMs,
            endedAtMs: clock.now().epochMillis,
            attributes,
          });
        }
      },
    };
  }
}
