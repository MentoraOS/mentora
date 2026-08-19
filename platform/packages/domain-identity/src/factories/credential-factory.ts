import type { Result } from '@mentora/kernel';
import { ok } from '@mentora/kernel';

import { Credential } from '../aggregate/credential.js';
import type { EstablishCredential } from '../commands/credential-commands.js';
import type { CredentialRefusal } from '../decisions/credential-refusal.js';
import type { Factor } from '../entities/factor.js';

/**
 * CredentialFactory — the birth door (F3.1: birth happens in the Factory,
 * the unit's constructor stays private). EstablishCredential arrives via the
 * ACL of the Account (F2.5 §5); the factory shapes the principal Factor and
 * arms the first fact. The R-A key (one ACTIVE credential per person ×
 * principal factor) is DECLARED by the specification and APPLIED by the
 * registry at retention — birth itself never queries the world (the unit
 * talks to nobody).
 */
export const establishCredential = (
  command: EstablishCredential,
): Result<Credential, CredentialRefusal> => {
  const principal: Factor = {
    factorId: command.principalFactor.factorId,
    kind: command.principalFactor.kind,
    strength: command.principalFactor.strength,
    principal: true,
    establishedAt: command.establishedAt,
  };
  const secondaries: readonly Factor[] = (command.secondaryFactors ?? []).map((factor) => ({
    factorId: factor.factorId,
    kind: factor.kind,
    strength: factor.strength,
    principal: false,
    establishedAt: command.establishedAt,
  }));
  return ok(Credential._born(command.credentialId, command.personId, principal, secondaries));
};
