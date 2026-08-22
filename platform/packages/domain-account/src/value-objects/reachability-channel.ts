import { AccountIdentifierBlankException } from '../errors/account-exceptions.js';

/**
 * ReachabilityChannel — the channel by which the person may be reached
 * (dictionary F2.5 §Notification/§Account: Canal de joignabilité). Owned by
 * the Account, read by the Notification through the ONE sanctioned upward
 * lecture. Guarded opaque value: the ReachabilityPolicy's product allowlist
 * is the judge of which channels exist (RFC-003 P5) — no enum is invented.
 */

declare const reachabilityChannelBrand: unique symbol;
export type ReachabilityChannel = string & { readonly [reachabilityChannelBrand]: true };

export const reachabilityChannelOf = (value: string): ReachabilityChannel => {
  if (value.trim().length === 0) {
    throw new AccountIdentifierBlankException('ReachabilityChannel must not be blank');
  }
  return value.trim().toLowerCase() as ReachabilityChannel;
};
