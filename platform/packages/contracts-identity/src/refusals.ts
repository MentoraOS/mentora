/**
 * Refusal reasons of the Identity & Access context — the negative half of the
 * published contract (F3.1.14: a Refusal is a VALUE of full rank).
 *
 * `TransitionUnavailable` is the ratified generic of the frozen machine
 * (R-B — same word as the Agreement precedent): the unit was asked a verb its
 * current state does not offer.
 *
 * `CredentialAlreadyExists` — the R-A key's refusal, SETTLED at the
 * persistence lot (Story #64/#68) exactly as the recorded gap prescribed:
 * the dictionary ratifies the `<Truth>AlreadyExists` family for R-A
 * uniqueness keys by name (F3.2-B, Enterprise registres: « R-A sur "une
 * appartenance active par (Organisation, Personne)" — Décision
 * `MembershipAlreadyExists` »). The member DERIVES from that ratified
 * family — never invented: an ACTIVE Credential already exists for this
 * person × principal-factor kind.
 */

export type CredentialRefusalReason = 'TransitionUnavailable' | 'CredentialAlreadyExists';

export const CREDENTIAL_REFUSAL_REASONS: readonly CredentialRefusalReason[] = [
  'TransitionUnavailable',
  'CredentialAlreadyExists',
];

/**
 * Session refusal reasons. `ProofUnavailable` DERIVES from the ratified
 * `-Unavailable` refusal family (F3.2-A — the family is law, the member
 * derives): the presented proof does not satisfy the ProofRequirementPolicy.
 * Dictionary ruling recorded as pending alongside the R-A reason gap.
 */
export type SessionRefusalReason = 'TransitionUnavailable' | 'ProofUnavailable';

export const SESSION_REFUSAL_REASONS: readonly SessionRefusalReason[] = [
  'TransitionUnavailable',
  'ProofUnavailable',
];
