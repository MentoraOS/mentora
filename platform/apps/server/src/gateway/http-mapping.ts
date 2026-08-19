import type {
  ReadOutcome,
  SequenceOutcome,
  SequenceRefusalLike,
} from '@mentora/application-kernel';

/**
 * The outcome→HTTP dialect — a MECHANISM of the entering adapter (F4.1.99:
 * frozen properties, free mechanisms; F4.3 M-7: dialects die at the edge).
 * The canonical semantics are preserved untouched in the BODY (the refusal
 * is a motivated VALUE; violations are the caller's defect); the status
 * code is HTTP's spelling of the same verdict, documented and reversible:
 *
 *   executed  → 200 (acknowledgement ONLY: the unit NEVER exits — I-4)
 *   answered  → 200 (the published response — it IS the wire language)
 *   refused   → 409 (a motivated Decision, full-rank value in the body)
 *   exception → 400 (violations listed — the caller's defect)
 *   abandoned/failure → 503 (transient technical Failure; retry later)
 */

export interface HttpReply {
  readonly status: number;
  readonly body: string;
}

const json = (status: number, value: unknown): HttpReply => ({
  status,
  body: JSON.stringify(value),
});

export const commandOutcomeReply = (
  outcome: SequenceOutcome<unknown, SequenceRefusalLike>,
): HttpReply => {
  switch (outcome.kind) {
    case 'executed':
      // Acknowledgement only — no unit, no snapshot, no domain truth.
      return json(200, { kind: 'executed', attempts: outcome.attempts });
    case 'refused':
      return json(409, { kind: 'refused', refusal: outcome.refusal });
    case 'exception':
      return json(400, { kind: 'exception', violations: outcome.violations });
    case 'abandoned':
      return json(503, {
        kind: 'abandoned',
        failure: { code: outcome.failure.code, retryable: outcome.failure.retryable },
      });
  }
};

export const readOutcomeReply = (
  outcome: ReadOutcome<unknown, SequenceRefusalLike>,
): HttpReply => {
  switch (outcome.kind) {
    case 'answered':
      return json(200, { kind: 'answered', response: outcome.response });
    case 'refused':
      return json(409, { kind: 'refused', refusal: outcome.refusal });
    case 'exception':
      return json(400, { kind: 'exception', violations: outcome.violations });
    case 'failure':
      return json(503, {
        kind: 'failure',
        failure: { code: outcome.failure.code, retryable: outcome.failure.retryable },
      });
  }
};

/** 401 — the TRANSPORT identity failed at the gate (M-9); never a Refusal. */
export const unauthenticatedReply = (detail: string): HttpReply =>
  json(401, { kind: 'unauthenticated', detail });

export const notFoundReply = (): HttpReply => json(404, { error: 'no such surface' });
