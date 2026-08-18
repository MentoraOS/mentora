import type {
  CredentialStateReadPort,
  CredentialStateView,
  SessionStateReadPort,
  SessionStateView,
} from '@mentora/application-identity';
import type { CredentialId, SessionId } from '@mentora/domain-identity';
import type { Option } from '@mentora/kernel';
import { none, some } from '@mentora/kernel';

import type { PrismaClient } from '../generated/prisma/client.js';

import { IdentityPersistenceCorruptionException } from '../errors/identity-persistence-errors.js';
import {
  deserializeCredentialSnapshot,
  deserializeSessionSnapshot,
  identitySnapshotChecksum,
} from '../serialization/identity-snapshot-serializer.js';

/**
 * The TWO read capabilities of the M-10 gate (Story #72), strictly and
 * nothing more: no extra projection, no search, no browse — no I&A Query
 * is ratified (F3.3 §5) and these adapters mint none. Reads hit the
 * PRIMARY (S-5: session validity is never read on a lagging replica).
 * Views are derived from the VERIFIED photograph — checksum first,
 * corruption throws (never a lying view); the domain unit never exits
 * (the views carry state kinds and references only).
 */

export class PrismaSessionStateReadAdapter implements SessionStateReadPort {
  constructor(private readonly prisma: PrismaClient) {}

  async stateOf(sessionId: SessionId): Promise<Option<SessionStateView>> {
    const row = await this.prisma.sessionSnapshot.findUnique({ where: { sessionId } });
    if (row === null) {
      return none;
    }
    if (identitySnapshotChecksum(row.payload) !== row.checksum) {
      throw new IdentityPersistenceCorruptionException(row.sessionId, 'checksum mismatch');
    }
    const snapshot = deserializeSessionSnapshot(row.payload);
    if (!snapshot.ok) {
      throw new IdentityPersistenceCorruptionException(row.sessionId, snapshot.error);
    }
    return some({
      sessionId: snapshot.value.sessionId as SessionId,
      credentialId: snapshot.value.credentialId as CredentialId,
      stateKind: snapshot.value.state.kind,
      version: snapshot.value.version,
    });
  }
}

export class PrismaCredentialStateReadAdapter implements CredentialStateReadPort {
  constructor(private readonly prisma: PrismaClient) {}

  async stateOf(credentialId: CredentialId): Promise<Option<CredentialStateView>> {
    const row = await this.prisma.credentialSnapshot.findUnique({ where: { credentialId } });
    if (row === null) {
      return none;
    }
    if (identitySnapshotChecksum(row.payload) !== row.checksum) {
      throw new IdentityPersistenceCorruptionException(row.credentialId, 'checksum mismatch');
    }
    const snapshot = deserializeCredentialSnapshot(row.payload);
    if (!snapshot.ok) {
      throw new IdentityPersistenceCorruptionException(row.credentialId, snapshot.error);
    }
    return some({
      credentialId: snapshot.value.credentialId as CredentialId,
      personId: snapshot.value.personId as CredentialStateView['personId'],
      stateKind: snapshot.value.state.kind,
      version: snapshot.value.version,
    });
  }
}
