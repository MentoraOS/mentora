import { Session } from '@mentora/domain-identity';

import { IdentityPersistenceCorruptionException } from '../errors/identity-persistence-errors.js';
import {
  deserializeSessionSnapshot,
  identitySnapshotChecksum,
  serializeSessionSnapshot,
} from '../serialization/identity-snapshot-serializer.js';

/**
 * SessionSnapshotMapper — unit ⇄ registry row through the domain's own
 * doors. The credentialId / stateKind columns materialize the cascade probe
 * activeByCredential — derived from the photograph, never a second truth.
 */

export interface SessionSnapshotRow {
  readonly sessionId: string;
  readonly version: number;
  readonly payload: string;
  readonly checksum: string;
  readonly credentialId: string;
  readonly stateKind: string;
}

export const toSessionRow = (unit: Session): SessionSnapshotRow => {
  const snapshot = unit.snapshot();
  const serialized = serializeSessionSnapshot(snapshot);
  return {
    sessionId: snapshot.sessionId,
    version: snapshot.version,
    payload: serialized.payload,
    checksum: serialized.checksum,
    credentialId: snapshot.credentialId,
    stateKind: snapshot.state.kind,
  };
};

export const toSessionUnit = (row: {
  readonly sessionId: string;
  readonly payload: string;
  readonly checksum: string;
}): Session => {
  if (identitySnapshotChecksum(row.payload) !== row.checksum) {
    throw new IdentityPersistenceCorruptionException(row.sessionId, 'checksum mismatch');
  }
  const snapshot = deserializeSessionSnapshot(row.payload);
  if (!snapshot.ok) {
    throw new IdentityPersistenceCorruptionException(row.sessionId, snapshot.error);
  }
  return Session.fromSnapshot(snapshot.value);
};
