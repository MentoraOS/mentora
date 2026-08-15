import type { LapseAgreementRequest as LapseAgreementRequestContract } from '@mentora/contracts-agreement';
import type { AgreementRepository, LapseAgreementRequest } from '@mentora/domain-agreement';
import { err, ok } from '@mentora/kernel';

import { toLapseAgreementRequest } from '../factories/agreement-command-factory.js';

import type { AgreementSequenceDefinition } from './agreement-sequence-definition.js';
import { agreementAbsentRefusal, agreementSequenceDefinition } from './agreement-sequence-definition.js';

/**
 * LapseAgreementRequest — the Caducité strikes the DEMANDE, never the firm
 * agreement (F2.5.2): Requested|Accepted → Lapsed, terminal. Commanded by the
 * time tooling with the instant AS DATA — the unit judges time, never reads
 * it. (`Expired` is reserved to Consent, F2.5 §11 — hence Lapse.)
 */
export const lapseAgreementRequestDefinition = (deps: {
  readonly repository: AgreementRepository;
}): AgreementSequenceDefinition<LapseAgreementRequestContract, LapseAgreementRequest> =>
  agreementSequenceDefinition(
    {
      commandType: 'LapseAgreementRequest',
      map: (wire, instant) => ok(toLapseAgreementRequest(wire, instant)),
      act: (unit, command) =>
        unit.some ? unit.value.lapseRequest(command) : err(agreementAbsentRefusal()),
    },
    deps.repository,
  );
