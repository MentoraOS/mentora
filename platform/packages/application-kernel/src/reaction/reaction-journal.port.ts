import type { CorrelationId } from '@mentora/contracts';

import type { ReactionStep } from './reaction-steps.js';

/**
 * The Journal of the Séquence de Réaction (pas 6; A-10: correlated, one
 * record per executed step, never a matter, never a secret — P7; Journal ≠
 * Log, F5.3). Same philosophy as the Command and Read journals: probative,
 * deterministic, content-free.
 *
 * `occurredAtMs` carries the ONE injected instant of the execution (pas 2 —
 * "instant si requis"; A-6): 0 on records written before the injection.
 */

export type ReactionStepOutcome = 'advanced' | 'duplicate' | 'exception' | 'failure' | 'abandoned';

export interface ReactionStepRecord {
  readonly correlationId: CorrelationId;
  readonly step: ReactionStep;
  /** The dictionary name of the fact being consumed. */
  readonly factType: string;
  readonly occurredAtMs: number;
  readonly attempt: number;
  readonly outcome: ReactionStepOutcome;
  /** Fact identity, failure code or violation code — never a content. */
  readonly note?: string;
}

export interface ReactionJournalPort {
  record(entry: ReactionStepRecord): void;
}
