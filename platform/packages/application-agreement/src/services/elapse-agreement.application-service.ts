import type { ElapseAgreement as ElapseAgreementContract } from '@mentora/contracts-agreement';
import type { AgreementRepository, ElapseAgreement } from '@mentora/domain-agreement';

import { elapseAgreementDefinition } from '../definitions/elapse-agreement.definition.js';

import type { AgreementSequenceMachinery } from './agreement-sequence.application-service.js';
import { AgreementSequenceApplicationService } from './agreement-sequence.application-service.js';

/**
 * Carries `ElapseAgreement` — the Échéance: Confirmed → Elapsed, terminal
 * (time tooling, instant as data; `Elapsed` is the frozen end — no "Complete").
 */
export class ElapseAgreementApplicationService extends AgreementSequenceApplicationService<
  ElapseAgreementContract,
  ElapseAgreement
> {
  constructor(
    deps: { readonly repository: AgreementRepository },
    machinery: AgreementSequenceMachinery,
  ) {
    super(elapseAgreementDefinition(deps), machinery);
  }
}
