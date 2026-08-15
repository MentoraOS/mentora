/**
 * SequenceJournalPort — the application's journal of its own execution
 * (F4.1 §9, A-10): ONE record per step, correlated, NEVER a content, NEVER a
 * secret (P7). The probative applicative Journal, distinct from the technical
 * Log (F5.3 §2 — Journal ≠ Log).
 *
 * Since Lot 1C-2 the canonical port lives in `@mentora/application-kernel`
 * (the journal belongs to the generic pipeline, not to a domain); re-exported
 * here so the 1C-1 public API keeps a single definition.
 */

export type {
  SequenceJournalPort,
  SequenceStepOutcome,
  SequenceStepRecord,
} from '@mentora/application-kernel';
