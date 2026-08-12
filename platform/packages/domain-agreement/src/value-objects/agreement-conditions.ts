import type { OfferId } from '../ids/identifiers.js';

/**
 * AgreementConditions — the agreed terms (F3.2-A: "les conditions convenues —
 * vérité NOUVELLE citant OfferId : ce n'est pas une copie de l'Offre, c'est le
 * fait de ce qui fut convenu"). R2 freezes only the OfferId citation; the
 * extract's further content awaits the Offer contracts package (SIGNALED —
 * nothing invented here).
 */
export interface AgreementConditions {
  /** Stable provenance citation — never a copy of the mutable Offer. */
  readonly offerId: OfferId;
}

export const agreementConditionsOf = (offerId: OfferId): AgreementConditions => ({ offerId });
