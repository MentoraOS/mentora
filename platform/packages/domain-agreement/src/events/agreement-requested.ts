import type { AgreementFactBase } from '../aggregate/agreement-fact-base.js';
import type { ClientId, ExpertId, OfferId } from '../ids/identifiers.js';
import type { TimeSlot } from '../value-objects/time-slot.js';

/** Frozen fact (F2.5 §4). The Demande is the Agreement's youth (F3.2-A). */
export interface AgreementRequested extends AgreementFactBase {
  readonly type: 'AgreementRequested';
  readonly clientId: ClientId;
  readonly expertId: ExpertId;
  readonly offerId: OfferId;
  readonly slot: TimeSlot;
}
