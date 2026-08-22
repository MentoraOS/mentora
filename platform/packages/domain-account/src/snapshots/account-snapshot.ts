/**
 * The internal reconstitution photographs (F3.1.11: "privée au registre —
 * jamais un contrat, jamais une donnée servie"; F5.2.99: reconstruction =
 * private Snapshot + delta(0)). Plain serializable state; ONLY the registry
 * adapter may touch them.
 */

export type AccountSnapshotState =
  | { readonly kind: 'Active'; readonly registeredAtMs: number }
  | { readonly kind: 'Closed'; readonly closedAtMs: number; readonly motive: string };

export interface AccountSnapshot {
  readonly personId: string;
  readonly verificationState: string;
  readonly preferences: readonly { readonly kind: string; readonly value: string }[];
  /** undefined until the first ChangeReachability. */
  readonly reachability?: string;
  readonly devices: readonly { readonly deviceId: string; readonly registeredAtMs: number }[];
  readonly state: AccountSnapshotState;
  readonly version: number;
}

export interface AvailabilityFrameSnapshot {
  readonly personId: string;
  readonly windows: readonly { readonly startMs: number; readonly endMs: number }[];
  readonly version: number;
}

// ---------------------------------------------------------------- Lot A02

export type SubscriptionSnapshotState =
  | { readonly kind: 'Active'; readonly startedAtMs: number }
  | { readonly kind: 'Ended'; readonly endedAtMs: number; readonly motive: string };

export interface SubscriptionSnapshot {
  readonly subscriptionId: string;
  readonly personId: string;
  readonly offerReference: string;
  readonly state: SubscriptionSnapshotState;
  readonly version: number;
}

/** STATE ONLY: a support request has no facts to photograph. */
export type SupportRequestSnapshotState =
  | { readonly kind: 'Opened'; readonly openedAtMs: number }
  | { readonly kind: 'Handled'; readonly handledAtMs: number };

export interface SupportRequestSnapshot {
  readonly supportRequestId: string;
  readonly requesterId: string;
  readonly motive: string;
  readonly state: SupportRequestSnapshotState;
  readonly version: number;
}
