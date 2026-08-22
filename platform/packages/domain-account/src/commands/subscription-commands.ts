import type { Instant } from '@mentora/kernel';

import type { CommandId, PersonId, SubscriptionId, SupportRequestId } from '../ids/identifiers.js';

/**
 * The domain commands of Lot A02 (catalogue 43-46) — typed, validated intent
 * after the wire→domain seam (pas 5); the INSTANT rides inside (A-6).
 */

export interface StartSubscription {
  readonly commandId: CommandId;
  readonly subscriptionId: SubscriptionId;
  /** The holder — the Account's identity (RFC-003 P1); the Commissioner of the Settlement. */
  readonly personId: PersonId;
  /** The terms, frozen BY REFERENCE (règle du contrat commercial) — never a price here. */
  readonly offerReference: string;
  readonly startedAt: Instant;
}

export interface EndSubscription {
  readonly commandId: CommandId;
  readonly subscriptionId: SubscriptionId;
  readonly motive: string;
  readonly endedAt: Instant;
}

export interface OpenSupportRequest {
  readonly commandId: CommandId;
  readonly supportRequestId: SupportRequestId;
  /** The SupportRequester — qualified actor (dictionary: Requester toujours qualifié). */
  readonly requesterId: PersonId;
  /** A motive REFERENCE — the dialogue itself is a Conversation (Messaging). */
  readonly motive: string;
  readonly openedAt: Instant;
}

export interface HandleSupportRequest {
  readonly commandId: CommandId;
  readonly supportRequestId: SupportRequestId;
  readonly handledAt: Instant;
}
