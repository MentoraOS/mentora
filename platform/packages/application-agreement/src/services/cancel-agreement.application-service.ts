import type { CancelAgreement as CancelAgreementContract } from '@mentora/contracts-agreement';
import type {
  AgreementCancellationPolicy,
  AgreementRepository,
  CancelAgreement,
} from '@mentora/domain-agreement';

import { cancelAgreementDefinition } from '../definitions/cancel-agreement.definition.js';

import type { AgreementSequenceMachinery } from './agreement-sequence.application-service.js';
import { AgreementSequenceApplicationService } from './agreement-sequence.application-service.js';

/**
 * Carries `CancelAgreement` — Confirmed → Cancelled, terminal, under the
 * published AgreementCancellationPolicy, injected with its product parameters.
 */
export class CancelAgreementApplicationService extends AgreementSequenceApplicationService<
  CancelAgreementContract,
  CancelAgreement
> {
  constructor(
    deps: {
      readonly repository: AgreementRepository;
      readonly cancellationPolicy: AgreementCancellationPolicy;
    },
    machinery: AgreementSequenceMachinery,
  ) {
    super(cancelAgreementDefinition(deps), machinery);
  }
}
