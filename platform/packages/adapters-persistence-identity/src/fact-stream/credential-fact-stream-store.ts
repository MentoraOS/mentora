import type { CredentialDomainEvent } from '@mentora/domain-identity';

import type { Prisma } from '../generated/prisma/client.js';

import { toFactRow } from './credential-fact-mapper.js';

/**
 * CredentialFactStreamStore — the append-only fact stream (RC-1 §3): the
 * eternal provenance (O-4). Append happens INSIDE the retention transaction;
 * unique(credentialId, sequence) is the structural idempotence. No UPDATE,
 * no DELETE, ever (S-9).
 */
export class CredentialFactStreamStore {
  async append(tx: Prisma.TransactionClient, facts: readonly CredentialDomainEvent[]): Promise<void> {
    await tx.credentialFact.createMany({ data: facts.map(toFactRow) });
  }

  async readStream(
    tx: Prisma.TransactionClient,
    credentialId: string,
  ): Promise<readonly { sequence: number; type: string; payload: string; checksum: string }[]> {
    const rows = await tx.credentialFact.findMany({
      where: { credentialId },
      orderBy: { sequence: 'asc' },
      select: { sequence: true, type: true, payload: true, checksum: true },
    });
    return rows;
  }
}
