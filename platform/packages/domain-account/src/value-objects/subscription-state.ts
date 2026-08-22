import type { Instant } from '@mentora/kernel';

/**
 * The frozen machine of the Subscription (catalogue §8 n°6): `Active →
 * Ended`, terminal. RFC-003 P4 (ratified): Active AT StartSubscription —
 * no `Pending` exists; the Settlement's verdict arrives as a reaction that
 * may END it (Lot A03). R-B: re-subscribing is a NEW unit.
 */
export type SubscriptionState =
  | { readonly kind: 'Active'; readonly startedAt: Instant }
  | { readonly kind: 'Ended'; readonly endedAt: Instant; readonly motive: string };

/**
 * The frozen machine of the SupportRequest (catalogue §8 n°7): `Opened →
 * Handled`, terminal. No fact is ever published (canon: "droit, pas
 * devoir"; the dialogues are Conversations).
 */
export type SupportRequestState =
  | { readonly kind: 'Opened'; readonly openedAt: Instant }
  | { readonly kind: 'Handled'; readonly handledAt: Instant };
