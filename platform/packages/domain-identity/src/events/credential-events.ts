import type { Instant } from '@mentora/kernel';

import type { CredentialId, FactorId, PersonId } from '../ids/identifiers.js';
import type { FactorKind } from '../value-objects/factor-kind.js';

/**
 * The facts of the Credential — the TWO ratified events of the context
 * (dictionary F2.5 §4: « CredentialEstablished · CredentialRevoked »).
 * Canon ch.04: "références et natures, AUCUNE matière" — a fact may say
 * WHICH factor kind established the proof, never any material, never a
 * strength judgment (the strength is the Policy's business, not the
 * public record's).
 */

export interface CredentialEstablished {
  readonly type: 'CredentialEstablished';
  readonly credentialId: CredentialId;
  /** Per-unit fact order — the EventIdentity half owned by the unit. */
  readonly sequence: number;
  readonly instant: Instant;
  readonly personId: PersonId;
  readonly principalFactorId: FactorId;
  readonly principalFactorKind: FactorKind;
}

export interface CredentialRevoked {
  readonly type: 'CredentialRevoked';
  readonly credentialId: CredentialId;
  readonly sequence: number;
  readonly instant: Instant;
  readonly motive: string;
}
