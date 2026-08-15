import type { ConfirmAgreement as ConfirmAgreementContract } from '@mentora/contracts-agreement';
import type { AgreementRepository, ConfirmAgreement } from '@mentora/domain-agreement';
import { err, ok } from '@mentora/kernel';

import { toConfirmAgreement } from '../factories/agreement-command-factory.js';

import type { AgreementSequenceDefinition } from './agreement-sequence-definition.js';
import { agreementAbsentRefusal, agreementSequenceDefinition } from './agreement-sequence-definition.js';

/**
 * ConfirmAgreement — Commissioner confirms: Accepted → Confirmed. "Nulle
 * Confirmation sans conditions accomplies, encaissement compris" (F2.6 [É]) —
 * the translated settlement reference rides the wire AS DATA (loi 15); the
 * unit applies the ConfirmableAgreementSpecification itself (F3.1 matrix).
 */
export const confirmAgreementDefinition = (deps: {
  readonly repository: AgreementRepository;
}): AgreementSequenceDefinition<ConfirmAgreementContract, ConfirmAgreement> =>
  agreementSequenceDefinition(
    {
      commandType: 'ConfirmAgreement',
      map: (wire, instant) => ok(toConfirmAgreement(wire, instant)),
      act: (unit, command) =>
        unit.some ? unit.value.confirm(command) : err(agreementAbsentRefusal()),
    },
    deps.repository,
  );
