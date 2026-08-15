import { invariant } from '@mentora/kernel';

import type { SequenceRefusalLike } from '../result/sequence-outcome.js';

import type { ReadInput } from './read-executor.js';
import type { ReadOutcome } from './read-outcome.js';

/**
 * QueryDispatch — the Query Dispatcher of F4.1 §6: "résout vers son lecteur,
 * applique R-C (grille des ayants droit, catalogue F3.3 §5), journalise."
 *
 * Frozen PROPERTIES (mechanisms free — F4.1.99): the table is CLOSED,
 * declared at construction; ONE reader per Query ("UN Query → UN lecteur →
 * UNE réponse" — two carriers = an error detected at assembly, fail closed);
 * the table is readable; zero business logic. R-C and the journal are
 * executed by the reader's own Séquence de Lecture (pas 3 and 6) — the
 * dispatch routes, it never thinks (A-8).
 */

export interface QueryCarrier {
  /** The dictionary name of the ONE query this reader carries. */
  readonly queryType: string;
  execute(input: ReadInput): Promise<ReadOutcome<unknown, SequenceRefusalLike>>;
}

export class QueryDispatch {
  private readonly table: ReadonlyMap<string, QueryCarrier>;

  constructor(carriers: readonly QueryCarrier[]) {
    const table = new Map<string, QueryCarrier>();
    for (const carrier of carriers) {
      invariant(
        !table.has(carrier.queryType),
        `two carriers for '${carrier.queryType}' — one reader per Query (F4.1 §6, fail closed)`,
      );
      table.set(carrier.queryType, carrier);
    }
    this.table = table;
  }

  /** The closed, readable table (a frozen property — F4.1.99). */
  get queryTypes(): readonly string[] {
    return [...this.table.keys()];
  }

  async dispatch(input: ReadInput): Promise<ReadOutcome<unknown, SequenceRefusalLike>> {
    const type =
      typeof input.payload === 'object' && input.payload !== null
        ? (input.payload as Record<string, unknown>)['type']
        : undefined;
    const carrier = typeof type === 'string' ? this.table.get(type) : undefined;
    if (carrier === undefined) {
      // No reader carries this payload: a malformed call — the Exception
      // channel as a VALUE (the carrier's sequence never started, so there
      // is no journal to write — the dispatch owns no journal of its own).
      return {
        kind: 'exception',
        violations: [
          {
            code: 'CONTRACT.UNKNOWN_CONTRACT',
            field: 'type',
            message: `No reader carries '${String(type)}' (table fermée — F4.1 §6)`,
          },
        ],
      };
    }
    return carrier.execute(input);
  }
}
