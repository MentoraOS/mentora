import type { RejectAgreement as RejectAgreementContract } from '@mentora/contracts-agreement';
import type { AgreementRepository, RejectAgreement } from '@mentora/domain-agreement';

import { rejectAgreementDefinition } from '../definitions/reject-agreement.definition.js';

import type { AgreementSequenceMachinery } from './agreement-sequence.application-service.js';
import { AgreementSequenceApplicationService } from './agreement-sequence.application-service.js';

/** Carries `RejectAgreement` — Requested → Rejected, terminal (A-1: one carrier). */
export class RejectAgreementApplicationService extends AgreementSequenceApplicationService<
  RejectAgreementContract,
  RejectAgreement
> {
  constructor(
    deps: { readonly repository: AgreementRepository },
    machinery: AgreementSequenceMachinery,
  ) {
    super(rejectAgreementDefinition(deps), machinery);
  }
}
