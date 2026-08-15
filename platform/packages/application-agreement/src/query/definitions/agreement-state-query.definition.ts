import type { ReadDefinition } from '@mentora/application-kernel';
import type { AgreementStateQuery, AgreementStateResponse } from '@mentora/contracts-agreement';
import { err, ok } from '@mentora/kernel';

import { agreementReadRefusal } from '../errors/agreement-read-refusal.js';
import type { AgreementReadRefusal } from '../errors/agreement-read-refusal.js';
import type {
  AgreementReadRightsPort,
  AgreementStateReadPort,
  AgreementStateView,
} from '../ports/agreement-state-read.port.js';
import { receiveAgreementQuery } from '../validators/agreement-query-reception.js';

/**
 * The ONE ratified Agreement read (F2.5 §6, F3.3 §5: AgreementStateQuery —
 * rights grid "les parties, l'outillage du temps", response "l'état ⊘ les
 * conditions à des tiers"), plugged into the Séquence de Lecture. No
 * ListAgreement, no SearchAgreement, no BrowseAgreement, no FindAgreement —
 * none exists in R2 (§4 F3.3: "ExpressSearch supprimée").
 */
export const agreementStateQueryDefinition = (deps: {
  readonly readPort: AgreementStateReadPort;
  readonly rightsPort: AgreementReadRightsPort;
}): ReadDefinition<AgreementStateQuery, AgreementStateView, AgreementStateResponse, AgreementReadRefusal> => ({
  queryTypeOf: (wire) => wire.type,

  // Pas 1 — the published language validates; the application adds nothing.
  receive: (payload) => receiveAgreementQuery(payload),

  // Pas 3 — the declared grid on the injected identity (F4.1 §5).
  entitled: async (query, actor) => {
    const held = await deps.rightsPort.holdsStateRight(actor, query.agreementId);
    return held
      ? ok(undefined)
      : err(
          agreementReadRefusal(
            'RightMissing',
            'The declared grid grants this read to the parties and the time tooling only (F3.3 §5)',
          ),
        );
  },

  // Pas 4 — the lecture: the Read Model, by Identifier, nothing else.
  read: (query) => deps.readPort.stateOf(query.agreementId),

  absent: () =>
    agreementReadRefusal(
      'AgreementUnavailable',
      'Nothing is readable under this Identifier — motivated, never silence (F2.6)',
    ),

  // Pas 5 — the PURE mapping view → published response: the parties are
  // STRIPPED ("l'état ⊘ les conditions à des tiers"); the domain never exits.
  respond: (view) => ({
    contractVersion: 1,
    type: 'AgreementStateResponse',
    agreementId: view.agreementId,
    stateKind: view.stateKind,
    slot: view.slot,
    version: view.version,
  }),
});
