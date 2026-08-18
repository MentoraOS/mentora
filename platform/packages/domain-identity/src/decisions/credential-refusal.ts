import type { CredentialRefusalReason } from '@mentora/contracts-identity';

/**
 * The Refusal — the negative Decision (F3.1.14: a VALUE of full rank, never
 * an exception). The REASON UNION is owned by the published language
 * (@mentora/contracts-identity); this module owns the in-memory Decision
 * shape the unit returns.
 */

export type { CredentialRefusalReason } from '@mentora/contracts-identity';

export interface CredentialRefusal {
  readonly reason: CredentialRefusalReason;
  readonly message: string;
}

export const credentialRefusal = (
  reason: CredentialRefusalReason,
  message: string,
): CredentialRefusal => ({ reason, message });
