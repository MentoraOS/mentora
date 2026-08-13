import type { AgreementId } from '../ids/identifiers.js';

/**
 * AgreementStateQuery — the ONLY ratified Agreement read (F2.5 §6, F3.3 §5).
 * R-C rights-holder, verbatim from the frozen catalogue: "les parties,
 * l'outillage du temps" — returns "l'état ⊘ les conditions à des tiers". The
 * rights check is applied by the Query Dispatch (F4.1 §6), never here.
 * Read-only: a query never mutates.
 */
export interface AgreementStateQuery {
  readonly contractVersion: 1;
  readonly type: 'AgreementStateQuery';
  readonly agreementId: AgreementId;
}
