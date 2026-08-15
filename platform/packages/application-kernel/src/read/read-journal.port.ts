import type { CorrelationId } from '@mentora/contracts';

import type { ReadStep } from './read-steps.js';

/**
 * The Journal of the Séquence de Lecture (pas 6; A-10: "le journal suit la
 * Séquence, porte la corrélation, et ne contient jamais une matière";
 * F4.1 §6: the Query Dispatch "journalise"). One record per executed step,
 * correlated — never a content, never a secret (P7). Journal ≠ Log (F5.3).
 *
 * DELIBERATE ABSENCE of a timestamp: the frozen six steps of the Lecture
 * hold NO TimeInjection — no instant is captured, and A-6 forbids reading a
 * clock ambiently. The adapter below this port may stamp its own storage
 * time (technical, below the port — I-12).
 */

export type ReadStepOutcome = 'advanced' | 'refused' | 'exception' | 'failure';

export interface ReadStepRecord {
  readonly correlationId: CorrelationId;
  readonly step: ReadStep;
  /** The dictionary name of the query being read. */
  readonly queryType: string;
  readonly outcome: ReadStepOutcome;
  /** Refusal reason or failure/violation code — never a content. */
  readonly note?: string;
}

export interface ReadJournalPort {
  record(entry: ReadStepRecord): void;
}
