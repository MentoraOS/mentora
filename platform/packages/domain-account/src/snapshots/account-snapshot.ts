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
