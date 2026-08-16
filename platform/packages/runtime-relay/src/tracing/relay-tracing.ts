import type { Span, Tracer } from '@mentora/runtime-tracing';
import { decodeTraceparent } from '@mentora/runtime-tracing';

import type { RelayEnvelope } from '../dispatch/relay-envelope.js';

/**
 * RelayTracing — the sampled shadow of a delivery (O-4). "Aucune perte":
 * the envelope's correlation/causation/traceparent are NEVER touched — the
 * publisher receives them verbatim; this helper only opens a CHILD span of
 * the carried trace context when one exists (and the tracer is provided).
 * The eternal chain stays the facts' provenance — the audit lives without
 * traces.
 */
export class RelayTracing {
  constructor(private readonly tracer?: Tracer) {}

  publishSpan(envelope: RelayEnvelope): Span | undefined {
    if (this.tracer === undefined) {
      return undefined;
    }
    const parent =
      envelope.traceparent !== undefined ? decodeTraceparent(envelope.traceparent) : undefined;
    const span =
      parent !== undefined && parent.some
        ? this.tracer.startSpan('relay.publish', parent.value)
        : this.tracer.startSpan('relay.publish');
    span.setAttribute('messageId', envelope.messageId);
    span.setAttribute('subjectKey', envelope.subjectKey);
    span.setAttribute('sequence', envelope.sequence);
    if (envelope.correlationId !== undefined) {
      span.setAttribute('correlationId', envelope.correlationId);
    }
    return span;
  }
}
