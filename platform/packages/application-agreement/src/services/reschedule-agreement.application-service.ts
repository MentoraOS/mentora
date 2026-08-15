import type { RescheduleAgreement as RescheduleAgreementContract } from '@mentora/contracts-agreement';
import type {
  AgreementRepository,
  RescheduleAgreement,
  ReschedulePolicy,
} from '@mentora/domain-agreement';

import { rescheduleAgreementDefinition } from '../definitions/reschedule-agreement.definition.js';

import type { AgreementSequenceMachinery } from './agreement-sequence.application-service.js';
import { AgreementSequenceApplicationService } from './agreement-sequence.application-service.js';

/**
 * Carries `RescheduleAgreement` — Confirmed ⇄ Confirmed under the published
 * ReschedulePolicy, injected with its product parameters (F4.1 §4).
 */
export class RescheduleAgreementApplicationService extends AgreementSequenceApplicationService<
  RescheduleAgreementContract,
  RescheduleAgreement
> {
  constructor(
    deps: {
      readonly repository: AgreementRepository;
      readonly reschedulePolicy: ReschedulePolicy;
    },
    machinery: AgreementSequenceMachinery,
  ) {
    super(rescheduleAgreementDefinition(deps), machinery);
  }
}
