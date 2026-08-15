import type { RescheduleAgreement as RescheduleAgreementContract } from '@mentora/contracts-agreement';
import type {
  AgreementRepository,
  RescheduleAgreement,
  ReschedulePolicy,
} from '@mentora/domain-agreement';
import { err } from '@mentora/kernel';

import { toRescheduleAgreement } from '../factories/agreement-command-factory.js';

import type { AgreementSequenceDefinition } from './agreement-sequence-definition.js';
import { agreementAbsentRefusal, agreementSequenceDefinition } from './agreement-sequence-definition.js';

/**
 * RescheduleAgreement — a party reschedules: Confirmed ⇄ Confirmed under the
 * published ReschedulePolicy (F3.2-A). The Policy is built with its PRODUCT
 * parameters at the composition root and INJECTED — "jamais instanciées en
 * chemin" (F4.1 §4); the UNIT applies it (F3.1 matrix), never this layer.
 */
export const rescheduleAgreementDefinition = (deps: {
  readonly repository: AgreementRepository;
  readonly reschedulePolicy: ReschedulePolicy;
}): AgreementSequenceDefinition<RescheduleAgreementContract, RescheduleAgreement> =>
  agreementSequenceDefinition(
    {
      commandType: 'RescheduleAgreement',
      map: (wire, instant) => toRescheduleAgreement(wire, instant),
      act: (unit, command) =>
        unit.some
          ? unit.value.reschedule(command, deps.reschedulePolicy)
          : err(agreementAbsentRefusal()),
    },
    deps.repository,
  );
