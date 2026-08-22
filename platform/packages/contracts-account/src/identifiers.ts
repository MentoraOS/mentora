/**
 * Identifiers of the Account published language (dictionary F2.5 §Account:
 * Person, AccountHolder, Device, Subscription, SupportRequest, AvailabilityFrame).
 *
 * RFC-003 P1 (RATIFIED): the Account is singleton-par-acteur — its identity
 * IS the PersonId (reference-as-identity, the one written exception to
 * "jamais dérivé", bounded to one per actor). No AccountId exists. P2: the
 * AvailabilityFrame is singleton-par-Compte and carries the SAME identity.
 * The PersonId handed to Identity & Access through the Account ACL is this
 * value, opaque to I&A.
 */

declare const personIdBrand: unique symbol;
declare const deviceIdBrand: unique symbol;
declare const subscriptionIdBrand: unique symbol;
declare const supportRequestIdBrand: unique symbol;

export type PersonId = string & { readonly [personIdBrand]: true };
/** Inner identity of the Device entity (RFC-003 P7) — opaque, provided by the act. */
export type DeviceId = string & { readonly [deviceIdBrand]: true };
export type SubscriptionId = string & { readonly [subscriptionIdBrand]: true };
export type SupportRequestId = string & { readonly [supportRequestIdBrand]: true };

export type { CommandId } from '@mentora/contracts';
