import type { PersonId, SubscriptionId } from '@mentora/contracts-account';
import type { Result } from '@mentora/kernel';

/**
 * SettlementAclPort — the Account's ACL toward the Settlement generic
 * (context map: "Account → Settlement (ACL, abonnement)"; the Subscription
 * is the COMMISSIONER of the Settlement). OWNED HERE, by the consumer
 * (I-4). M-7: translation outward is an ORDER (never a fact); translation
 * inward is the Settlement's report to the SOLE commissioner, expressed in
 * THIS context's language — the `SettlementReport` below is Account's
 * type, no Settlement dialect ever crosses this port (I-7).
 *
 * The Settlement domain does not exist yet: the port is DECLARED now
 * (RFC-003 P4, ratified); its real adapter arrives with that domain; until
 * then only the PROVISIONAL development adapter may stand behind it — and
 * it refuses to exist outside development (see development-no-settlement-adapter.ts).
 */

export interface SettlementOrderRequest {
  readonly subscriptionId: SubscriptionId;
  readonly commissioner: PersonId;
  readonly offerReference: string;
}

export interface SettlementAclViolation {
  readonly code: 'SETTLEMENT.UNAVAILABLE';
  readonly message: string;
}

/** The report to the sole commissioner, in Account's words (M-7). */
export type SettlementReport =
  | { readonly kind: 'executed'; readonly subscriptionId: SubscriptionId }
  | { readonly kind: 'failed'; readonly subscriptionId: SubscriptionId; readonly reason: string };

export interface SettlementAclPort {
  /** The identifying name of the adapter behind the port — read at boot, never hidden. */
  readonly adapterName: string;
  commission(order: SettlementOrderRequest): Promise<Result<void, SettlementAclViolation>>;
}
