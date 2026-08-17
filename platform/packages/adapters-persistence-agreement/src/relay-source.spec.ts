import { environmentSource } from '@mentora/runtime-config';
import type { RelayEnvelope } from '@mentora/runtime-relay';
import { relayContractSuite } from '@mentora/runtime-relay/contract-suite';
import { afterAll, describe, expect, it } from 'vitest';

import { PrismaAgreementRelaySource } from './relay/prisma-agreement-relay-source.js';
import { AgreementPersistenceFixture } from './testing/agreement-persistence-fixture.js';
import { AgreementPersistenceMother } from './testing/agreement-persistence-mother.js';

/**
 * The SQL binding of the Agreement Outbox de faits to the relay's source
 * port — the 2B-2 contract suite REPLAYED against the real engine: the
 * PostgreSQL implementation must exhibit exactly the reference behavior.
 */

const url = environmentSource().read('MENTORA_AGREEMENT_DATABASE_URL');

describe.skipIf(url === undefined)('PrismaAgreementRelaySource (real engine)', () => {
  const fixture = new AgreementPersistenceFixture(url ?? '');

  afterAll(async () => {
    await fixture.dispose();
  });

  const seed = async (envelope: RelayEnvelope): Promise<void> => {
    await fixture.prisma.agreementOutbox.create({
      data: {
        messageId: envelope.messageId,
        agreementId: envelope.subjectKey,
        sequence: envelope.sequence,
        payload: envelope.payload,
        occurredAtMs: BigInt(envelope.occurredAtMs),
        deliveryAttempts: envelope.deliveryAttempts,
        ...(envelope.correlationId !== undefined ? { correlationId: envelope.correlationId } : {}),
        ...(envelope.causationId !== undefined ? { causationId: envelope.causationId } : {}),
      },
    });
  };

  relayContractSuite('PrismaAgreementRelaySource', {
    make: async () => {
      await fixture.truncate();
      return { source: new PrismaAgreementRelaySource(fixture.prisma), seed };
    },
  });

  it('the RETAINED outbox rows are claimable by the relay — the loop closes (A-3 → A-4)', async () => {
    await fixture.truncate();
    const mother = new AgreementPersistenceMother();
    await fixture.repository.retain(mother.confirmed());
    const source = new PrismaAgreementRelaySource(fixture.prisma);
    const first = await source.claimBatch({ limit: 10, nowMs: 1, claimedUntilMs: 10_000 });
    // Per-subject order: ONE in-flight envelope for the one agreement.
    expect(first.map((envelope) => envelope.sequence)).toEqual([1]);
    await source.markPublished(first[0]?.messageId ?? '');
    const second = await source.claimBatch({ limit: 10, nowMs: 2, claimedUntilMs: 10_000 });
    expect(second.map((envelope) => envelope.sequence)).toEqual([2]);
  });
});
