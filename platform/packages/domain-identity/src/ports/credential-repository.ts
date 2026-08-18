import type { Result } from '@mentora/kernel';

import type { Credential } from '../aggregate/credential.js';
import type { CredentialRefusal } from '../decisions/credential-refusal.js';
import type { CredentialId, PersonId } from '../ids/identifiers.js';

/**
 * CredentialRepository — the registry port OWNED BY THE DOMAIN (F4.4 §3:
 * domain owns its registries). The registry applies the DECLARED R-A key at
 * retention (one ACTIVE credential per person × principal-factor kind) and
 * refuses structurally — the refusal REASON name for that key is a recorded
 * canon gap, settled at the persistence lot (Story #64/#68).
 *
 * retain() is ONE atomic act (A-3): version control → facts → snapshot →
 * outbox — the implementations' law, proven by the contract suite.
 */
export interface CredentialRepository {
  byId(id: CredentialId): Promise<Credential | undefined>;
  /** The R-A probe surface: the ACTIVE credential of a person for a principal-factor kind. */
  activeByPersonAndKind(personId: PersonId, principalFactorKind: string): Promise<Credential | undefined>;
  retain(credential: Credential): Promise<Result<Credential, CredentialRefusal>>;
}
