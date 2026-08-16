import { invariant } from '@mentora/kernel';

import type { RelayEnvelope } from '../dispatch/relay-envelope.js';

import type { RelaySourcePort } from './relay-source-port.js';

/**
 * ClaimEngine — owns the claim POLICY (duration — technical config, I-5);
 * the ATOMICITY belongs to the source implementation (free mechanism:
 * conditional UPDATE, RETURNING, in-memory mutex). Two workers never hold
 * the same live claim; a crashed worker's claim expires and the row returns
 * to the claimable pool — correctness never rests on the claim (F5.1 §19).
 */
export class ClaimEngine {
  constructor(
    private readonly source: RelaySourcePort,
    private readonly claimDurationMillis: number,
  ) {
    invariant(claimDurationMillis > 0, 'a claim lives for a positive duration');
  }

  claim(limit: number, nowMs: number): Promise<readonly RelayEnvelope[]> {
    return this.source.claimBatch({
      limit,
      nowMs,
      claimedUntilMs: nowMs + this.claimDurationMillis,
    });
  }
}
