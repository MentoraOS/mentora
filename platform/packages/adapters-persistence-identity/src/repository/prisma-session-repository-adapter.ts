import type {
  CredentialId,
  Session,
  SessionId,
  SessionRefusal,
  SessionRepository,
} from '@mentora/domain-identity';
import type { Option, Result } from '@mentora/kernel';
import { none, ok, some } from '@mentora/kernel';


import { classifyIdentityEngineError } from '../concurrency/identity-optimistic-concurrency-guard.js';
import { IdentityVersionConflictError } from '../errors/identity-persistence-errors.js';
import type { PrismaClient } from '../generated/prisma/client.js';
import type { SessionRetentionEngine } from '../retention/session-retention-engine.js';
import { toSessionUnit } from '../snapshot/session-snapshot-mapper.js';

/**
 * PrismaSessionRepositoryAdapter — the real Session registry: STATE ONLY by
 * construction (the engine has no fact step, the schema has no Session
 * outbox table — the absence IS the conformity). The RetentionContext of
 * the port (RFC-001) is accepted and has nothing to ride to — by design.
 *
 * Channel discipline: a snapshot-pkey collision or stale version is the
 * transient Failure channel (thrown — S-3); corruption on load surfaces
 * raw (A-7); no Refusal is ever minted here (the acts refuse upstream).
 */
export class PrismaSessionRepositoryAdapter implements SessionRepository {
  constructor(
    private readonly prisma: PrismaClient,
    private readonly engine: SessionRetentionEngine,
  ) {}

  async byId(id: SessionId): Promise<Option<Session>> {
    const row = await this.prisma.sessionSnapshot.findUnique({ where: { sessionId: id } });
    return row === null ? none : some(toSessionUnit(row));
  }

  async activeByCredential(credentialId: CredentialId): Promise<readonly Session[]> {
    const rows = await this.prisma.sessionSnapshot.findMany({
      where: { credentialId, stateKind: 'Active' },
      orderBy: { sessionId: 'asc' },
    });
    return rows.map(toSessionUnit);
  }

  // The port's optional RetentionContext (RFC-001) is lawfully NOT declared
  // here: a session registry has nothing to carry it to (same choice as the
  // in-memory reference — fewer parameters conform structurally).
  async retain(unit: Session): Promise<Result<void, SessionRefusal>> {
    try {
      await this.prisma.$transaction(
        async (tx) => {
          await this.engine.retainWithin(tx, unit);
        },
        { isolationLevel: 'Serializable' },
      );
      return ok(undefined);
    } catch (error) {
      if (error instanceof IdentityVersionConflictError) {
        throw error;
      }
      if (classifyIdentityEngineError(error) === 'version-conflict') {
        throw new IdentityVersionConflictError(unit.id, unit.version - 1);
      }
      throw error;
    }
  }
}
