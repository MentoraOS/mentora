import type { EstablishCredential as EstablishCredentialContract } from '@mentora/contracts-identity';
import type { CredentialRepository, EstablishCredential } from '@mentora/domain-identity';
import { credentialRefusal, establishCredential } from '@mentora/domain-identity';
import { err } from '@mentora/kernel';

import { toEstablishCredential } from '../factories/identity-command-factory.js';

import type { IdentitySequenceDefinition } from './identity-sequence-definition.js';
import { identitySequenceDefinition } from './identity-sequence-definition.js';

/**
 * EstablishCredential — the birth (canon ch.04: established via the ACL of
 * the Account; catalog 70). The act goes through the FACTORY door (F3.1);
 * an Identifier already inhabited refuses: R-B — a new unit needs a new
 * identity. The R-A key (one ACTIVE credential per person ×
 * principal-factor kind) is applied STRUCTURALLY by the registry at
 * retention — never judged here.
 */
export const establishCredentialDefinition = (deps: {
  readonly repository: CredentialRepository;
}): IdentitySequenceDefinition<EstablishCredentialContract, EstablishCredential> =>
  identitySequenceDefinition(
    {
      commandType: 'EstablishCredential',
      map: (wire, instant) => toEstablishCredential(wire, instant),
      act: (unit, command) =>
        unit.some
          ? err(
              credentialRefusal(
                'TransitionUnavailable',
                'A Credential already lives under this Identifier — a new unit requires a new identity (R-B)',
              ),
            )
          : establishCredential(command),
    },
    deps.repository,
  );
