import type { Result } from '@mentora/kernel';
import { ok } from '@mentora/kernel';

import { Subscription } from '../aggregate/subscription.js';
import { SupportRequest } from '../aggregate/support-request.js';
import type { OpenSupportRequest, StartSubscription } from '../commands/subscription-commands.js';
import type { SubscriptionRefusal, SupportRequestRefusal } from '../decisions/account-refusal.js';
import type { SubscriptionPolicy } from '../policies/subscription.policy.js';

/**
 * The birth doors of Lot A02 (F3.1).
 *
 * `startSubscription` — the canon's `SubscriptionFactory` (43): the
 * RATIFIED SubscriptionPolicy judges the offer BEFORE the birth (same seam
 * as ProofRequirementPolicy before OpenSession); the R-A key is the
 * registry's at retention. RFC-003 P4: born Active.
 *
 * `openSupportRequest` (45) — birth without a fact, by construction.
 */
export const startSubscription = (
  command: StartSubscription,
  policy: SubscriptionPolicy,
): Result<Subscription, SubscriptionRefusal> => {
  const judged = policy.judge(command.offerReference);
  if (!judged.ok) {
    return judged;
  }
  return ok(Subscription._born(command));
};

export const openSupportRequest = (
  command: OpenSupportRequest,
): Result<SupportRequest, SupportRequestRefusal> => ok(SupportRequest._born(command));
