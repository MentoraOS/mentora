import type { RejectAgreement as RejectAgreementContract } from '@mentora/contracts-agreement';
import type { AgreementRepository, RejectAgreement } from '@mentora/domain-agreement';
import { err, ok } from '@mentora/kernel';

import { toRejectAgreement } from '../factories/agreement-command-factory.js';

import type { AgreementSequenceDefinition } from './agreement-sequence-definition.js';
import { agreementAbsentRefusal, agreementSequenceDefinition } from './agreement-sequence-definition.js';

/**
 * RejectAgreement — Expert rejects the Demande: Requested → Rejected, terminal
 * (F3.2-A; `Rejected` is Engagement's reserved word, F2.5 §11).
 */
export const rejectAgreementDefinition = (deps: {
  readonly repository: AgreementRepository;
}): AgreementSequenceDefinition<RejectAgreementContract, RejectAgreement> =>
  agreementSequenceDefinition(
    {
      commandType: 'RejectAgreement',
      map: (wire, instant) => ok(toRejectAgreement(wire, instant)),
      act: (unit, command) =>
        unit.some ? unit.value.reject(command) : err(agreementAbsentRefusal()),
    },
    deps.repository,
  );
