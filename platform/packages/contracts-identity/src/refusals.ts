/**
 * Refusal reasons of the Identity & Access context — the negative half of the
 * published contract (F3.1.14: a Refusal is a VALUE of full rank).
 *
 * `TransitionUnavailable` is the ratified generic of the frozen machine
 * (R-B — same word as the Agreement precedent): the unit was asked a verb its
 * current state does not offer.
 *
 * CANON GAP, recorded, not invented: the corpus declares the Credential R-A
 * key ("one active Credential per person × principal factor") but does NOT
 * name its refusal reason (the Agreement precedent had `TimeSlotUnavailable`
 * ratified by name). The persistence lot (Story #64/#68) will need that name:
 * it must be settled against the dictionary THEN — until ratified, this union
 * deliberately does not carry it.
 */

export type CredentialRefusalReason = 'TransitionUnavailable';

export const CREDENTIAL_REFUSAL_REASONS: readonly CredentialRefusalReason[] = [
  'TransitionUnavailable',
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
