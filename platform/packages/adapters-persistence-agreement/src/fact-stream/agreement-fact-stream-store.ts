import type { AgreementDomainEvent } from '@mentora/domain-agreement';
import type { Prisma } from '@prisma/client';

import { toFactRow } from './agreement-fact-mapper.js';

/**
 * AgreementFactStreamStore — the append-only fact stream (RC-1 §3): the
 * eternal provenance (O-4). Append happens INSIDE the retention transaction;
 * unique(agreementId, sequence) is the structural idempotence. Reading back
 * is the owner-side relecture (provenance, Réadmission S-6, replay tooling)
 * — ordered per unit subject only (F4.3 §4). No UPDATE, no DELETE, ever (S-9).
 */
export class AgreementFactStreamStore {
  async append(tx: Prisma.TransactionClient, facts: readonly AgreementDomainEvent[]): Promise<void> {
    await tx.agreementFact.createMany({ data: facts.map(toFactRow) });
  }

  async readStream(
    tx: Prisma.TransactionClient,
    agreementId: string,
  ): Promise<readonly { sequence: number; type: string; payload: string; checksum: string }[]> {
    const rows = await tx.agreementFact.findMany({
      where: { agreementId },
      orderBy: { sequence: 'asc' },
      select: { sequence: true, type: true, payload: true, checksum: true },
    });
    return rows;
  }
}
