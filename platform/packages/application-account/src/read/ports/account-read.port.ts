import type { ActorRef } from '@mentora/contracts';
import type { PersonId } from '@mentora/contracts-account';
import type { Option } from '@mentora/kernel';

/**
 * The READ ports of the Account query side — owned by their consumer, the
 * application (I-4); implemented by adapters below (I-12). READ ONLY by
 * construction. `<Capability>Port` naming (F2.5 §9), never a "repository".
 *
 * Two ratified lectures (catalogue 03): the frame (n°4, ayant droit : tous)
 * and the reachability (n°10, ayant droit : la Notification sanctionnée +
 * le Titulaire). The views are Read Model rows — never the units.
 */

export interface AvailabilityFrameView {
  readonly personId: PersonId;
  readonly windows: readonly { readonly startMs: number; readonly endMs: number }[];
  readonly version: number;
}

/** Carries only what the lecture serves: the channel (absent until first set) and the account's life. */
export interface ReachabilityView {
  readonly personId: PersonId;
  readonly channel?: string;
  readonly accountState: 'Active' | 'Closed';
}

export interface AvailabilityFrameReadPort {
  frameOf(personId: PersonId): Promise<Option<AvailabilityFrameView>>;
}

export interface ReachabilityReadPort {
  reachabilityOf(personId: PersonId): Promise<Option<ReachabilityView>>;
}

/**
 * R-C: the DECLARED grid of ReachabilityQuery, verbatim from the catalogue:
 * "la Notification (sanctionnée) + le Titulaire". HOW the adapter below
 * recognizes the sanctioned Notification (a declared actor the Root
 * injects) and the holder (the actor IS the account's identity — RFC-003
 * P1) is its mechanism. AvailabilityFrameQuery has NO grid: "tous".
 */
export interface AccountReadRightsPort {
  holdsReachabilityRight(actor: ActorRef, personId: PersonId): Promise<boolean>;
}
