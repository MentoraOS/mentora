import type { Credential } from '@mentora/domain-identity';
import type { RetentionContext } from '@mentora/kernel';


import { previousCredentialVersionOf } from '../concurrency/identity-optimistic-concurrency-guard.js';
import { IdentityVersionConflictError } from '../errors/identity-persistence-errors.js';
import type { CredentialFactStreamStore } from '../fact-stream/credential-fact-stream-store.js';
import type { Prisma } from '../generated/prisma/client.js';
import type { CredentialOutboxStore } from '../outbox/credential-outbox-store.js';
import { toCredentialRow } from '../snapshot/credential-snapshot-mapper.js';

/**
 * CredentialRetentionEngine — the atomic act (pas 8), EXACTLY the Blueprint
 * order: (1) version control → (2) fact-stream append → (3) snapshot →
 * (4) Outbox de faits → (5) commit (the caller's transaction boundary).
 * The retention talks to NO ONE (A-3: no port, no network, no publish, no
 * business log). RFC-001: the optional context rides to the outbox only.
 *
 * The engine THROWS on every collision — a PostgreSQL constraint violation
 * aborts the transaction, so the classification into lawful channels
 * (Refusal vs Failure) happens OUTSIDE the transaction, in the facade,
 * after the rollback: nothing partial ever exists.
 */
export class CredentialRetentionEngine {
  constructor(
    private readonly factStream: CredentialFactStreamStore,
    private readonly outbox: CredentialOutboxStore,
  ) {}

  async retainWithin(
    tx: Prisma.TransactionClient,
    unit: Credential,
    context?: RetentionContext,
  ): Promise<void> {
    const facts = unit.pendingFacts;
    const row = toCredentialRow(unit);
    const previousVersion = previousCredentialVersionOf(unit);

    // (1) version control — the declared expectation, checked first (S-3).
    if (previousVersion > 0) {
      const current = await tx.credentialSnapshot.findUnique({
        where: { credentialId: row.credentialId },
        select: { version: true },
      });
      if (current === null || current.version !== previousVersion) {
        throw new IdentityVersionConflictError(row.credentialId, previousVersion);
      }
    }

    // (2) fact-stream append (idempotence by unique(credentialId, sequence)).
    await this.factStream.append(tx, facts);

    // (3) the private photograph — the conditional write IS the TOCTOU-safe
    // guard (the step-1 read fast-fails; this write decides).
    if (previousVersion === 0) {
      await tx.credentialSnapshot.create({ data: row });
    } else {
      const updated = await tx.credentialSnapshot.updateMany({
        where: { credentialId: row.credentialId, version: previousVersion },
        data: { ...row },
      });
      if (updated.count === 0) {
        throw new IdentityVersionConflictError(row.credentialId, previousVersion);
      }
    }

    // (4) the Outbox de faits — same atomic act (A-3); the relay will read.
    await this.outbox.write(tx, facts, context);
  }
}
