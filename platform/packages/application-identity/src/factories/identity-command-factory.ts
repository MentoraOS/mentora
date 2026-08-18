import type { EstablishCredential as EstablishCredentialContract } from '@mentora/contracts-identity';
import {
  commandIdOf,
  credentialIdOf,
  factorIdOf,
  factorKindOf,
  personIdOf,
  proofStrengthOf,
} from '@mentora/domain-identity';
import type { EstablishCredential } from '@mentora/domain-identity';
import type { CredentialRefusal } from '@mentora/domain-identity';
import type { Instant, Result } from '@mentora/kernel';
import { ok } from '@mentora/kernel';

/**
 * The wire→domain seam (pas 5, 1C-1 precedent: agreement-command-factory).
 * The INJECTED instant (A-6) enters the domain command here — the wire never
 * carries time. Blanks were refused at reception; the guards remain the
 * Exception door for malformed internal calls.
 */
export const toEstablishCredential = (
  wire: EstablishCredentialContract,
  instant: Instant,
): Result<EstablishCredential, CredentialRefusal> =>
  ok({
    commandId: commandIdOf(wire.commandId),
    credentialId: credentialIdOf(wire.credentialId),
    personId: personIdOf(wire.personId),
    principalFactor: {
      factorId: factorIdOf(wire.principalFactor.factorId),
      kind: factorKindOf(wire.principalFactor.kind),
      strength: proofStrengthOf(wire.principalFactor.strength),
    },
    establishedAt: instant,
  });
