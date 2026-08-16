import type { RelayBacklog, RelayEnvelope } from '../dispatch/relay-envelope.js';

/**
 * RelaySourcePort — the relay's OWN port over the retained rows (I-4: a port
 * belongs to its CONSUMER — the relay is the consumer of every owner's
 * Outbox de faits/commandes; the storage adapter below implements it, I-12).
 *
 * THE CLAIM IS A LEASE-OPTIMIZATION, NEVER A GUARDIAN (F5.1 §19, verbatim:
 * "licite comme optimisation, jamais comme gardien — aucun invariant métier
 * ne repose jamais sur un lease"): claimBatch atomically marks rows claimed
 * until `claimedUntilMs`; an EXPIRED claim becomes claimable again ("les
 * restes d'un crash sont des déchets" — l'Outbox pardonne, F4.4 §6). A
 * double delivery after claim expiry is LAWFUL at-least-once — the unique
 * EFFECT is produced downstream by the consumer Inboxes (A-5).
 *
 * ELIGIBILITY contract (the scanner's law, encoded here so every
 * implementation exhibits it — proven by the contract suite):
 * - status pending, next attempt due, claim absent or expired;
 * - AND no earlier unpublished message of the SAME subjectKey (lower
 *   sequence still pending/retrying/claimed/quarantined): order is promised
 *   per unit subject (F4.3 §4) — a struggling subject holds ITS OWN
 *   successors and NEVER the other subjects (M-8: a poison never blocks
 *   the queue — that is the starvation protection).
 * - Stable order: oldest first (insertion order), which preserves
 *   per-subject sequence order by construction.
 */
export interface RelayClaimRequest {
  readonly limit: number;
  readonly nowMs: number;
  readonly claimedUntilMs: number;
}

export interface RelaySourcePort {
  claimBatch(request: RelayClaimRequest): Promise<readonly RelayEnvelope[]>;

  /** ACK — pending → published. NEVER a deletion (the row is history). */
  markPublished(messageId: string): Promise<void>;

  /** A failed delivery: attempts+1, next try at the given instant (backoff). */
  recordAttempt(messageId: string, nextAttemptAtMs: number): Promise<void>;

  /** Beyond the budget: parked, never deleted (M-8 — the Quarantaine). */
  quarantine(messageId: string, reason: string): Promise<void>;

  /** The health/metrics reading of the backlog. */
  backlog(nowMs: number): Promise<RelayBacklog>;
}
