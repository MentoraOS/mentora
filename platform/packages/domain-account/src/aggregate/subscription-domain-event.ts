import type { SubscriptionEnded, SubscriptionStarted } from '../events/subscription-events.js';

/** The closed union of the Subscription facts (MENTORA0003: unions live outside events/). */
export type SubscriptionDomainEvent = SubscriptionStarted | SubscriptionEnded;
