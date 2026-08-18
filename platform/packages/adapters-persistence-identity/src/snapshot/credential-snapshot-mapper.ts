import { Credential } from '@mentora/domain-identity';

import { IdentityPersistenceCorruptionException } from '../errors/identity-persistence-errors.js';
import {
  deserializeCredentialSnapshot,
  identitySnapshotChecksum,
  serializeCredentialSnapshot,
} from '../serialization/identity-snapshot-serializer.js';

/**
 * CredentialSnapshotMapper — unit ⇄ registry row, through the domain's OWN
 * doors only (toSnapshot/fromSnapshot — I-3: no truth is built here; S-2:
 * the unit is whole or is not). The personId / principalFactorKind /
 * stateKind columns are the MATERIALIZED INDEX of the declared R-A key
 * (RC-1 §1) — derived from the photograph, never a second truth. NO SECRET
 * can transit: the snapshot shape has no field for it.
 */

export interface CredentialSnapshotRow {
  readonly credentialId: string;
  readonly version: number;
  readonly payload: string;
  readonly checksum: string;
  readonly personId: string;
  readonly principalFactorKind: string;
  readonly stateKind: string;
}

export const toCredentialRow = (unit: Credential): CredentialSnapshotRow => {
  const snapshot = unit.snapshot();
  const serialized = serializeCredentialSnapshot(snapshot);
  const principal = snapshot.factors.find((factor) => factor.principal);
  if (principal === undefined) {
    // The unit's own invariant guards this; reaching here is a defect.
    throw new Error(`credential '${snapshot.credentialId}' photographs without a principal factor`);
  }
  return {
    credentialId: snapshot.credentialId,
    version: snapshot.version,
    payload: serialized.payload,
    checksum: serialized.checksum,
    personId: snapshot.personId,
    principalFactorKind: principal.kind,
    stateKind: snapshot.state.kind,
  };
};

export const toCredentialUnit = (row: {
  readonly credentialId: string;
  readonly payload: string;
  readonly checksum: string;
}): Credential => {
  if (identitySnapshotChecksum(row.payload) !== row.checksum) {
    throw new IdentityPersistenceCorruptionException(row.credentialId, 'checksum mismatch');
  }
  const snapshot = deserializeCredentialSnapshot(row.payload);
  if (!snapshot.ok) {
    throw new IdentityPersistenceCorruptionException(row.credentialId, snapshot.error);
  }
  return Credential.fromSnapshot(snapshot.value);
};
