import type { Subscription } from '../aggregate/subscription.js';

/**
 * SubscriptionChangeSpecification — the NAMED question of the Subscription's
 * transitions (catalogue des specifications: `SubscriptionChange`). The
 * canon names the machine (`Active → Ended`) and the commercial-contract
 * rule (a Subscription is a unit because it has a lifecycle and refusals of
 * its own); it names no further condition. Reading recorded: a change
 * (ending) is admissible iff the subscription is Active — the ONLY change
 * the ratified machine offers. Starting is a birth (the factory's door),
 * judged by the SubscriptionPolicy and the R-A key, not by this question.
 */
export class SubscriptionChangeSpecification {
  isSatisfiedBy(subscription: Subscription): boolean {
    return subscription.state.kind === 'Active';
  }
}
