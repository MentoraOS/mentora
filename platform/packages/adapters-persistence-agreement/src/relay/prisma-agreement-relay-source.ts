import type {
  RelayBacklog,
  RelayClaimRequest,
  RelayEnvelope,
  RelaySourcePort,
} from '@mentora/runtime-relay';
import type { PrismaClient } from '@prisma/client';

/**
 * PrismaAgreementRelaySource — the SQL binding of the Agreement Outbox de
 * faits (2B-1) to the relay's source port (2B-2), announced by the 2B-2
 * README and born with the 0002 EXPAND migration (S-7). ADDITIVE file: no
 * 2B-1 source touched; the retention keeps writing 'pending' rows exactly
 * as before.
 *
 * The eligibility contract (RelaySourcePort) in ONE claim transaction:
 * pending + due + unclaimed/expired + no earlier unpublished row of the
 * same subject; oldest first; the claim is a conditional UPDATE inside a
 * serialized transaction (atomic — a lease-optimization, never a guardian,
 * F5.1 §19). Proven by the relayContractSuite against the real engine.
 */
export class PrismaAgreementRelaySource implements RelaySourcePort {
  constructor(private readonly prisma: PrismaClient) {}

  async claimBatch(request: RelayClaimRequest): Promise<readonly RelayEnvelope[]> {
    return this.prisma.$transaction(
      async (tx) => {
        const rows = await tx.$queryRaw<
          Array<{
            id: bigint;
            messageId: string;
            agreementId: string;
            sequence: number;
            correlationId: string | null;
            causationId: string | null;
            deliveryAttempts: number;
            payload: string;
            occurredAtMs: bigint;
          }>
        >`
          SELECT o."id", o."messageId", o."agreementId", o."sequence",
                 o."correlationId", o."causationId", o."deliveryAttempts",
                 o."payload", o."occurredAtMs"
          FROM "AgreementOutbox" o
          WHERE o."status" = 'pending'
            AND o."nextAttemptAtMs" <= ${BigInt(request.nowMs)}
            AND o."claimedUntilMs" <= ${BigInt(request.nowMs)}
            AND NOT EXISTS (
              -- ONE in-flight envelope per subject; a struggling subject
              -- (delayed, claimed or quarantined predecessor) holds ITS OWN
              -- successors and never the other subjects (F4.3 §4 / M-8).
              SELECT 1 FROM "AgreementOutbox" earlier
              WHERE earlier."agreementId" = o."agreementId"
                AND earlier."sequence" < o."sequence"
                AND earlier."status" <> 'published'
            )
          ORDER BY o."id" ASC
          LIMIT ${request.limit}
          FOR UPDATE OF o SKIP LOCKED
        `;
        if (rows.length > 0) {
          await tx.agreementOutbox.updateMany({
            where: { id: { in: rows.map((row) => row.id) } },
            data: { claimedUntilMs: BigInt(request.claimedUntilMs) },
          });
        }
        return rows.map((row) => ({
          messageId: row.messageId,
          subjectKey: row.agreementId,
          sequence: row.sequence,
          payload: row.payload,
          occurredAtMs: Number(row.occurredAtMs),
          ...(row.correlationId !== null ? { correlationId: row.correlationId } : {}),
          ...(row.causationId !== null ? { causationId: row.causationId } : {}),
          deliveryAttempts: row.deliveryAttempts,
        }));
      },
    );
  }

  async markPublished(messageId: string): Promise<void> {
    await this.prisma.agreementOutbox.update({
      where: { messageId },
      data: { status: 'published', claimedUntilMs: BigInt(0) },
    });
  }

  async recordAttempt(messageId: string, nextAttemptAtMs: number): Promise<void> {
    await this.prisma.agreementOutbox.update({
      where: { messageId },
      data: {
        deliveryAttempts: { increment: 1 },
        nextAttemptAtMs: BigInt(nextAttemptAtMs),
        claimedUntilMs: BigInt(0),
      },
    });
  }

  async quarantine(messageId: string, reason: string): Promise<void> {
    await this.prisma.agreementOutbox.update({
      where: { messageId },
      data: { status: 'quarantined', quarantineReason: reason, claimedUntilMs: BigInt(0) },
    });
  }

  async backlog(nowMs: number): Promise<RelayBacklog> {
    const [pending, retrying, quarantined, oldest] = await Promise.all([
      this.prisma.agreementOutbox.count({ where: { status: 'pending' } }),
      this.prisma.agreementOutbox.count({
        where: { status: 'pending', deliveryAttempts: { gt: 0 } },
      }),
      this.prisma.agreementOutbox.count({ where: { status: 'quarantined' } }),
      this.prisma.agreementOutbox.findFirst({
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
