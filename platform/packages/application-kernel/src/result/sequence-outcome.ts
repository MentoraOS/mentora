import type { UnknownRecord } from '@mentora/kernel';

/**
 * The outcomes of one Sequence execution — the three channels of A-7, never
 * mixed, all carried as VALUES:
 * - executed  — the act happened; the unit was retained; facts await the relay.
 * - refused   — the motivated Decision refusal (from the validities, the act,
 *               or the structural R-A retention refusal). A refusal is a
 *               successful execution of the contract (pas 7).
 * - exception — a malformed call (pas 1), carrying the contract violations.
 * - abandoned — technical Failures exhausted the retry budget (the journal
 *               d'abandon; retries are mechanical because Failure is a value).
 */

/** Generic contract-violation shape (structurally matches every context's). */
export interface SequenceViolation {
  readonly code: string;
  readonly field: string;
  readonly message: string;
}

/** Minimal shape every domain refusal satisfies (motivated Decision). */
export interface SequenceRefusalLike {
  readonly reason: string;
  readonly message: string;
}

/** The third channel: technical incapacity, retryable, carried as a value. */
export interface SequenceFailure {
  readonly kind: 'Failure';
  readonly code: string;
  readonly message: string;
  readonly retryable: boolean;
  readonly metadata?: UnknownRecord;
}

export const sequenceFailure = (
  code: string,
  message: string,
  retryable = true,
): SequenceFailure => ({ kind: 'Failure', code, message, retryable });

export type SequenceOutcome<TUnit, TRefusal extends SequenceRefusalLike> =
  | { readonly kind: 'executed'; readonly unit: TUnit; readonly attempts: number }
  | { readonly kind: 'refused'; readonly refusal: TRefusal; readonly attempts: number }
  | { readonly kind: 'exception'; readonly violations: readonly SequenceViolation[] }
  | { readonly kind: 'abandoned'; readonly failure: SequenceFailure; readonly attempts: number };
