import type { CommandId } from '@mentora/contracts';

import type { CredentialId, FactorId, PersonId, SessionId } from '../identifiers.js';

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
  /** V-2 ADDITIVE (Story #111 MFA): optional factors born WITH the credential. */
  readonly secondaryFactors?: readonly {
    readonly factorId: FactorId;
    readonly kind: string;
    readonly strength: string;
  }[];
}

export interface RevokeCredential extends IdentityCommandBase {
  readonly type: 'RevokeCredential';
  /** Dictionary motive — a reference, never secret material. */
  readonly motive: string;
}

export type IdentityCommandContract = EstablishCredential | RevokeCredential;

export const IDENTITY_COMMAND_TYPES = ['EstablishCredential', 'RevokeCredential'] as const;

/** Session — mot réservé au domaine I&A : légitime ici. Le wire porte la FORCE de la preuve vérifiée, jamais sa matière. */
export interface OpenSession {
  readonly contractVersion: 1;
  readonly commandId: CommandId;
  readonly sessionId: SessionId;
  readonly credentialId: CredentialId;
  readonly presentedStrength: string;
  readonly type: 'OpenSession';
}

export interface EndSession {
  readonly contractVersion: 1;
  readonly commandId: CommandId;
  readonly sessionId: SessionId;
  readonly type: 'EndSession';
}

export interface RevokeSession {
  readonly contractVersion: 1;
  readonly commandId: CommandId;
  readonly sessionId: SessionId;
  readonly motive: string;
  readonly type: 'RevokeSession';
}

export type SessionCommandContract = OpenSession | EndSession | RevokeSession;

export const SESSION_COMMAND_TYPES = ['OpenSession', 'EndSession', 'RevokeSession'] as const;
