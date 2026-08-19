import type { Instant } from '@mentora/kernel';

import type { CommandId, CredentialId, FactorId, PersonId } from '../ids/identifiers.js';
import type { FactorKind } from '../value-objects/factor-kind.js';
import type { ProofStrength } from '../value-objects/proof-strength.js';

/**
 * Commands of the Credential unit — the two ratified dictionary verbs
 * (catalog 70-71), arriving « via ACL » du Compte (F2.5 §5): the Account ACL
 * is the door that carries them, the Credential is the unit that judges.
 * Every command carries its act identity (CommandId, F4.1 §3) and its
 * instant AS DATA (the clock never enters the unit, F3.1.99 §5).
 */

export interface EstablishCredential {
  readonly commandId: CommandId;
  readonly credentialId: CredentialId;
  /** Opaque reference handed by the Account ACL — the link lives THERE. */
  readonly personId: PersonId;
  readonly principalFactor: {
    readonly factorId: FactorId;
    readonly kind: FactorKind;
    readonly strength: ProofStrength;
  };
  /** MFA (Story #111): additional factors born WITH the credential (V-2 additive). */
  readonly secondaryFactors?: readonly {
    readonly factorId: FactorId;
    readonly kind: FactorKind;
    readonly strength: ProofStrength;
  }[];
  readonly establishedAt: Instant;
}

export interface RevokeCredential {
  readonly commandId: CommandId;
  readonly credentialId: CredentialId;
  /** Dictionary motive, never secret material. */
  readonly motive: string;
  readonly revokedAt: Instant;
}
