import type { Instant } from '@mentora/kernel';

import type { PersonId, SubscriptionId } from '../ids/identifiers.js';

/**
 * The facts of the Subscription — the last two of the seven ratified events
 * of the context (catalogue 45-46). References and natures: the holder, the
 * offer reference, the motive. The SupportRequest publishes NOTHING (canon)
 * — no fact of its exists, here or anywhere.
 */

export interface SubscriptionStarted {
  readonly type: 'SubscriptionStarted';
  readonly subscriptionId: SubscriptionId;
  readonly sequence: number;
  readonly instant: Instant;
  readonly personId: PersonId;
  readonly offerReference: string;
}

export interface SubscriptionEnded {
  readonly type: 'SubscriptionEnded';
  readonly subscriptionId: SubscriptionId;
  readonly sequence: number;
  readonly instant: Instant;
  readonly motive: string;
}
