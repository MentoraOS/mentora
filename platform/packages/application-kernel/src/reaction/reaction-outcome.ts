import type { SequenceFailure, SequenceViolation } from '../result/sequence-outcome.js';

/**
 * The outcome of ONE reaction execution. The channels of A-7 as VALUES —
 * with one deliberate difference from the Command and Read sequences:
 * there is NO Refusal channel. A Process Manager NEVER decides (P-3;
 * F4.2 §1: no truth, no invariant) — a business "no" can only come from an
 * AGGREGATE, later, when the emitted commands run their own Séquence de
 * Commande. A journey-level dead end (compensation refused beyond policy
 * bounds, P-8) is a POSITION (Abandoned + ops Signal), not a pipeline
 * outcome.
 *
 * - reacted    : new position + emitted commands retained (Outbox de
 *                commandes) — the only success;
 * - duplicate  : the Inbox already carries this fact identity (M-4) —
 *                absorbed, at-least-once redelivery is normal, not an error;
 * - exception  : malformed payload (pas 1) — violations as values;
 * - abandoned  : the TECHNICAL retry budget is exhausted (M-8: "les retries
 *                sont bornés; au-delà : Quarantaine + Signal — rien ne meurt
 *                sans témoin") — journaled, never silent.
 */
export type ReactionOutcome<TPosition, TCommand> =
  | {
      readonly kind: 'reacted';
      readonly position: TPosition;
      readonly commands: readonly TCommand[];
      readonly attempts: number;
    }
  | { readonly kind: 'duplicate'; readonly factIdentity: string }
  | { readonly kind: 'exception'; readonly violations: readonly SequenceViolation[] }
  | { readonly kind: 'abandoned'; readonly failure: SequenceFailure; readonly attempts: number };
