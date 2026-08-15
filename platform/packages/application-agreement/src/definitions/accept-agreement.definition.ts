import type { AcceptAgreement as AcceptAgreementContract } from '@mentora/contracts-agreement';
import type { AcceptAgreement, AgreementRepository } from '@mentora/domain-agreement';
import { err, ok } from '@mentora/kernel';

import { toAcceptAgreement } from '../factories/agreement-command-factory.js';

import type { AgreementSequenceDefinition } from './agreement-sequence-definition.js';
import { agreementAbsentRefusal, agreementSequenceDefinition } from './agreement-sequence-definition.js';

/** AcceptAgreement — Expert accepts the Demande: Requested → Accepted (F3.2-A). */
export const acceptAgreementDefinition = (deps: {
  readonly repository: AgreementRepository;
}): AgreementSequenceDefinition<AcceptAgreementContract, AcceptAgreement> =>
  agreementSequenceDefinition(
    {
      commandType: 'AcceptAgreement',
      map: (wire, instant) => ok(toAcceptAgreement(wire, instant)),
      act: (unit, command) =>
        unit.some ? unit.value.accept(command) : err(agreementAbsentRefusal()),
    },
    deps.repository,
  );
