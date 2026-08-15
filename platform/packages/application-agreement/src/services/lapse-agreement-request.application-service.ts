import type { LapseAgreementRequest as LapseAgreementRequestContract } from '@mentora/contracts-agreement';
import type { AgreementRepository, LapseAgreementRequest } from '@mentora/domain-agreement';

import { lapseAgreementRequestDefinition } from '../definitions/lapse-agreement-request.definition.js';

import type { AgreementSequenceMachinery } from './agreement-sequence.application-service.js';
import { AgreementSequenceApplicationService } from './agreement-sequence.application-service.js';

/**
 * Carries `LapseAgreementRequest` — the Caducité of the Demande:
 * Requested|Accepted → Lapsed, terminal (time tooling, instant as data).
 */
export class LapseAgreementRequestApplicationService extends AgreementSequenceApplicationService<
  LapseAgreementRequestContract,
  LapseAgreementRequest
> {
  constructor(
    deps: { readonly repository: AgreementRepository },
    machinery: AgreementSequenceMachinery,
  ) {
    super(lapseAgreementRequestDefinition(deps), machinery);
  }
}
