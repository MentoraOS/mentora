import type { AgreementFactBase } from '../aggregate/agreement-fact-base.js';

/**
 * Frozen fact (F2.5 §4, F2.5.2): la Caducité frappe la DEMANDE (Lapse — never
 * "Expired", reserved to Consent VD-0044). Constated on a PROVIDED instant
 * (F3.1.99 §5: the unit judges the instant, it never reads it).
 */
export interface AgreementRequestLapsed extends AgreementFactBase {
  readonly type: 'AgreementRequestLapsed';
}
