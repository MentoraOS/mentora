import type { ElapseAgreement as ElapseAgreementContract } from '@mentora/contracts-agreement';
import type { AgreementRepository, ElapseAgreement } from '@mentora/domain-agreement';
import { err, ok } from '@mentora/kernel';

import { toElapseAgreement } from '../factories/agreement-command-factory.js';

import type { AgreementSequenceDefinition } from './agreement-sequence-definition.js';
import { agreementAbsentRefusal, agreementSequenceDefinition } from './agreement-sequence-definition.js';

/**
 * ElapseAgreement — the Échéance: Confirmed → Elapsed, terminal (F3.2-A;
 * `Elapsed` is Engagement's frozen end of a confirmed agreement — "Complete"
 * does not exist in R2). Commanded by the time tooling, instant AS DATA.
 */
export const elapseAgreementDefinition = (deps: {
  readonly repository: AgreementRepository;
}): AgreementSequenceDefinition<ElapseAgreementContract, ElapseAgreement> =>
  agreementSequenceDefinition(
    {
      commandType: 'ElapseAgreement',
      map: (wire, instant) => ok(toElapseAgreement(wire, instant)),
      act: (unit, command) =>
        unit.some ? unit.value.elapse(command) : err(agreementAbsentRefusal()),
    },
    deps.repository,
  );
