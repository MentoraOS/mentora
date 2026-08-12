import type { AgreementFactBase } from '../aggregate/agreement-fact-base.js';
import type { ExpertId } from '../ids/identifiers.js';

/** Frozen fact (F2.5 §4). Rejected is RESERVED to the Engagement (VD-0046). */
export interface AgreementRejected extends AgreementFactBase {
  readonly type: 'AgreementRejected';
  readonly expertId: ExpertId;
}
