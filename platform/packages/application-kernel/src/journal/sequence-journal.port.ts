import type { CorrelationId } from '@mentora/contracts';

import type { SequenceStep } from '../step/sequence-steps.js';

/**
 * SequenceJournalPort — the application's JOURNAL of its own execution
 * (F4.1 §9, A-10): ONE record per executed step, carrying the correlation,
 * NEVER a content, NEVER a secret (P7). The Journal is the APPLICATIVE,
 * probative emission (F5.3 §2 — Journal ≠ Log): step journal, error journal
 * and abandon journal all flow through this port; technical logs never do.
 *
 * A port owned by its consumer (the application — F4.4 I-4), implemented by
 * an adapter below. `<Capability>Port` naming (F2.5 §9).
 */

export type SequenceStepOutcome = 'advanced' | 'refused' | 'exception' | 'failure' | 'abandoned';

export interface SequenceStepRecord {
  readonly correlationId: CorrelationId;
  readonly step: SequenceStep;
  /** The dictionary name of the command being executed. */
  readonly commandType: string;
  /** The single injected instant of the execution (A-6) — never read here. */
  readonly occurredAtMs: number;
  /** 1-based execution attempt (retries re-run steps 4→8 only). */
  readonly attempt: number;
  readonly outcome: SequenceStepOutcome;
  /** Refusal reason / failure code — never a payload, never a matière (P7). */
  readonly note?: string;
}

export interface SequenceJournalPort {
  record(entry: SequenceStepRecord): void;
}
