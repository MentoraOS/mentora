/**
 * The ENVELOPE the relay transports — and NOTHING else. The relay knows no
 * domain: the payload is an opaque published text; the fields are exactly
 * the transport layer's (F4.3 §5: MessageId, correlation, causation,
 * delivery attempts, transport timestamp, trace — "jamais un champ métier
 * interprétable"). Ordering is promised PER UNIT SUBJECT only (F4.3 §4) —
 * the subjectKey is an OPAQUE key (M-3), never interpreted.
 *
 * "Aucune perte" (the mandate's tracing law): every field present at claim
 * is handed to the publisher untouched.
 */
export interface RelayEnvelope {
  /** The transport occurrence identity (a re-carried fact: new MessageId, same fact identity). */
  readonly messageId: string;
  /** The opaque unit-subject key — the ONLY ordering scope (F4.3 §4). */
  readonly subjectKey: string;
  /** The per-subject order (the fact's sequence). */
  readonly sequence: number;
  /** The published wire text — opaque to the relay. */
  readonly payload: string;
  readonly occurredAtMs: number;
  /** Correlation — carried WHEN IT EXISTS (F5.3 §2), never fabricated. */
  readonly correlationId?: string;
  readonly causationId?: string;
  /** W3C traceparent — carried untouched when present. */
  readonly traceparent?: string;
  /** Delivery attempts so far — envelope memory, never a position (P-4). */
  readonly deliveryAttempts: number;
}

/** The relay's view of its source backlog (health & metrics reading). */
export interface RelayBacklog {
  readonly pending: number;
  readonly retrying: number;
  readonly quarantined: number;
  readonly oldestPendingAgeMs: number | undefined;
}
