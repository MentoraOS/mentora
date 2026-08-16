import { none, some } from '@mentora/kernel';
import type { Option } from '@mentora/kernel';

import type { SpanId, TraceId } from './trace-ids.js';
import { spanIdOf, traceIdOf } from './trace-ids.js';

/**
 * TraceContext + W3C traceparent propagation. F5.3 §5/O-4: the Trace is a
 * SAMPLED SHADOW ("licite sur le perdable seul") — the eternal chain is the
 * provenance of facts and the correlation of Journals; the audit redoes
 * itself WITHOUT traces. Propagation is a pure encoding — no vendor SDK.
 */

export interface TraceContext {
  readonly traceId: TraceId;
  readonly spanId: SpanId;
  readonly parentSpanId?: SpanId;
  readonly sampled: boolean;
}

const TRACEPARENT_SHAPE = /^00-([0-9a-f]{32})-([0-9a-f]{16})-([0-9a-f]{2})$/;

export const encodeTraceparent = (context: TraceContext): string =>
  `00-${context.traceId}-${context.spanId}-${context.sampled ? '01' : '00'}`;

export const decodeTraceparent = (header: string): Option<TraceContext> => {
  const match = TRACEPARENT_SHAPE.exec(header.trim());
  if (match === null) {
    return none;
  }
  const [, trace, span, flags] = match;
  if (trace === undefined || span === undefined || /^0+$/.test(trace) || /^0+$/.test(span)) {
    return none;
  }
  return some({
    traceId: traceIdOf(trace),
    spanId: spanIdOf(span),
    sampled: flags === '01',
  });
};
