import type { AgreementFactBase } from '../aggregate/agreement-fact-base.js';

/**
 * Frozen fact (F2.5 §4): Échéance → Elapse/Elapsed (F2.5 §15.1). Constated on
 * a provided instant; opens the road to the Encounter (Consultation).
 */
export interface AgreementElapsed extends AgreementFactBase {
  readonly type: 'AgreementElapsed';
}
