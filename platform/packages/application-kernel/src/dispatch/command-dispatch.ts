import { invariant } from '@mentora/kernel';

import type { SequenceInput } from '../executor/sequence-executor.js';
import type { SequenceOutcome, SequenceRefusalLike } from '../result/sequence-outcome.js';

/**
 * CommandDispatch — the Command Dispatcher of F4.1 §6, verbatim: "résout une
 * Command vers L'UNIQUE Application Service qui la porte (table fermée —
 * deux porteurs = erreur détectée au démarrage) ; exige l'identité d'acte ;
 * injecte identité et corrélation ; zéro logique métier."
 *
 * Frozen PROPERTIES, free mechanisms (F4.1.99): the table is CLOSED,
 * declared at assembly (the Root owns "les Dispatchers et leurs tables",
 * F4.4 §2), readable, ONE carrier per Command (duplicate = refused at
 * assembly, fail closed — the startup error); the ACT IDENTITY is demanded
 * before routing (F4.1 §3: replay is deduplicated by it); identity and
 * correlation ride the input, injected by the entering adapter (A-6) — the
 * dispatch passes them and never thinks (A-8).
 */

export interface CommandCarrier {
  /** The dictionary name of the ONE Command this service carries (A-1). */
  readonly commandType: string;
  execute(input: SequenceInput): Promise<SequenceOutcome<unknown, SequenceRefusalLike>>;
}

export class CommandDispatch {
  private readonly table: ReadonlyMap<string, CommandCarrier>;

  constructor(carriers: readonly CommandCarrier[]) {
    const table = new Map<string, CommandCarrier>();
    for (const carrier of carriers) {
      invariant(
        !table.has(carrier.commandType),
        `two carriers for '${carrier.commandType}' — one Application Service per Command (F4.1 §6, fail closed)`,
      );
      table.set(carrier.commandType, carrier);
    }
    this.table = table;
  }

  /** The closed, readable table (a frozen property — F4.1.99). */
  get commandTypes(): readonly string[] {
    return [...this.table.keys()];
  }

  async dispatch(input: SequenceInput): Promise<SequenceOutcome<unknown, SequenceRefusalLike>> {
    const payload =
      typeof input.payload === 'object' && input.payload !== null
        ? (input.payload as Record<string, unknown>)
        : undefined;
    const type = payload?.['type'];
    const carrier = typeof type === 'string' ? this.table.get(type) : undefined;
    if (carrier === undefined) {
      return {
        kind: 'exception',
        violations: [
          {
            code: 'CONTRACT.UNKNOWN_CONTRACT',
            field: 'type',
            message: `No Application Service carries '${String(type)}' (table fermée — F4.1 §6)`,
          },
        ],
      };
    }
    // "Exige l'identité d'acte" (F4.1 §3/§6): no act identity, no routing.
    const commandId = payload?.['commandId'];
    if (typeof commandId !== 'string' || commandId.trim() === '') {
      return {
        kind: 'exception',
        violations: [
          {
            code: 'CONTRACT.FIELD_MISSING',
            field: 'commandId',
            message: 'The Command Dispatch demands the act identity (F4.1 §3/§6)',
          },
        ],
      };
    }
    return carrier.execute(input);
  }
}
