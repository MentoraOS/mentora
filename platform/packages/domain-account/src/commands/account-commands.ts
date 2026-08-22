import type { Instant } from '@mentora/kernel';

import type { CommandId, DeviceId, PersonId } from '../ids/identifiers.js';
import type { AvailabilityWindow } from '../value-objects/availability-window.js';
import type { Preference } from '../value-objects/preference.js';
import type { ReachabilityChannel } from '../value-objects/reachability-channel.js';
import type { VerificationState } from '../value-objects/verification-state.js';

/**
 * The domain commands of Lot A01 (catalogue 36-42) — the typed, validated
 * intent the Application layer hands to the unit after the wire→domain seam
 * (pas 5). The INSTANT rides in the command (A-6: injected at pas 3, never
 * read by the unit). The person IS the Account (RFC-003 P1).
 */

export interface RegisterPerson {
  readonly commandId: CommandId;
  readonly personId: PersonId;
  readonly verificationState: VerificationState;
  readonly registeredAt: Instant;
}

export interface ChangePreference {
  readonly commandId: CommandId;
  readonly personId: PersonId;
  readonly preference: Preference;
  readonly changedAt: Instant;
}

export interface ChangeReachability {
  readonly commandId: CommandId;
  readonly personId: PersonId;
  readonly channel: ReachabilityChannel;
  readonly changedAt: Instant;
}

export interface RegisterDevice {
  readonly commandId: CommandId;
  readonly personId: PersonId;
  readonly deviceId: DeviceId;
  readonly registeredAt: Instant;
}

export interface RemoveDevice {
  readonly commandId: CommandId;
  readonly personId: PersonId;
  readonly deviceId: DeviceId;
  readonly removedAt: Instant;
}

export interface CloseAccount {
  readonly commandId: CommandId;
  readonly personId: PersonId;
  readonly motive: string;
  readonly closedAt: Instant;
}

/** 42 — the frame's identity is the person's (RFC-003 P2). */
export interface ChangeAvailabilityFrame {
  readonly commandId: CommandId;
  readonly personId: PersonId;
  readonly windows: readonly AvailabilityWindow[];
  readonly changedAt: Instant;
}
