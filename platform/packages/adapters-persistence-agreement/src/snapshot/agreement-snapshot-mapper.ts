import { Agreement } from '@mentora/domain-agreement';

import { AgreementPersistenceCorruptionException } from '../errors/agreement-persistence-errors.js';
import {
  agreementSnapshotChecksum,
  deserializeAgreementSnapshot,
  serializeAgreementSnapshot,
} from '../serialization/agreement-snapshot-serializer.js';

/**
 * AgreementSnapshotMapper — unit ⇄ registry row, through the domain's OWN
 * doors only (toSnapshot/fromSnapshot — I-3: no truth is built here; S-2:
 * the unit is whole or is not). The expertId/slot/stateKind columns are the
 * MATERIALIZED INDEX of the declared R-A key and catalogue walk (RC-1 §1) —
 * derived from the photograph, never a second truth.
 */

export interface AgreementSnapshotRow {
  readonly agreementId: string;
  readonly version: number;
  readonly payload: string;
  readonly checksum: string;
  readonly expertId: string;
  readonly slotStartMs: bigint;
  readonly slotEndMs: bigint;
  readonly stateKind: string;
}

export const toSnapshotRow = (unit: Agreement): AgreementSnapshotRow => {
  const snapshot = unit.toSnapshot();
  const serialized = serializeAgreementSnapshot(snapshot);
  return {
    agreementId: snapshot.agreementId,
    version: snapshot.version,
    payload: serialized.payload,
    checksum: serialized.checksum,
    expertId: snapshot.expertId,
    slotStartMs: BigInt(snapshot.slot.startMs),
    slotEndMs: BigInt(snapshot.slot.endMs),
    stateKind: snapshot.state.kind,
  };
};

export const toUnit = (row: AgreementSnapshotRow): Agreement => {
  if (agreementSnapshotChecksum(row.payload) !== row.checksum) {
    throw new AgreementPersistenceCorruptionException(row.agreementId, 'checksum mismatch');
  }
  const snapshot = deserializeAgreementSnapshot(row.payload);
  if (!snapshot.ok) {
    throw new AgreementPersistenceCorruptionException(row.agreementId, snapshot.error);
  }
  return Agreement.fromSnapshot(snapshot.value);
};
