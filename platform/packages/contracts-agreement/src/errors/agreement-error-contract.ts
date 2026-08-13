import type { UnknownRecord } from '@mentora/kernel';

/**
 * The PUBLIC error contracts of the Agreement language. Plain coded shapes —
 * NEVER a JavaScript Error (an error that crosses a boundary is data, not a
 * throw). Two families:
 *
 * 1. AgreementRefusalContract — the published form of the domain's motivated
 *    Decision refusals (F3.1.14). The reason union is THE single definition;
 *    the domain package imports it (no duplication).
 * 2. AgreementContractViolation — a message that violates the contract itself
 *    (missing/blank/mistyped field): a transport-level defect, prior to any
 *    business judgment.
 */

/**
 * Ratified reasons: TimeSlotUnavailable, OutsideAvailabilityFrame,
 * ConfirmationConditionsMissing (F3.2-A) + the `-Unavailable` family
 * (TransitionUnavailable). The remaining names follow the ratified patterns
 * and await Titre VII ratification of the full Reason family (F2.5.2 §20 not
 * enumerated in the materialized corpus — SIGNALED).
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

export interface AgreementRefusalContract {
  readonly kind: 'AgreementRefusal';
  readonly reason: AgreementRefusalReason;
  readonly message: string;
  readonly metadata?: UnknownRecord;
}

export type AgreementContractViolationCode =
  | 'CONTRACT.NOT_AN_OBJECT'
  | 'CONTRACT.FIELD_MISSING'
  | 'CONTRACT.FIELD_TYPE'
  | 'CONTRACT.FIELD_BLANK'
  | 'CONTRACT.UNKNOWN_CONTRACT'
  | 'CONTRACT.VERSION_INCOMPATIBLE'
  | 'CONTRACT.MALFORMED_JSON';

export interface AgreementContractViolation {
  readonly code: AgreementContractViolationCode;
  readonly field: string;
  readonly message: string;
  readonly metadata?: UnknownRecord;
}
