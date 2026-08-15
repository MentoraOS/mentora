import type { ConfirmAgreement as ConfirmAgreementContract } from '@mentora/contracts-agreement';
import type { AgreementRepository, ConfirmAgreement } from '@mentora/domain-agreement';

import { confirmAgreementDefinition } from '../definitions/confirm-agreement.definition.js';

import type { AgreementSequenceMachinery } from './agreement-sequence.application-service.js';
import { AgreementSequenceApplicationService } from './agreement-sequence.application-service.js';

/** Carries `ConfirmAgreement` — Accepted → Confirmed (A-1: one carrier). */
export class ConfirmAgreementApplicationService extends AgreementSequenceApplicationService<
  ConfirmAgreementContract,
  ConfirmAgreement
> {
  constructor(
    deps: { readonly repository: AgreementRepository },
    machinery: AgreementSequenceMachinery,
  ) {
    super(confirmAgreementDefinition(deps), machinery);
  }
}
