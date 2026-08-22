import type { ActorRef } from '@mentora/contracts';
import type { PersonId } from '@mentora/contracts-account';
import type { Option } from '@mentora/kernel';
import { none, some } from '@mentora/kernel';

import type {
  AccountReadRightsPort,
  AvailabilityFrameReadPort,
  AvailabilityFrameView,
  ReachabilityReadPort,
  ReachabilityView,
} from '../ports/account-read.port.js';

/**
 * Test doubles of the read ports — in-memory, deterministic. The rights
 * double mechanizes the DECLARED grid of ReachabilityQuery: the sanctioned
 * Notification is a designated ActorRef the Root injects; the holder is the
 * actor whose reference IS the account's identity (RFC-003 P1). The Lot A04
 * Prisma adapter will mechanize the same grid from the photographs.
 */
export class InMemoryAccountReadPorts
  implements AvailabilityFrameReadPort, ReachabilityReadPort, AccountReadRightsPort
{
  private readonly frames = new Map<string, AvailabilityFrameView>();
  private readonly reachabilities = new Map<string, ReachabilityView>();

  constructor(private readonly notificationActor: ActorRef) {}

  seedFrame(view: AvailabilityFrameView): void {
    this.frames.set(view.personId, view);
  }

  seedReachability(view: ReachabilityView): void {
    this.reachabilities.set(view.personId, view);
  }

  frameOf(personId: PersonId): Promise<Option<AvailabilityFrameView>> {
    const view = this.frames.get(personId);
    return Promise.resolve(view === undefined ? none : some(view));
  }

  reachabilityOf(personId: PersonId): Promise<Option<ReachabilityView>> {
    const view = this.reachabilities.get(personId);
    return Promise.resolve(view === undefined ? none : some(view));
  }

  holdsReachabilityRight(actor: ActorRef, personId: PersonId): Promise<boolean> {
    return Promise.resolve(actor === this.notificationActor || (actor as string) === personId);
  }
}
