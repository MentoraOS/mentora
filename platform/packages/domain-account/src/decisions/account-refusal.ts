import type {
  AccountRefusalReason,
  AvailabilityFrameRefusalReason,
  SubscriptionRefusalReason,
  SupportRequestRefusalReason,
} from '@mentora/contracts-account';

/**
 * The Refusals — negative Decisions (F3.1.14: VALUES of full rank, never
 * exceptions). The REASON UNIONS are owned by the published language
 * (@mentora/contracts-account); this module owns the in-memory Decision
 * shapes the units return.
 */

export type { AccountRefusalReason, AvailabilityFrameRefusalReason } from '@mentora/contracts-account';

export interface AccountRefusal {
  readonly reason: AccountRefusalReason;
  readonly message: string;
}

export const accountRefusal = (reason: AccountRefusalReason, message: string): AccountRefusal => ({
  reason,
  message,
});

export interface AvailabilityFrameRefusal {
  readonly reason: AvailabilityFrameRefusalReason;
  readonly message: string;
}

export const availabilityFrameRefusal = (
  reason: AvailabilityFrameRefusalReason,
  message: string,
): AvailabilityFrameRefusal => ({ reason, message });

// ---------------------------------------------------------------- Lot A02

export type { SubscriptionRefusalReason, SupportRequestRefusalReason } from '@mentora/contracts-account';

export interface SubscriptionRefusal {
  readonly reason: SubscriptionRefusalReason;
  readonly message: string;
}

export const subscriptionRefusal = (
  reason: SubscriptionRefusalReason,
  message: string,
): SubscriptionRefusal => ({ reason, message });

export interface SupportRequestRefusal {
  readonly reason: SupportRequestRefusalReason;
  readonly message: string;
}

export const supportRequestRefusal = (
  reason: SupportRequestRefusalReason,
  message: string,
): SupportRequestRefusal => ({ reason, message });
