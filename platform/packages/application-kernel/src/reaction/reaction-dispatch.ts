import { invariant } from '@mentora/kernel';

import type { ReactionInput } from './reaction-executor.js';
import type { ReactionOutcome } from './reaction-outcome.js';

/**
 * ReactionDispatch — the routing of consumed facts to their declared
 * reactions: the table is a PROJECTION of declared subscriptions (M-5: "les
 * tables (porteurs, abonnements, routage) sont closes, déclarées, dérivées
 * et vérifiées au boot"), CLOSED and readable; no dynamic discovery, no
 * runtime reflection (F4.1.99: reflection hiding the table is forbidden as
 * a FORM).
 *
 * Within ONE dispatch (one consumer executable, one Inbox — M-4), a fact
 * type routes to its ONE declared reaction: two carriers for the same fact
 * refuse at assembly (fail closed). Across the platform a published fact
 * MAY feed several consumers — each with its OWN Inbox and its own dispatch
 * (M-4/M-5); journeys still never talk to each other (P-10).
 */

export interface ReactionCarrier {
  /** The dictionary name of the ONE published fact this reaction consumes. */
  readonly factType: string;
  execute(input: ReactionInput): Promise<ReactionOutcome<unknown, unknown>>;
}

export class ReactionDispatch {
  private readonly table: ReadonlyMap<string, ReactionCarrier>;

  constructor(carriers: readonly ReactionCarrier[]) {
    const table = new Map<string, ReactionCarrier>();
    for (const carrier of carriers) {
      invariant(
        !table.has(carrier.factType),
        `two reactions for '${carrier.factType}' in one dispatch — declare one carrier per fact (M-5, fail closed)`,
      );
      table.set(carrier.factType, carrier);
    }
    this.table = table;
  }

  /** The closed, readable table (frozen properties, free mechanisms — F4.1.99). */
  get factTypes(): readonly string[] {
    return [...this.table.keys()];
  }

  async dispatch(input: ReactionInput): Promise<ReactionOutcome<unknown, unknown>> {
    const type =
      typeof input.payload === 'object' && input.payload !== null
        ? (input.payload as Record<string, unknown>)['type']
        : undefined;
    const carrier = typeof type === 'string' ? this.table.get(type) : undefined;
    if (carrier === undefined) {
      // No declared reaction consumes this payload: a producer/routing
      // defect — the Exception channel as a VALUE (no journal exists yet:
      // no carrier's sequence ever started).
      return {
        kind: 'exception',
        violations: [
          {
            code: 'CONTRACT.UNKNOWN_CONTRACT',
            field: 'type',
            message: `No declared reaction consumes '${String(type)}' (table close — M-5)`,
          },
        ],
      };
    }
    return carrier.execute(input);
  }
}
