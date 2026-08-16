import type {
  AgreementReadRightsPort,
  AgreementStateReadPort,
  AgreementStateView,
} from '@mentora/application-agreement';
import type { ActorRef } from '@mentora/contracts';
import type { AgreementId, ClientId, ExpertId } from '@mentora/contracts-agreement';
import type { Option } from '@mentora/kernel';
import { none, some } from '@mentora/kernel';
import type { PrismaClient } from '@prisma/client';

import { AgreementPersistenceCorruptionException } from '../errors/agreement-persistence-errors.js';
import {
  agreementSnapshotChecksum,
  deserializeAgreementSnapshot,
} from '../serialization/agreement-snapshot-serializer.js';

/**
 * PrismaAgreementStateReadAdapter — the two READ ports of 1C-4, strictly and
 * nothing more (the mandate's law: no extra projection; the 1C-6 STOP
 * stands). Reads hit the PRIMARY (S-5: validity is never read on a lagging
 * replica). The view carries the parties for the rights grid; the response
 * mapping upstream strips them — the domain never exits (1C-4).
 *
 * The rights grid ("les parties, l'outillage du temps" — F3.3 §5) is
 * mechanized here below its port (F4.1.99: frozen properties, free
 * mechanisms): parties come from the stored photograph; the time tooling is
 * the DECLARED actor the Root injects.
 */
export class PrismaAgreementStateReadAdapter
  implements AgreementStateReadPort, AgreementReadRightsPort
{
  constructor(
    private readonly prisma: PrismaClient,
    private readonly timeToolingActor: ActorRef,
  ) {}

  async stateOf(agreementId: AgreementId): Promise<Option<AgreementStateView>> {
    const view = await this.viewOf(agreementId);
    return view === undefined ? none : some(view);
  }

  async holdsStateRight(actor: ActorRef, agreementId: AgreementId): Promise<boolean> {
    if (actor === this.timeToolingActor) {
      return true;
    }
    const view = await this.viewOf(agreementId);
    return (
      view !== undefined &&
      ((actor as string) === view.clientId || (actor as string) === view.expertId)
    );
  }

  private async viewOf(agreementId: AgreementId): Promise<AgreementStateView | undefined> {
    const row = await this.prisma.agreementSnapshot.findUnique({ where: { agreementId } });
    if (row === null) {
      return undefined;
    }
    if (agreementSnapshotChecksum(row.payload) !== row.checksum) {
      throw new AgreementPersistenceCorruptionException(row.agreementId, 'checksum mismatch');
    }
    const snapshot = deserializeAgreementSnapshot(row.payload);
    if (!snapshot.ok) {
      throw new AgreementPersistenceCorruptionException(row.agreementId, snapshot.error);
    }
    return {
      agreementId: snapshot.value.agreementId as AgreementId,
      stateKind: snapshot.value.state.kind,
      slot: { startMs: snapshot.value.slot.startMs, endMs: snapshot.value.slot.endMs },
      version: snapshot.value.version,
      clientId: snapshot.value.clientId as ClientId,
      expertId: snapshot.value.expertId as ExpertId,
    };
  }
}
