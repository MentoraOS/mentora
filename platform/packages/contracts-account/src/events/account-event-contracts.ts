import type { PersonId, SubscriptionId } from '../identifiers.js';

/**
 * The wire facts of the Account context — the SEVEN ratified events
 * (catalogue 40-46; dictionary F2.5 §Account), in the published language
 * the relay carries (precedent: contracts-identity event contracts).
 * References and natures only (F3.3 §3): a preference is TYPED (which kind,
 * which value), a reachability is a channel, a closure is a motive — never
 * free content. Device and SupportRequest publish NOTHING (canon): no fact
 * of theirs exists in this language and none may be added here. The base
 * and the closed union live in wire/event-union.ts (MENTORA0003).
 */

export interface PersonRegistered {
  readonly contractVersion: 1;
  readonly type: 'PersonRegistered';
  /** EventIdentity = (personId, sequence) — per-unit order (F4.3 §4). */
  readonly personId: PersonId;
  readonly sequence: number;
  readonly occurredAtMs: number;
  readonly verificationState: string;
}

export interface PreferenceChanged {
  readonly contractVersion: 1;
  readonly type: 'PreferenceChanged';
  readonly personId: PersonId;
  readonly sequence: number;
  readonly occurredAtMs: number;
  readonly preferenceKind: string;
  readonly preferenceValue: string;
}

export interface ReachabilityChanged {
  readonly contractVersion: 1;
  readonly type: 'ReachabilityChanged';
  readonly personId: PersonId;
  readonly sequence: number;
  readonly occurredAtMs: number;
  readonly channel: string;
}

export interface AccountClosed {
  readonly contractVersion: 1;
  readonly type: 'AccountClosed';
  readonly personId: PersonId;
  readonly sequence: number;
  readonly occurredAtMs: number;
  readonly motive: string;
}

/** The frame's identity IS the person's (RFC-003 P2): the subject key is personId. */
export interface AvailabilityFrameChanged {
  readonly contractVersion: 1;
  readonly type: 'AvailabilityFrameChanged';
  readonly personId: PersonId;
  readonly sequence: number;
  readonly occurredAtMs: number;
  readonly windows: readonly { readonly startMs: number; readonly endMs: number }[];
}

export interface SubscriptionStarted {
  readonly contractVersion: 1;
  readonly type: 'SubscriptionStarted';
  readonly subscriptionId: SubscriptionId;
  readonly sequence: number;
  readonly occurredAtMs: number;
  readonly personId: PersonId;
  readonly offerReference: string;
}

export interface SubscriptionEnded {
  readonly contractVersion: 1;
  readonly type: 'SubscriptionEnded';
  readonly subscriptionId: SubscriptionId;
  readonly sequence: number;
  readonly occurredAtMs: number;
  readonly motive: string;
}
