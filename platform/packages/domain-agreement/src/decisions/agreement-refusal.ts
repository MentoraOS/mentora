/**
 * The Refusal — the negative Decision (F3.1.14: "la Décision négative — métier,
 * attendue, saine"; it is a VALUE of full rank, never an exception; the refusal
 * is half of the P4 contract). Every Command on the Agreement yields
 * Result<Agreement, AgreementRefusal> — the Decision, motivated by a Reason.
 *
 * Ratified reasons (R2): TimeSlotUnavailable (F3.2-A amendment 1 — official VO
 * + the `-Unavailable` family), OutsideAvailabilityFrame,
 * ConfirmationConditionsMissing. TransitionUnavailable follows the ratified
 * `-Unavailable` family for acts arriving on a state that cannot serve them
 * (frozen machine, F3.3 §8). The remaining names are engineering names pending
 * Titre VII ratification of the full Reason family (F2.5.2 §20 is not
 * enumerated in the materialized corpus — SIGNALED, not invented as law).
 */

export type AgreementRefusalReason =
  | 'TimeSlotUnavailable'
  | 'OutsideAvailabilityFrame'
  | 'ConfirmationConditionsMissing'
  | 'TransitionUnavailable'
  | 'SlotBoundsInvalid'
  | 'CancellationWindowClosed'
  | 'RescheduleWindowClosed'
  | 'RescheduleLimitReached';

export interface AgreementRefusal {
  readonly reason: AgreementRefusalReason;
  readonly message: string;
}

export const agreementRefusal = (
  reason: AgreementRefusalReason,
  message: string,
): AgreementRefusal => ({ reason, message });
