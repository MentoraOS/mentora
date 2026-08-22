import type { QueryCarrier, ReadInput, ReadJournalPort, ReadOutcome } from '@mentora/application-kernel';
import { QueryDispatch, ReadExecutor } from '@mentora/application-kernel';
import type {
  AvailabilityFrameQuery,
  AvailabilityFrameResponse,
  ReachabilityQuery,
  ReachabilityResponse,
} from '@mentora/contracts-account';

import {
  availabilityFrameQueryDefinition,
  reachabilityQueryDefinition,
} from '../definitions/account-query-definitions.js';
import type { AccountReadRefusal } from '../errors/account-read-refusal.js';
import type {
  AccountReadRightsPort,
  AvailabilityFrameReadPort,
  AvailabilityFrameView,
  ReachabilityReadPort,
  ReachabilityView,
} from '../ports/account-read.port.js';

/**
 * The two BORING readers (F4.1 §7): each instantiates its ReadDefinition,
 * hands it to the ONE ReadExecutor and delegates. They never decide, never
 * retain, never journal directly (the Séquence's pas 6 does — A-10).
 */

export class AvailabilityFrameQueryApplicationService implements QueryCarrier {
  readonly queryType = 'AvailabilityFrameQuery';
  private readonly executor: ReadExecutor<AvailabilityFrameQuery, AvailabilityFrameView, AvailabilityFrameResponse, AccountReadRefusal>;

  constructor(deps: { readonly readPort: AvailabilityFrameReadPort }, machinery: { readonly journal: ReadJournalPort }) {
    this.executor = new ReadExecutor({
      definition: availabilityFrameQueryDefinition(deps),
      journal: machinery.journal,
    });
  }

  execute(input: ReadInput): Promise<ReadOutcome<AvailabilityFrameResponse, AccountReadRefusal>> {
    return this.executor.execute(input);
  }
}

export class ReachabilityQueryApplicationService implements QueryCarrier {
  readonly queryType = 'ReachabilityQuery';
  private readonly executor: ReadExecutor<ReachabilityQuery, ReachabilityView, ReachabilityResponse, AccountReadRefusal>;

  constructor(
    deps: { readonly readPort: ReachabilityReadPort; readonly rightsPort: AccountReadRightsPort },
    machinery: { readonly journal: ReadJournalPort },
  ) {
    this.executor = new ReadExecutor({
      definition: reachabilityQueryDefinition(deps),
      journal: machinery.journal,
    });
  }

  execute(input: ReadInput): Promise<ReadOutcome<ReachabilityResponse, AccountReadRefusal>> {
    return this.executor.execute(input);
  }
}

/** The Account entries of the Query Dispatch — CLOSED: the two ratified reads, nothing else. */
export const accountQueryDispatch = (
  frameReader: AvailabilityFrameQueryApplicationService,
  reachabilityReader: ReachabilityQueryApplicationService,
): QueryDispatch => new QueryDispatch([frameReader, reachabilityReader]);
