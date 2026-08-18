import type { RevokeCredential as RevokeCredentialContract } from '@mentora/contracts-identity';
import type { CredentialRepository, RevokeCredential } from '@mentora/domain-identity';

import { revokeCredentialDefinition } from '../definitions/revoke-credential.definition.js';

import type { IdentitySequenceMachinery } from './identity-sequence.application-service.js';
import { IdentitySequenceApplicationService } from './identity-sequence.application-service.js';

/** Carries `RevokeCredential` — the prioritary revocation (A-1: one carrier). */
export class RevokeCredentialApplicationService extends IdentitySequenceApplicationService<
  RevokeCredentialContract,
  RevokeCredential
> {
  constructor(
    deps: { readonly repository: CredentialRepository },
    machinery: IdentitySequenceMachinery,
  ) {
    super(revokeCredentialDefinition(deps), machinery);
  }
}
