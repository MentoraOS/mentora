import type { Session } from '@mentora/domain-identity';


import { previousSessionVersionOf } from '../concurrency/identity-optimistic-concurrency-guard.js';
import { IdentityVersionConflictError } from '../errors/identity-persistence-errors.js';
import type { Prisma } from '../generated/prisma/client.js';
import { toSessionRow } from '../snapshot/session-snapshot-mapper.js';

/**
 * SessionRetentionEngine — the atomic act, STATE ONLY: (1) version control →
 * (2) snapshot → (3) commit. There is NO step for facts and NO step for an
 * outbox — not skipped: STRUCTURALLY ABSENT, exactly like the unit's missing
 * pendingFacts field and the schema's missing Session tables ("aucun fait
 * publié"; what has no code path cannot leak). A RetentionContext offered by
 * the port is lawfully accepted upstream and has nothing to ride to here.
 */
export class SessionRetentionEngine {
  async retainWithin(tx: Prisma.TransactionClient, unit: Session): Promise<void> {
    const row = toSessionRow(unit);
    const previousVersion = previousSessionVersionOf(unit);

    if (previousVersion > 0) {
      const current = await tx.sessionSnapshot.findUnique({
        where: { sessionId: row.sessionId },
        select: { version: true },
      });
      if (current === null || current.version !== previousVersion) {
        throw new IdentityVersionConflictError(row.sessionId, previousVersion);
      }
    }

    if (previousVersion === 0) {
      await tx.sessionSnapshot.create({ data: row });
    } else {
      const updated = await tx.sessionSnapshot.updateMany({
        where: { sessionId: row.sessionId, version: previousVersion },
        data: { ...row },
      });
      if (updated.count === 0) {
        throw new IdentityVersionConflictError(row.sessionId, previousVersion);
      }
    }
  }
}
