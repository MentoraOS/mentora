import type { Instant } from '@mentora/kernel';

import type { AgreementParty } from './agreement-party.js';

/**
 * CancellationRecord — ratified VO (F3.2-A): "auteur + instant + motif".
 * "Toute Annulation porte son Auteur" (F2.6 [S][UX]) — the author is CancelledBy
 * (F2.5 §3: Auteur (d'annulation) → CancelledBy).
 */
export interface CancellationRecord {
  readonly cancelledBy: AgreementParty;
  readonly instant: Instant;
  readonly motive: string;
}

export const cancellationRecordOf = (
  cancelledBy: AgreementParty,
  instant: Instant,
  motive: string,
): CancellationRecord => ({ cancelledBy, instant, motive });
