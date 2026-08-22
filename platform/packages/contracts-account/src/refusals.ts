/**
 * Refusal reasons of the Account context — the negative half of the published
 * contract (F3.1.14: a Refusal is a VALUE of full rank).
 *
 * `TransitionUnavailable` — the ratified generic of the frozen machine (R-B;
 * same word as the Agreement and Identity precedents).
 * `DeviceUnavailable`, `ChannelUnavailable`, `WindowUnavailable`,
 * `OfferUnavailable` — DERIVE from the ratified `-Unavailable` refusal family
 * (F3.2-A: the family is law, the member derives): an unknown device name, a
 * channel the ReachabilityPolicy does not admit, a window set the
 * CoherentFrameSpecification refuses, an offer the SubscriptionPolicy does
 * not admit. Dictionary ruling recorded as pending (same posture as
 * ProofUnavailable).
 * `SubscriptionAlreadyExists` — the R-A key's refusal, from the ratified
 * `<Truth>AlreadyExists` family (F3.2-B: `MembershipAlreadyExists`; Identity:
 * `CredentialAlreadyExists`): an ACTIVE Subscription already exists for this
 * holder.
 */

export type AccountRefusalReason =
  | 'TransitionUnavailable'
  | 'DeviceUnavailable'
  | 'ChannelUnavailable';
export const ACCOUNT_REFUSAL_REASONS: readonly AccountRefusalReason[] = [
  'TransitionUnavailable',
  'DeviceUnavailable',
  'ChannelUnavailable',
];

export type AvailabilityFrameRefusalReason = 'TransitionUnavailable' | 'WindowUnavailable';
export const AVAILABILITY_FRAME_REFUSAL_REASONS: readonly AvailabilityFrameRefusalReason[] = [
  'TransitionUnavailable',
  'WindowUnavailable',
];

export type SubscriptionRefusalReason =
  | 'TransitionUnavailable'
  | 'SubscriptionAlreadyExists'
  | 'OfferUnavailable';
export const SUBSCRIPTION_REFUSAL_REASONS: readonly SubscriptionRefusalReason[] = [
  'TransitionUnavailable',
  'SubscriptionAlreadyExists',
  'OfferUnavailable',
];

export type SupportRequestRefusalReason = 'TransitionUnavailable';
export const SUPPORT_REQUEST_REFUSAL_REASONS: readonly SupportRequestRefusalReason[] = [
  'TransitionUnavailable',
];
