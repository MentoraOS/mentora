import type { Agreement } from '@mentora/domain-agreement';
import type { Prisma } from '@prisma/client';

import { previousVersionOf } from '../concurrency/agreement-optimistic-concurrency-guard.js';
import { AgreementVersionConflictError } from '../errors/agreement-persistence-errors.js';
import type { AgreementFactStreamStore } from '../fact-stream/agreement-fact-stream-store.js';
import type { AgreementOutboxStore } from '../outbox/agreement-outbox-store.js';
import { toSnapshotRow } from '../snapshot/agreement-snapshot-mapper.js';

/**
 * AgreementRetentionEngine — the atomic act (pas 8), EXACTLY the Blueprint
 * order: (1) version control → (2) fact-stream append → (3) snapshot →
 * (4) Outbox de faits → (5) commit (the caller's transaction boundary).
 * The retention talks to NO ONE (A-3: no port, no network, no publish, no
 * business log).
 *
 * The engine THROWS on every collision — a PostgreSQL constraint violation
 * aborts the transaction, so the classification into lawful channels
 * (Refusal vs Failure) happens OUTSIDE the transaction, in the facade,
 * after the rollback: nothing partial ever exists.
 */
export class AgreementRetentionEngine {
  constructor(
    private readonly factStream: AgreementFactStreamStore,
    private readonly outbox: AgreementOutboxStore,
  ) {}

  async retainWithin(tx: Prisma.TransactionClient, unit: Agreement): Promise<void> {
    const facts = unit.pendingFacts;
    const row = toSnapshotRow(unit);
    const previousVersion = previousVersionOf(unit);

    // (1) version control — the declared expectation, checked first (S-3).
    if (previousVersion > 0) {
      const current = await tx.agreementSnapshot.findUnique({
        where: { agreementId: row.agreementId },
        select: { version: true },
      });
      if (current === null || current.version !== previousVersion) {
        throw new AgreementVersionConflictError(row.agreementId, previousVersion);
      }
    }

    // (2) fact-stream append (idempotence by unique(agreementId, sequence)).
    await this.factStream.append(tx, facts);

    // (3) the private photograph — the conditional write IS the TOCTOU-safe
    // guard (the step-1 read fast-fails; this write decides).
    if (previousVersion === 0) {
      await tx.agreementSnapshot.create({ data: row });
    } else {
      const updated = await tx.agreementSnapshot.updateMany({
        where: { agreementId: row.agreementId, version: previousVersion },
        data: { ...row },
      });
      if (updated.count === 0) {
        throw new AgreementVersionConflictError(row.agreementId, previousVersion);
      }
    }

    // (4) the Outbox de faits — same atomic act (A-3); the relay will read.
    await this.outbox.write(tx, facts);
  }
}
