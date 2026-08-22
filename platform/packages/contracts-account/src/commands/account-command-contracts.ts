import type { CommandId } from '@mentora/contracts';

import type { DeviceId, PersonId, SubscriptionId, SupportRequestId } from '../identifiers.js';

/**
 * The wire commands of the Account context — the published language's single
 * definition (catalogue 36-46, F3.2-B). The wire NEVER carries an instant
 * (A-6: time is injected at pas 3). Every command names the PERSON: the
 * Account and its AvailabilityFrame are identified by the PersonId (RFC-003
 * P1/P2); Subscription and SupportRequest carry their own identity plus the
 * holder's. The Subscription and SupportRequest wires belong to Lot A02's
 * units — the LANGUAGE is complete from the first lot (Story #156).
 */

export interface AccountCommandBase {
  readonly contractVersion: 1;
  /** The act identity (F4.1 §3) — replay is deduplicated by it. */
  readonly commandId: CommandId;
  readonly personId: PersonId;
}

/** 36 — the birth of the Account (the entry's act; the ACL then commands the proof — A05). */
export interface RegisterPerson extends AccountCommandBase {
  readonly type: 'RegisterPerson';
  /** VerificationState at registration — stays until a Titre VII names its command (RFC-003 P6). */
  readonly verificationState: string;
}

/** 37 — a TYPED preference (dictionary VOs: NotificationPreference, LanguagePreference, Timezone). */
export interface ChangePreference extends AccountCommandBase {
  readonly type: 'ChangePreference';
  readonly preference: { readonly kind: string; readonly value: string };
}

/** 38 — the reachability channel (judged by ReachabilityPolicy; read by Notification). */
export interface ChangeReachability extends AccountCommandBase {
  readonly type: 'ChangeReachability';
  readonly channel: string;
}

/** 39/40 — Device: an Entity with NO fact (canon). */
export interface RegisterDevice extends AccountCommandBase {
  readonly type: 'RegisterDevice';
  readonly deviceId: DeviceId;
}
export interface RemoveDevice extends AccountCommandBase {
  readonly type: 'RemoveDevice';
  readonly deviceId: DeviceId;
}

/** 41 — terminal; the confirmation is BEFORE the fact (UX-06); R-B: coming back = a new person. */
export interface CloseAccount extends AccountCommandBase {
  readonly type: 'CloseAccount';
  readonly motive: string;
}

/** 42 — the frame is born at its first change (RFC-003 P2); windows in epoch millis. */
export interface ChangeAvailabilityFrame extends AccountCommandBase {
  readonly type: 'ChangeAvailabilityFrame';
  readonly windows: readonly { readonly startMs: number; readonly endMs: number }[];
}

/** 43/44 — Subscription (the unit ships with Lot A02). */
export interface StartSubscription extends AccountCommandBase {
  readonly type: 'StartSubscription';
  readonly subscriptionId: SubscriptionId;
  /** A reference to the offer — terms are frozen BY REFERENCE; never a price here. */
  readonly offerReference: string;
}
export interface EndSubscription extends AccountCommandBase {
  readonly type: 'EndSubscription';
  readonly subscriptionId: SubscriptionId;
  readonly motive: string;
}

/** 45/46 — SupportRequest: transitions WITHOUT fact (canon: "aucun fait publié"). */
export interface OpenSupportRequest extends AccountCommandBase {
  readonly type: 'OpenSupportRequest';
  readonly supportRequestId: SupportRequestId;
  /** A motive reference — the dialogue itself is a Conversation (Messaging). */
  readonly motive: string;
}
export interface HandleSupportRequest extends AccountCommandBase {
  readonly type: 'HandleSupportRequest';
  readonly supportRequestId: SupportRequestId;
}

export type AccountCommandContract =
  | RegisterPerson
  | ChangePreference
  | ChangeReachability
  | RegisterDevice
  | RemoveDevice
  | CloseAccount
  | ChangeAvailabilityFrame
  | StartSubscription
  | EndSubscription
  | OpenSupportRequest
  | HandleSupportRequest;

export const ACCOUNT_COMMAND_TYPES = [
  'RegisterPerson',
  'ChangePreference',
  'ChangeReachability',
  'RegisterDevice',
  'RemoveDevice',
  'CloseAccount',
  'ChangeAvailabilityFrame',
  'StartSubscription',
  'EndSubscription',
  'OpenSupportRequest',
  'HandleSupportRequest',
] as const;
