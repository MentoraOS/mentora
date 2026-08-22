import type {
  AccountClosed,
  AvailabilityFrameChanged,
  PersonRegistered,
  PreferenceChanged,
  ReachabilityChanged,
} from '../events/account-events.js';

/**
 * The closed unions of the Lot A01 facts (precedent: credential-domain-event).
 * Live in aggregate/ — events/ is reserved to the facts themselves
 * (<Truth><PastParticiple>, MENTORA0003).
 */
export type AccountDomainEvent =
  | PersonRegistered
  | PreferenceChanged
  | ReachabilityChanged
  | AccountClosed;

export type AvailabilityFrameDomainEvent = AvailabilityFrameChanged;
