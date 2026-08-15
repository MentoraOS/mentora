import type { RequestAgreement as RequestAgreementContract } from '@mentora/contracts-agreement';
import type { AgreementRepository, RequestAgreement } from '@mentora/domain-agreement';
import { AgreementFactory, agreementRefusal } from '@mentora/domain-agreement';
import { err } from '@mentora/kernel';

import { toRequestAgreement } from '../factories/agreement-command-factory.js';

import type { AgreementSequenceDefinition } from './agreement-sequence-definition.js';
import { agreementSequenceDefinition } from './agreement-sequence-definition.js';

/**
 * RequestAgreement — the birth (F3.2-A: Client requests; the published
 * AvailabilityFrame rides the command AS DATA, loi 15). The act goes through
 * the FACTORY door (F3.1: the Factory refuses births — OutsideAvailabilityFrame);
 * an Identifier already inhabited refuses: R-B — a new unit needs a new identity.
 */
export const requestAgreementDefinition = (deps: {
  readonly repository: AgreementRepository;
}): AgreementSequenceDefinition<RequestAgreementContract, RequestAgreement> => {
  const factory = new AgreementFactory();
  return agreementSequenceDefinition(
    {
      commandType: 'RequestAgreement',
      map: (wire, instant) => toRequestAgreement(wire, instant),
      act: (unit, command) =>
        unit.some
          ? err(
              agreementRefusal(
                'TransitionUnavailable',
                'An Agreement already lives under this Identifier — a new unit requires a new identity (R-B)',
              ),
            )
          : factory.request(command),
    },
    deps.repository,
  );
};
