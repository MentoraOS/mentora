import { environmentSource } from '@mentora/runtime-config';
import type { RelayEnvelope } from '@mentora/runtime-relay';
import { relayContractSuite } from '@mentora/runtime-relay/contract-suite';
import { afterAll, describe, expect, it } from 'vitest';

import { PrismaIdentityRelaySource } from './relay/prisma-identity-relay-source.js';
import { IdentityPersistenceFixture } from './testing/identity-persistence-fixture.js';
import { IdentityPersistenceMother } from './testing/identity-persistence-mother.js';

/**
 * The SQL binding of the Credential Outbox de faits to the relay's source
 * port (Task #77) — the relay contract suite REPLAYED against the real
 * engine: the PostgreSQL implementation must exhibit exactly the reference
 * behavior.
 */

const url = environmentSource().read('MENTORA_IDENTITY_DATABASE_URL');

describe.skipIf(url === undefined)('PrismaIdentityRelaySource (real engine)', () => {
  const fixture = new IdentityPersistenceFixture(url ?? '');

  afterAll(async () => {
    await fixture.dispose();
  });

  const seed = async (envelope: RelayEnvelope): Promise<void> => {
    await fixture.prisma.credentialOutbox.create({
      data: {
        messageId: envelope.messageId,
        credentialId: envelope.subjectKey,
        sequence: envelope.sequence,
        payload: envelope.payload,
        occurredAtMs: BigInt(envelope.occurredAtMs),
        deliveryAttempts: envelope.deliveryAttempts,
        ...(envelope.correlationId !== undefined ? { correlationId: envelope.correlationId } : {}),
        ...(envelope.causationId !== undefined ? { causationId: envelope.causationId } : {}),
      },
    });
  };

  relayContractSuite('PrismaIdentityRelaySource', {
    make: async () => {
      await fixture.truncate();
      return { source: new PrismaIdentityRelaySource(fixture.prisma), seed };
    },
  });

  it('the RETAINED outbox rows are claimable by the relay — the loop closes (A-3 → A-4)', async () => {
    await fixture.truncate();
    const mother = new IdentityPersistenceMother();
    await fixture.credentials.retain(mother.revoked('cred-1'), { correlationId: 'corr-e2e' });
    const source = new PrismaIdentityRelaySource(fixture.prisma);
    const first = await source.claimBatch({ limit: 10, nowMs: 1, claimedUntilMs: 10_000 });
    // Per-subject order: ONE in-flight envelope for the one credential.
    expect(first.map((envelope) => envelope.sequence)).toEqual([1]);
    // RFC-001 end to end: the envelope carries what the retention received.
    expect(first[0]?.correlationId).toBe('corr-e2e');
    await source.markPublished(first[0]?.messageId ?? '');
    const second = await source.claimBatch({ limit: 10, nowMs: 2, claimedUntilMs: 10_000 });
    expect(second.map((envelope) => envelope.sequence)).toEqual([2]);
  });
});
