import type { AgreementFactBase } from '../aggregate/agreement-fact-base.js';

/**
 * Frozen fact (F2.5 §4). "Nulle Confirmation sans conditions accomplies,
 * encaissement compris" (F2.6 [É]); the settlement reference is the translated
 * execution report citation carried by the Commissioner (F3.2-A).
 */
export interface AgreementConfirmed extends AgreementFactBase {
  readonly type: 'AgreementConfirmed';
  readonly settlementReference: string;
}
