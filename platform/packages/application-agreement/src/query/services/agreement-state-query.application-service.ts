import type {
  QueryCarrier,
  ReadInput,
  ReadJournalPort,
  ReadOutcome,
} from '@mentora/application-kernel';
import { ReadExecutor } from '@mentora/application-kernel';
import type { AgreementStateQuery, AgreementStateResponse } from '@mentora/contracts-agreement';

import { agreementStateQueryDefinition } from '../definitions/agreement-state-query.definition.js';
import type { AgreementReadRefusal } from '../errors/agreement-read-refusal.js';
import type {
  AgreementReadRightsPort,
  AgreementStateReadPort,
  AgreementStateView,
} from '../ports/agreement-state-read.port.js';

/**
 * The reader of `AgreementStateQuery` — the ONLY ratified Agreement read.
 * BORING by the same law as the command carriers (F4.1 §7): it instantiates
 * its ReadDefinition, hands it to the ONE ReadExecutor, and delegates. It
 * never decides, never mutates, never retains, never publishes, never
 * journals directly (the Séquence's pas 6 does — A-10), and holds no state
 * between two calls.
 */
export class AgreementStateQueryApplicationService implements QueryCarrier {
  /** The dictionary name of the ONE query this reader carries (F4.1 §6). */
  readonly queryType = 'AgreementStateQuery';

  private readonly executor: ReadExecutor<
    AgreementStateQuery,
    AgreementStateView,
    AgreementStateResponse,
    AgreementReadRefusal
  >;

  constructor(
    deps: {
      readonly readPort: AgreementStateReadPort;
      readonly rightsPort: AgreementReadRightsPort;
    },
    machinery: { readonly journal: ReadJournalPort },
  ) {
    this.executor = new ReadExecutor({
      definition: agreementStateQueryDefinition(deps),
      journal: machinery.journal,
    });
  }

  /** The whole reader: ONE delegation to the Séquence de Lecture. */
  execute(input: ReadInput): Promise<ReadOutcome<AgreementStateResponse, AgreementReadRefusal>> {
    return this.executor.execute(input);
  }
}
