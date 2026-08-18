import type {
  RelayBacklog,
  RelayClaimRequest,
  RelayEnvelope,
  RelaySourcePort,
} from '@mentora/runtime-relay';

import type { PrismaClient } from '../generated/prisma/client.js';

/**
 * PrismaIdentityRelaySource — the SQL binding of the Credential Outbox de
 * faits to the relay's source port (Task #77), replicated from the frozen
 * 2B-2 precedent. The eligibility contract in ONE claim transaction:
 * pending + due + unclaimed/expired + no earlier unpublished row of the
 * same subject; oldest first; the claim is a conditional UPDATE inside a
 * serialized transaction (a lease-optimization, never a guardian, F5.1
 * §19). Session facts CANNOT appear here: no Session outbox exists.
 */
export class PrismaIdentityRelaySource implements RelaySourcePort {
  constructor(private readonly prisma: PrismaClient) {}

  async claimBatch(request: RelayClaimRequest): Promise<readonly RelayEnvelope[]> {
    return this.prisma.$transaction(async (tx) => {
      const rows = await tx.$queryRaw<
        Array<{
          id: bigint;
          messageId: string;
          credentialId: string;
          sequence: number;
          correlationId: string | null;
          causationId: string | null;
          deliveryAttempts: number;
          payload: string;
          occurredAtMs: bigint;
        }>
      >`
          SELECT o."id", o."messageId", o."credentialId", o."sequence",
                 o."correlationId", o."causationId", o."deliveryAttempts",
                 o."payload", o."occurredAtMs"
          FROM "CredentialOutbox" o
          WHERE o."status" = 'pending'
            AND o."nextAttemptAtMs" <= ${BigInt(request.nowMs)}
            AND o."claimedUntilMs" <= ${BigInt(request.nowMs)}
            AND NOT EXISTS (
              -- ONE in-flight envelope per subject; a struggling subject
              -- holds ITS OWN successors and never the other subjects
              -- (F4.3 §4 / M-8).
              SELECT 1 FROM "CredentialOutbox" earlier
              WHERE earlier."credentialId" = o."credentialId"
                AND earlier."sequence" < o."sequence"
                AND earlier."status" <> 'published'
            )
          ORDER BY o."id" ASC
          LIMIT ${request.limit}
          FOR UPDATE OF o SKIP LOCKED
        `;
      if (rows.length > 0) {
        await tx.credentialOutbox.updateMany({
          where: { id: { in: rows.map((row) => row.id) } },
          data: { claimedUntilMs: BigInt(request.claimedUntilMs) },
        });
      }
      return rows.map((row) => ({
        messageId: row.messageId,
        subjectKey: row.credentialId,
        sequence: row.sequence,
        payload: row.payload,
        occurredAtMs: Number(row.occurredAtMs),
        ...(row.correlationId !== null ? { correlationId: row.correlationId } : {}),
        ...(row.causationId !== null ? { causationId: row.causationId } : {}),
        deliveryAttempts: row.deliveryAttempts,
      }));
    });
  }

  async markPublished(messageId: string): Promise<void> {
    await this.prisma.credentialOutbox.update({
      where: { messageId },
      data: { status: 'published', claimedUntilMs: BigInt(0) },
    });
  }

  async recordAttempt(messageId: string, nextAttemptAtMs: number): Promise<void> {
    await this.prisma.credentialOutbox.update({
      where: { messageId },
      data: {
        deliveryAttempts: { increment: 1 },
        nextAttemptAtMs: BigInt(nextAttemptAtMs),
        claimedUntilMs: BigInt(0),
      },
    });
  }

  async quarantine(messageId: string, reason: string): Promise<void> {
    await this.prisma.credentialOutbox.update({
      where: { messageId },
      data: { status: 'quarantined', quarantineReason: reason, claimedUntilMs: BigInt(0) },
    });
  }

  async backlog(nowMs: number): Promise<RelayBacklog> {
    const [pending, retrying, quarantined, oldest] = await Promise.all([
      this.prisma.credentialOutbox.count({ where: { status: 'pending' } }),
      this.prisma.credentialOutbox.count({
        where: { status: 'pending', deliveryAttempts: { gt: 0 } },
      }),
      this.prisma.credentialOutbox.count({ where: { status: 'quarantined' } }),
      this.prisma.credentialOutbox.findFirst({
        where: { status: 'pending' },
        orderBy: { occurredAtMs: 'asc' },
        select: { occurredAtMs: true },
      }),
    ]);
    return {
      pending,
      retrying,
      quarantined,
      oldestPendingAgeMs: oldest === null ? undefined : nowMs - Number(oldest.occurredAtMs),
    };
  }
}
