import type { CancelAgreement as CancelAgreementContract } from '@mentora/contracts-agreement';
import type {
  AgreementCancellationPolicy,
  AgreementRepository,
  CancelAgreement,
} from '@mentora/domain-agreement';
import { err, ok } from '@mentora/kernel';

import { toCancelAgreement } from '../factories/agreement-command-factory.js';

import type { AgreementSequenceDefinition } from './agreement-sequence-definition.js';
import { agreementAbsentRefusal, agreementSequenceDefinition } from './agreement-sequence-definition.js';

/**
 * CancelAgreement — a party cancels: Confirmed → Cancelled, terminal. "Toute
 * Annulation porte son Auteur et subit les règles publiées" (F2.6 [S][UX]) —
 * the author rides the command; the published AgreementCancellationPolicy is
 * injected (product parameters, F4.4 I-5) and applied BY THE UNIT.
 */
export const cancelAgreementDefinition = (deps: {
  readonly repository: AgreementRepository;
  readonly cancellationPolicy: AgreementCancellationPolicy;
}): AgreementSequenceDefinition<CancelAgreementContract, CancelAgreement> =>
  agreementSequenceDefinition(
    {
      commandType: 'CancelAgreement',
      map: (wire, instant) => ok(toCancelAgreement(wire, instant)),
      act: (unit, command) =>
        unit.some
          ? unit.value.cancel(command, deps.cancellationPolicy)
          : err(agreementAbsentRefusal()),
    },
    deps.repository,
  );
