import type { AgreementFactBase } from '../aggregate/agreement-fact-base.js';
import type { CancellationRecord } from '../value-objects/cancellation-record.js';

/** Frozen fact (F2.5 §4). "Toute Annulation porte son Auteur" (F2.6). */
export interface AgreementCancelled extends AgreementFactBase {
  readonly type: 'AgreementCancelled';
  readonly record: CancellationRecord;
}
