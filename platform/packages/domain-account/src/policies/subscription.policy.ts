import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { SubscriptionRefusal } from '../decisions/account-refusal.js';
import { subscriptionRefusal } from '../decisions/account-refusal.js';

/**
 * SubscriptionPolicy — the RATIFIED policy of the Subscription (catalogue
 * des policies; canon F3.2-B). RFC-003 P5 (ratified): PRODUCT parameters =
 * an explicit ALLOWLIST of offer references, nothing more. It judges
 * `StartSubscription` BEFORE the birth (same seam as ProofRequirementPolicy
 * before OpenSession). Built at the Root, injected, never en route.
 */
export interface SubscriptionPolicyParams {
  readonly admittedOffers: readonly string[];
}

export class SubscriptionPolicy {
  private readonly admitted: ReadonlySet<string>;

  constructor(configuration: SubscriptionPolicyParams) {
    this.admitted = new Set(configuration.admittedOffers.map((value) => value.trim()));
  }

  judge(offerReference: string): Result<void, SubscriptionRefusal> {
    if (this.admitted.has(offerReference.trim())) {
      return ok(undefined);
    }
    return err(
      subscriptionRefusal(
        'OfferUnavailable',
        `The offer '${offerReference}' is not admitted by the product`,
      ),
    );
  }
}
