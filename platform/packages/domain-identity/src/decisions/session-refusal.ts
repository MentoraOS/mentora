import type { SessionRefusalReason } from '@mentora/contracts-identity';

/**
 * The Session Refusal — a VALUE of full rank (F3.1.14). The reason union is
 * owned by the published language; `ProofUnavailable` derives from the
 * ratified `-Unavailable` family (F3.2-A).
 */

export type { SessionRefusalReason } from '@mentora/contracts-identity';

export interface SessionRefusal {
  readonly reason: SessionRefusalReason;
  readonly message: string;
}

export const sessionRefusal = (reason: SessionRefusalReason, message: string): SessionRefusal => ({
  reason,
  message,
});
