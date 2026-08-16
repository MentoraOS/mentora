import { describe, expect, it } from 'vitest';

import type { RelaySourcePort } from '../claim/relay-source-port.js';
import type { RelayEnvelope } from '../dispatch/relay-envelope.js';

/**
 * RelayContractSuite — the SOURCE PORT's promises written once (I-10):
 * every implementation (the in-memory reference today, the SQL binding of
 * an owner's Outbox tomorrow) must exhibit THE SAME eligibility, claim,
 * ack, retry and quarantine behavior.
 */

export interface RelaySourceProvider {
  make(): Promise<{
    source: RelaySourcePort;
    seed: (envelope: RelayEnvelope) => Promise<void> | void;
  }>;
}

export const envelopeOf = (
  messageId: string,
  subjectKey: string,
  sequence: number,
  occurredAtMs = 1_000,
): RelayEnvelope => ({
  messageId,
  subjectKey,
  sequence,
  payload: `{"opaque":"${messageId}"}`,
  occurredAtMs,
  deliveryAttempts: 0,
});

export const relayContractSuite = (name: string, provider: RelaySourceProvider): void => {
  describe(`RelaySourcePort contract — ${name}`, () => {
    it('claims oldest-first, bounded by the limit (stable order, pagination)', async () => {
      const { source, seed } = await provider.make();
      await seed(envelopeOf('m1', 'a', 1));
      await seed(envelopeOf('m2', 'b', 1));
      await seed(envelopeOf('m3', 'c', 1));
      const page1 = await source.claimBatch({ limit: 2, nowMs: 10_000, claimedUntilMs: 20_000 });
      expect(page1.map((envelope) => envelope.messageId)).toEqual(['m1', 'm2']);
      const page2 = await source.claimBatch({ limit: 2, nowMs: 10_000, claimedUntilMs: 20_000 });
      expect(page2.map((envelope) => envelope.messageId)).toEqual(['m3']);
    });

    it('a live claim excludes the row; an EXPIRED claim frees it (lease, never guardian)', async () => {
      const { source, seed } = await provider.make();
      await seed(envelopeOf('m1', 'a', 1));
      const first = await source.claimBatch({ limit: 10, nowMs: 10_000, claimedUntilMs: 20_000 });
      expect(first).toHaveLength(1);
      const during = await source.claimBatch({ limit: 10, nowMs: 15_000, claimedUntilMs: 25_000 });
      expect(during).toHaveLength(0);
      const after = await source.claimBatch({ limit: 10, nowMs: 21_000, claimedUntilMs: 31_000 });
      expect(after.map((envelope) => envelope.messageId)).toEqual(['m1']);
    });

    it('per-subject order: a struggling subject holds ITS successors, never the others', async () => {
      const { source, seed } = await provider.make();
      await seed(envelopeOf('a1', 'subject-a', 1));
      await seed(envelopeOf('a2', 'subject-a', 2));
      await seed(envelopeOf('b1', 'subject-b', 1));
      const first = await source.claimBatch({ limit: 10, nowMs: 10_000, claimedUntilMs: 20_000 });
      // ONE envelope per subject per pass (a2 waits for a1's fate).
      expect(first.map((envelope) => envelope.messageId)).toEqual(['a1', 'b1']);
      await source.recordAttempt('a1', 60_000);
      await source.markPublished('b1');
      const second = await source.claimBatch({ limit: 10, nowMs: 21_000, claimedUntilMs: 31_000 });
      // a1 is backing off → a2 is HELD; subject-b flows (nothing left there).
      expect(second).toHaveLength(0);
      const third = await source.claimBatch({ limit: 10, nowMs: 61_000, claimedUntilMs: 71_000 });
      expect(third.map((envelope) => envelope.messageId)).toEqual(['a1']);
    });

    it('a quarantined predecessor holds its subject; other subjects keep flowing (M-8)', async () => {
      const { source, seed } = await provider.make();
      await seed(envelopeOf('a1', 'subject-a', 1));
      await seed(envelopeOf('a2', 'subject-a', 2));
      await seed(envelopeOf('b1', 'subject-b', 1));
      await source.claimBatch({ limit: 10, nowMs: 10_000, claimedUntilMs: 20_000 });
      await source.quarantine('a1', 'poison');
      await source.markPublished('b1');
      const next = await source.claimBatch({ limit: 10, nowMs: 30_000, claimedUntilMs: 40_000 });
      expect(next).toHaveLength(0);
      await seed(envelopeOf('c1', 'subject-c', 1));
      const flowing = await source.claimBatch({ limit: 10, nowMs: 31_000, claimedUntilMs: 41_000 });
      expect(flowing.map((envelope) => envelope.messageId)).toEqual(['c1']);
    });

    it('ACK is pending → published — the row remains, never deleted', async () => {
      const { source, seed } = await provider.make();
      await seed(envelopeOf('m1', 'a', 1));
      await source.claimBatch({ limit: 1, nowMs: 10_000, claimedUntilMs: 20_000 });
      await source.markPublished('m1');
      const backlog = await source.backlog(30_000);
      expect(backlog.pending).toBe(0);
      const again = await source.claimBatch({ limit: 10, nowMs: 30_000, claimedUntilMs: 40_000 });
      expect(again).toHaveLength(0);
    });

    it('recordAttempt increments the ENVELOPE attempts and delays the row', async () => {
      const { source, seed } = await provider.make();
      await seed(envelopeOf('m1', 'a', 1));
      await source.claimBatch({ limit: 1, nowMs: 10_000, claimedUntilMs: 20_000 });
      await source.recordAttempt('m1', 50_000);
      const early = await source.claimBatch({ limit: 10, nowMs: 30_000, claimedUntilMs: 40_000 });
      expect(early).toHaveLength(0);
      const due = await source.claimBatch({ limit: 10, nowMs: 50_000, claimedUntilMs: 60_000 });
      expect(due[0]?.deliveryAttempts).toBe(1);
    });

    it('the backlog reading counts pending, retrying, quarantined and the oldest age', async () => {
      const { source, seed } = await provider.make();
      await seed(envelopeOf('m1', 'a', 1, 1_000));
      await seed(envelopeOf('m2', 'b', 1, 2_000));
      await seed(envelopeOf('m3', 'c', 1, 3_000));
      await source.claimBatch({ limit: 3, nowMs: 10_000, claimedUntilMs: 20_000 });
      await source.recordAttempt('m1', 50_000);
      await source.markPublished('m2');
      await source.quarantine('m3', 'poison');
      const backlog = await source.backlog(60_000);
      expect(backlog).toEqual({
        pending: 1,
        retrying: 1,
        quarantined: 1,
        oldestPendingAgeMs: 59_000,
      });
    });
  });
};
