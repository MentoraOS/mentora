import type { AgreementRefusalReason } from '@mentora/contracts-agreement';

/**
 * The Refusal — the negative Decision (F3.1.14: a VALUE of full rank, never an
 * exception; the refusal is half of the P4 contract). The REASON UNION is
 * owned by the published language (@mentora/contracts-agreement) — single
 * definition, re-exported here; this module owns the in-memory Decision shape
 * the unit returns.
 */

export type { AgreementRefusalReason } from '@mentora/contracts-agreement';

export interface AgreementRefusal {
  readonly reason: AgreementRefusalReason;
  readonly message: string;
}

export const agreementRefusal = (
  reason: AgreementRefusalReason,
  message: string,
): AgreementRefusal => ({ reason, message });
