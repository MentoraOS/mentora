import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { AccountRefusal } from '../decisions/account-refusal.js';
import { accountRefusal } from '../decisions/account-refusal.js';
import type { ReachabilityChannel } from '../value-objects/reachability-channel.js';

/**
 * ReachabilityPolicy — the RATIFIED policy of the Account (catalogue des
 * policies; canon F3.2-B: owned by the Account, consumed by the
 * Notification). RFC-003 P5 (ratified): its parameters are PRODUCT
 * configuration — an explicit ALLOWLIST of channels, nothing more; no
 * semantics beyond membership exists without a written product decision.
 * Built at the Root with its params, injected, never instantiated en route.
 */
export interface ReachabilityPolicyParams {
  readonly admittedChannels: readonly string[];
}

export class ReachabilityPolicy {
  private readonly admitted: ReadonlySet<string>;

  constructor(configuration: ReachabilityPolicyParams) {
    this.admitted = new Set(configuration.admittedChannels.map((value) => value.toLowerCase()));
  }

  judge(channel: ReachabilityChannel): Result<void, AccountRefusal> {
    if (this.admitted.has(channel)) {
      return ok(undefined);
    }
    return err(
      accountRefusal('ChannelUnavailable', `The channel '${channel}' is not admitted by the product`),
    );
  }
}
