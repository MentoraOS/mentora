/**
 * The Refusal channel of the Account Lecture (A-7: a motivated VALUE, never
 * thrown). SIGNALED, same posture as the Agreement precedent (the read
 * Reason family of F2.5.2 §20 is not enumerated in the materialized
 * corpus): 'RightMissing' — R-C verbatim "si le droit manque";
 * 'AccountUnavailable' — the ratified `-Unavailable` family (nothing
 * readable under this person — motivated, never silence, F2.6).
 */

export type AccountReadRefusalReason = 'RightMissing' | 'AccountUnavailable';

export interface AccountReadRefusal {
  readonly reason: AccountReadRefusalReason;
  readonly message: string;
}

export const accountReadRefusal = (
  reason: AccountReadRefusalReason,
  message: string,
): AccountReadRefusal => ({ reason, message });
