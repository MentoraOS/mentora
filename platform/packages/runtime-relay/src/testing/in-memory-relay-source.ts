import type { RelayClaimRequest, RelaySourcePort } from '../claim/relay-source-port.js';
import type { RelayBacklog, RelayEnvelope } from '../dispatch/relay-envelope.js';

/**
 * InMemoryRelaySource — the REFERENCE implementation of the source port's
 * eligibility contract (see RelaySourcePort): pending + due + unexpired-
 * unclaimed + no earlier unpublished message of the same subject; oldest
 * first; claims atomic (single-threaded by construction here — a SQL
 * implementation uses a conditional UPDATE). Rows never disappear:
 * pending → claimed → published | pending(retrying) | quarantined.
 */

interface SourceRow {
  envelope: RelayEnvelope;
  status: 'pending' | 'published' | 'quarantined';
  claimedUntilMs: number;
  nextAttemptAtMs: number;
  insertedAt: number;
  reason?: string;
}

export class InMemoryRelaySource implements RelaySourcePort {
  private readonly rows: SourceRow[] = [];
  private insertions = 0;
  /** Injectable outage: when set, every call throws (health/readiness specs). */
  unreachable = false;

  seed(envelope: RelayEnvelope): void {
    this.rows.push({
      envelope,
      status: 'pending',
      claimedUntilMs: 0,
      nextAttemptAtMs: 0,
      insertedAt: (this.insertions += 1),
    });
  }

  claimBatch(request: RelayClaimRequest): Promise<readonly RelayEnvelope[]> {
    this.guard();
    const blockedSubjects = new Set<string>();
    for (const row of this.rows) {
      const unpublished = row.status !== 'published';
      const held =
        row.status === 'quarantined' ||
        (row.status === 'pending' &&
          (row.nextAttemptAtMs > request.nowMs || row.claimedUntilMs > request.nowMs));
      if (unpublished && held) {
        blockedSubjects.add(row.envelope.subjectKey);
      }
    }
    const claimed: RelayEnvelope[] = [];
    for (const row of [...this.rows].sort((a, b) => a.insertedAt - b.insertedAt)) {
      if (claimed.length >= request.limit) {
        break;
      }
      if (row.status !== 'pending') {
        continue;
      }
      if (row.nextAttemptAtMs > request.nowMs || row.claimedUntilMs > request.nowMs) {
        continue;
      }
      if (blockedSubjects.has(row.envelope.subjectKey)) {
        continue;
      }
      row.claimedUntilMs = request.claimedUntilMs;
      // A later message of this subject must not be claimed in the same pass.
      blockedSubjects.add(row.envelope.subjectKey);
      claimed.push(row.envelope);
    }
    return Promise.resolve(claimed);
  }

  markPublished(messageId: string): Promise<void> {
    this.guard();
    const row = this.rowOf(messageId);
    row.status = 'published';
    return Promise.resolve();
  }

  recordAttempt(messageId: string, nextAttemptAtMs: number): Promise<void> {
    this.guard();
    const row = this.rowOf(messageId);
    row.envelope = { ...row.envelope, deliveryAttempts: row.envelope.deliveryAttempts + 1 };
    row.nextAttemptAtMs = nextAttemptAtMs;
    row.claimedUntilMs = 0;
    return Promise.resolve();
  }

  quarantine(messageId: string, reason: string): Promise<void> {
    this.guard();
    const row = this.rowOf(messageId);
    row.status = 'quarantined';
    row.reason = reason;
    row.claimedUntilMs = 0;
    return Promise.resolve();
  }

  backlog(nowMs: number): Promise<RelayBacklog> {
    this.guard();
    const pending = this.rows.filter((row) => row.status === 'pending');
    const retrying = pending.filter((row) => row.envelope.deliveryAttempts > 0);
    const oldest = pending.reduce<number | undefined>(
      (acc, row) => (acc === undefined ? row.envelope.occurredAtMs : Math.min(acc, row.envelope.occurredAtMs)),
      undefined,
    );
    return Promise.resolve({
      pending: pending.length,
      retrying: retrying.length,
      quarantined: this.rows.filter((row) => row.status === 'quarantined').length,
      oldestPendingAgeMs: oldest === undefined ? undefined : nowMs - oldest,
    });
  }

  /** Test-side reading — the rows as history (nothing ever deleted). */
  statuses(): ReadonlyArray<readonly [string, string]> {
    return this.rows.map((row) => [row.envelope.messageId, row.status] as const);
  }

  reasonOf(messageId: string): string | undefined {
    return this.rows.find((row) => row.envelope.messageId === messageId)?.reason;
  }

  private rowOf(messageId: string): SourceRow {
    const row = this.rows.find((candidate) => candidate.envelope.messageId === messageId);
    if (row === undefined) {
      throw new Error(`no relay row '${messageId}'`);
    }
    return row;
  }

  private guard(): void {
    if (this.unreachable) {
      throw new Error('relay source unreachable');
    }
  }
}
