/**
 * THE SÉQUENCE DE COMMANDE — the ten frozen steps (F4.1 §2, order corrected
 * by F4.1.99). Since Lot 1C-2 the canonical definition lives in
 * `@mentora/application-kernel`: "le pipeline n'appartient pas au domaine —
 * le domaine est injecté dans le pipeline". This module re-exports it so the
 * 1C-1 public API is preserved with a SINGLE definition (anti-duplication —
 * the same law that moved Ids/envelopes into core contracts in 1B).
 *
 * The constitutional notes per step live with the canonical constant.
 */

export {
  SEQUENCE_STEPS,
  sequenceStepIndex,
  type SequenceStep,
} from '@mentora/application-kernel';
