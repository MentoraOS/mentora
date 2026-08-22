import type { Instant } from '@mentora/kernel';

import type { PersonId } from '../ids/identifiers.js';
import type { AvailabilityWindow } from '../value-objects/availability-window.js';
import type { PreferenceKind, PreferenceValue } from '../value-objects/preference.js';
import type { ReachabilityChannel } from '../value-objects/reachability-channel.js';
import type { VerificationState } from '../value-objects/verification-state.js';

/**
 * The facts of the Account and its AvailabilityFrame — five of the seven
 * ratified events of the context (catalogue 40-44; 45-46 are the
 * Subscription's, Lot A02). References and natures only: a typed
 * preference, a channel, a motive, windows. Device and SupportRequest
 * publish nothing (canon).
 */

export interface PersonRegistered {
  readonly type: 'PersonRegistered';
  readonly personId: PersonId;
  readonly sequence: number;
  readonly instant: Instant;
  readonly verificationState: VerificationState;
}

export interface PreferenceChanged {
  readonly type: 'PreferenceChanged';
  readonly personId: PersonId;
  readonly sequence: number;
  readonly instant: Instant;
  readonly preferenceKind: PreferenceKind;
  readonly preferenceValue: PreferenceValue;
}

export interface ReachabilityChanged {
  readonly type: 'ReachabilityChanged';
  readonly personId: PersonId;
  readonly sequence: number;
  readonly instant: Instant;
  readonly channel: ReachabilityChannel;
}

export interface AccountClosed {
  readonly type: 'AccountClosed';
  readonly personId: PersonId;
  readonly sequence: number;
  readonly instant: Instant;
  readonly motive: string;
}

export interface AvailabilityFrameChanged {
  readonly type: 'AvailabilityFrameChanged';
  readonly personId: PersonId;
  readonly sequence: number;
  readonly instant: Instant;
  readonly windows: readonly AvailabilityWindow[];
}
