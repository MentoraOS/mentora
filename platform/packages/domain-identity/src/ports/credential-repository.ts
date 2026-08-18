import type { Option, Result, RetentionContext } from '@mentora/kernel';

import type { Credential } from '../aggregate/credential.js';
import type { CredentialRefusal } from '../decisions/credential-refusal.js';
import type { CredentialId, PersonId } from '../ids/identifiers.js';

/**
 * CredentialRepository — the registry port OWNED BY THE DOMAIN (F4.4 §3),
 * shaped EXACTLY like the frozen precedent (AgreementRepository): Option for
 * presence, Result<void> for the atomic retention verdict. The registry
 * applies the DECLARED R-A key at retention (one ACTIVE credential per
 * person × principal-factor kind) and refuses structurally with the settled
 * reason `CredentialAlreadyExists` (the ratified `<Truth>AlreadyExists`
 * family — F3.2-B `MembershipAlreadyExists` precedent; gap closed at the
 * persistence lot as prescribed).
 *
 * retain() is ONE atomic act (A-3): version control → facts → snapshot →
 * outbox — the implementations' law, proven by the contract suite. The
 * OPTIONAL `context` is RFC-001 (Option A, RATIFIED): envelope values the
 * outbox transports when they exist — never domain truth, never required.
 */
export interface CredentialRepository {
  byId(id: CredentialId): Promise<Option<Credential>>;
  /** The R-A probe surface: the ACTIVE credential of a person for a principal-factor kind. */
  activeByPersonAndKind(
    personId: PersonId,
    principalFactorKind: string,
  ): Promise<Option<Credential>>;
  retain(
    credential: Credential,
    context?: RetentionContext,
  ): Promise<Result<void, CredentialRefusal>>;
}
