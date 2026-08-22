import type {
  AccountClosed,
  AvailabilityFrameChanged,
  PersonRegistered,
  PreferenceChanged,
  ReachabilityChanged,
  SubscriptionEnded,
  SubscriptionStarted,
} from '../events/account-event-contracts.js';

/**
 * The closed union of the Account wire facts (precedent: contracts-identity
 * wire/event-union). Lives OUTSIDE events/ — that directory is reserved to
 * the facts themselves (<Truth><PastParticiple>, MENTORA0003).
 */
export type AccountEventContract =
  | PersonRegistered
  | PreferenceChanged
  | ReachabilityChanged
  | AccountClosed
  | AvailabilityFrameChanged
  | SubscriptionStarted
  | SubscriptionEnded;

export const ACCOUNT_EVENT_TYPES = [
  'PersonRegistered',
  'PreferenceChanged',
  'ReachabilityChanged',
  'AccountClosed',
  'AvailabilityFrameChanged',
  'SubscriptionStarted',
  'SubscriptionEnded',
] as const;
