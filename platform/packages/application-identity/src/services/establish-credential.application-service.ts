import type { EstablishCredential as EstablishCredentialContract } from '@mentora/contracts-identity';
import type { CredentialRepository, EstablishCredential } from '@mentora/domain-identity';

import { establishCredentialDefinition } from '../definitions/establish-credential.definition.js';

import type { IdentitySequenceMachinery } from './identity-sequence.application-service.js';
import { IdentitySequenceApplicationService } from './identity-sequence.application-service.js';

/** Carries `EstablishCredential` — the birth of the proof (A-1: one carrier). */
export class EstablishCredentialApplicationService extends IdentitySequenceApplicationService<
  EstablishCredentialContract,
  EstablishCredential
> {
  constructor(
    deps: { readonly repository: CredentialRepository },
    machinery: IdentitySequenceMachinery,
  ) {
    super(establishCredentialDefinition(deps), machinery);
  }
}
