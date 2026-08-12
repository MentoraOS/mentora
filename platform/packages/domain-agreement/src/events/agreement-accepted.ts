import type { AgreementFactBase } from '../aggregate/agreement-fact-base.js';
import type { ExpertId } from '../ids/identifiers.js';

/** Frozen fact (F2.5 §4). The Expert accepts the Demande. */
export interface AgreementAccepted extends AgreementFactBase {
  readonly type: 'AgreementAccepted';
  readonly expertId: ExpertId;
}
