import type { Instant } from '@mentora/kernel';
import { instantOf } from '@mentora/kernel';

/**
 * Frozen Policy (F3.2-A: ConfirmationPolicy — ratified single-stem name).
 * Publishes, in advance, the window within which an Accepted Demande may still
 * be confirmed (after it, the Caducité path applies: Accepted → Lapsed).
 * Parameters are product configuration, injected (F4.4 I-5).
 */
export interface ConfirmationPolicyParams {
  readonly confirmationWindowMillis: number;
}

export class ConfirmationPolicy {
  constructor(private readonly params: ConfirmationPolicyParams) {}

  confirmableUntil(acceptedAt: Instant): Instant {
    return instantOf(acceptedAt.epochMillis + this.params.confirmationWindowMillis);
  }

  isWithinWindow(acceptedAt: Instant, at: Instant): boolean {
    return at.epochMillis < this.confirmableUntil(acceptedAt).epochMillis;
  }
}
