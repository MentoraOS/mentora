import type { AcceptAgreement as AcceptAgreementContract } from '@mentora/contracts-agreement';
import type { AcceptAgreement, AgreementRepository } from '@mentora/domain-agreement';

import { acceptAgreementDefinition } from '../definitions/accept-agreement.definition.js';

import type { AgreementSequenceMachinery } from './agreement-sequence.application-service.js';
import { AgreementSequenceApplicationService } from './agreement-sequence.application-service.js';

/** Carries `AcceptAgreement` — Requested → Accepted (A-1: one carrier). */
export class AcceptAgreementApplicationService extends AgreementSequenceApplicationService<
  AcceptAgreementContract,
  AcceptAgreement
> {
  constructor(
    deps: { readonly repository: AgreementRepository },
    machinery: AgreementSequenceMachinery,
  ) {
    super(acceptAgreementDefinition(deps), machinery);
  }
}
