import type { ActorRef } from '@mentora/contracts';
import type { AgreementId } from '@mentora/contracts-agreement';
import type { Option } from '@mentora/kernel';
import { none, some } from '@mentora/kernel';

import type {
  AgreementReadRightsPort,
  AgreementStateReadPort,
  AgreementStateView,
} from '../ports/agreement-state-read.port.js';

/**
 * Test doubles of the two read ports — in-memory, deterministic. The rights
 * double implements the DECLARED grid ("les parties, l'outillage du temps")
 * against the same stored views: the parties are the view's client/expert;
 * the time tooling is a designated ActorRef.
 */

export class InMemoryAgreementStateReadPort
  implements AgreementStateReadPort, AgreementReadRightsPort
{
  private readonly views = new Map<string, AgreementStateView>();
  /** Simulates a technical incapacity of the read model (S-3: a Failure). */
  failReads = false;

  constructor(private readonly timeToolingActor?: ActorRef) {}

  seed(view: AgreementStateView): void {
    this.views.set(view.agreementId, view);
  }

  stateOf(agreementId: AgreementId): Promise<Option<AgreementStateView>> {
    if (this.failReads) {
      return Promise.reject(new Error('read model unreachable'));
    }
    const view = this.views.get(agreementId);
    return Promise.resolve(view === undefined ? none : some(view));
  }

  holdsStateRight(actor: ActorRef, agreementId: AgreementId): Promise<boolean> {
    if (actor === this.timeToolingActor) {
      return Promise.resolve(true);
    }
    const view = this.views.get(agreementId);
    return Promise.resolve(
      view !== undefined && ((actor as string) === view.clientId || (actor as string) === view.expertId),
    );
  }
}
