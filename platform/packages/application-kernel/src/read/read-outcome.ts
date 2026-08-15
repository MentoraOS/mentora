import type {
  SequenceFailure,
  SequenceRefusalLike,
  SequenceViolation,
} from '../result/sequence-outcome.js';

/**
 * The outcome of ONE read execution — the three A-7 channels as VALUES,
 * never mixed (the channel primitives are shared with the Séquence de
 * Commande: one definition, two sequences):
 * - answered  : the published response (the only success);
 * - refused   : R-C right missing, or nothing readable — a motivated
 *               Decision VALUE ("refuse motivé", F4.1 §5);
 * - exception : malformed call (pas 1) — violations as values;
 * - failure   : technical incapacity, retryable BY THE TRANSPORT — the
 *               Séquence de Lecture itself never retries (its six frozen
 *               steps hold no retry; a read is idempotent and the caller
 *               may simply ask again — M-8 bounds transport retries).
 */
export type ReadOutcome<TResponse, TRefusal extends SequenceRefusalLike> =
  | { readonly kind: 'answered'; readonly response: TResponse }
  | { readonly kind: 'refused'; readonly refusal: TRefusal }
  | { readonly kind: 'exception'; readonly violations: readonly SequenceViolation[] }
  | { readonly kind: 'failure'; readonly failure: SequenceFailure };
