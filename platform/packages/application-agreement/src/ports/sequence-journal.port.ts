import type { CorrelationId } from '@mentora/contracts';

import type { SequenceStep } from '../pipeline/sequence-steps.js';

/**
 * SequenceJournalPort — the application's journal of its own execution
 * (F4.1 §9, A-10): ONE record per step of the Séquence, carrying the
 * correlation, NEVER a content, NEVER a secret (P7). The Journal is the
 * APPLICATIVE, probative emission (F5.3 §2) — distinct from the technical Log.
 *
 * A port owned by its consumer (the application — F4.4 I-4), implemented by an
 * adapter below. `<Capability>Port` naming (F2.5 §9).
 */

export type SequenceStepOutcome = 'advanced' | 'refused' | 'exception' | 'failure';

export interface SequenceStepRecord {
  readonly correlationId: CorrelationId;
  readonly step: SequenceStep;
  /** The dictionary name of the command being executed. */
  readonly commandType: string;
  /** The injected instant of the execution (A-6) — never read here. */
  readonly occurredAtMs: number;
  readonly outcome: SequenceStepOutcome;
}

export interface SequenceJournalPort {
  record(entry: SequenceStepRecord): void;
}
