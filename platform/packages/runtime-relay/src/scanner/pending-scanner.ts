import { invariant } from '@mentora/kernel';

import type { ClaimEngine } from '../claim/claim-engine.js';
import type { RelayEnvelope } from '../dispatch/relay-envelope.js';

/**
 * PendingScanner — the batch reader: stable oldest-first order (which
 * preserves per-subject sequence order by construction), bounded batches
 * (technical config, I-5), pagination by successive claims. Starvation
 * protection is STRUCTURAL, not heuristic: eligibility (encoded in the
 * source port's contract) skips only the successors of a struggling
 * subject — every other subject flows (M-8: a poison never blocks the
 * queue). Zero business logic: the scanner never reads a payload.
 */
export class PendingScanner {
  constructor(
    private readonly claims: ClaimEngine,
    private readonly batchSize: number,
  ) {
    invariant(batchSize >= 1, 'a batch carries at least one envelope');
  }

  /** One page of claimed work — call again for the next page (pagination). */
  nextBatch(nowMs: number): Promise<readonly RelayEnvelope[]> {
    return this.claims.claim(this.batchSize, nowMs);
  }
}
