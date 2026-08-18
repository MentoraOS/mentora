import type { CommandId } from '@mentora/contracts';

import type { CredentialId, FactorId, PersonId } from '../identifiers.js';

/**
 * The wire commands of the Identity & Access context — the published
 * language's single definition (catalog 70-74; Stories #16/#21 ship the
 * Credential pair, the Session wires arrive with their stories).
 * The wire NEVER carries an instant (A-6: time is injected at pas 3) and
 * NEVER carries secret material (the factor's nature and weight only —
 * the material lives with the mechanisms under the vault discipline).
 */

export interface IdentityCommandBase {
  readonly contractVersion: 1;
  /** The act identity (F4.1 §3) — replay is deduplicated by it. */
  readonly commandId: CommandId;
  readonly credentialId: CredentialId;
}

export interface EstablishCredential extends IdentityCommandBase {
  readonly type: 'EstablishCredential';
  /** Opaque reference handed by the Account ACL — the link lives THERE. */
  readonly personId: PersonId;
  readonly principalFactor: {
    readonly factorId: FactorId;
    readonly kind: string;
    readonly strength: string;
  };
}

export interface RevokeCredential extends IdentityCommandBase {
  readonly type: 'RevokeCredential';
  /** Dictionary motive — a reference, never secret material. */
  readonly motive: string;
}

export type IdentityCommandContract = EstablishCredential | RevokeCredential;

export const IDENTITY_COMMAND_TYPES = ['EstablishCredential', 'RevokeCredential'] as const;
