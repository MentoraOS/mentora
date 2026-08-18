/**
 * CredentialSnapshot — the internal reconstitution photograph (F3.1.11:
 * "privée au registre — jamais un contrat, jamais une donnée servie";
 * F5.2.99: reconstruction = private Snapshot + delta). Plain serializable
 * state; ONLY the registry adapter may touch it. NO secret material can
 * appear here by construction — the Factor shape has no field for it.
 */

export interface CredentialSnapshotFactor {
  readonly factorId: string;
  readonly kind: string;
  readonly strength: string;
  readonly principal: boolean;
  readonly establishedAtMs: number;
}

export type CredentialSnapshotState =
  | { readonly kind: 'Active'; readonly establishedAtMs: number }
  | { readonly kind: 'Revoked'; readonly revokedAtMs: number; readonly motive: string };

export interface CredentialSnapshot {
  readonly credentialId: string;
  readonly personId: string;
  readonly factors: readonly CredentialSnapshotFactor[];
  readonly state: CredentialSnapshotState;
  readonly version: number;
}
