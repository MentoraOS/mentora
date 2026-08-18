import type { RevokeCredential as RevokeCredentialContract } from '@mentora/contracts-identity';
import type { CredentialRepository, RevokeCredential } from '@mentora/domain-identity';
import { err } from '@mentora/kernel';

import { toRevokeCredential } from '../factories/identity-command-factory.js';

import type { IdentitySequenceDefinition } from './identity-sequence-definition.js';
import { credentialAbsentRefusal, identitySequenceDefinition } from './identity-sequence-definition.js';

/**
 * RevokeCredential — the prioritary verb (canon ch.04: "révocation
 * immédiate"; catalog 71). Active → Revoked, terminal (R-B). The unit
 * renders the Decision; an absent Identifier refuses — nothing to revoke
 * is a motivated Decision, never an error.
 */
export const revokeCredentialDefinition = (deps: {
  readonly repository: CredentialRepository;
}): IdentitySequenceDefinition<RevokeCredentialContract, RevokeCredential> =>
  identitySequenceDefinition(
    {
      commandType: 'RevokeCredential',
      map: (wire, instant) => toRevokeCredential(wire, instant),
      act: (unit, command) => (unit.some ? unit.value.revoke(command) : err(credentialAbsentRefusal())),
    },
    deps.repository,
  );
