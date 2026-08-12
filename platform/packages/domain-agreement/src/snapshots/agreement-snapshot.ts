/**
 * AgreementSnapshot — the internal reconstitution photograph (F3.1.11: "privée
 * au registre — jamais un contrat, jamais une donnée servie"; F5.2.99:
 * reconstruction = private Snapshot + delta). Plain serializable state; ONLY
 * the registry adapter may touch it. It is NOT a published shape.
 */

export interface AgreementSnapshotSlot {
  readonly startMs: number;
  readonly endMs: number;
}

export interface AgreementSnapshotParty {
  readonly role: 'Client' | 'Expert';
  readonly id: string;
}

export interface AgreementSnapshotReschedule {
  readonly previousSlot: AgreementSnapshotSlot;
  readonly newSlot: AgreementSnapshotSlot;
  readonly requestedBy: AgreementSnapshotParty;
  readonly instantMs: number;
}

export type AgreementSnapshotState =
  | { readonly kind: 'Requested'; readonly atMs: number }
  | { readonly kind: 'Accepted'; readonly atMs: number }
  | { readonly kind: 'Confirmed'; readonly atMs: number; readonly settlementReference: string }
  | { readonly kind: 'Rejected'; readonly atMs: number }
  | { readonly kind: 'Lapsed'; readonly atMs: number }
  | {
      readonly kind: 'Cancelled';
      readonly atMs: number;
      readonly cancelledBy: AgreementSnapshotParty;
      readonly motive: string;
    }
  | { readonly kind: 'Elapsed'; readonly atMs: number };

export interface AgreementSnapshot {
  readonly agreementId: string;
  readonly clientId: string;
  readonly expertId: string;
  readonly offerId: string;
  readonly slot: AgreementSnapshotSlot;
  readonly state: AgreementSnapshotState;
  readonly reschedules: readonly AgreementSnapshotReschedule[];
  readonly version: number;
}
