import type { RequestAgreement as RequestAgreementContract } from '@mentora/contracts-agreement';
import type { AgreementRepository, RequestAgreement } from '@mentora/domain-agreement';

import { requestAgreementDefinition } from '../definitions/request-agreement.definition.js';

import type { AgreementSequenceMachinery } from './agreement-sequence.application-service.js';
import { AgreementSequenceApplicationService } from './agreement-sequence.application-service.js';

/** Carries `RequestAgreement` — the birth of the Demande (A-1: one carrier). */
export class RequestAgreementApplicationService extends AgreementSequenceApplicationService<
  RequestAgreementContract,
  RequestAgreement
> {
  constructor(
    deps: { readonly repository: AgreementRepository },
    machinery: AgreementSequenceMachinery,
  ) {
    super(requestAgreementDefinition(deps), machinery);
  }
}
