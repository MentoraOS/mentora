import type { ActorRef, CorrelationId } from '@mentora/contracts';

import { SequenceExecutionException } from '../errors/sequence-errors.js';
import type { SequenceRefusalLike } from '../result/sequence-outcome.js';
import { sequenceFailure } from '../result/sequence-outcome.js';

import type { ReadDefinition } from './read-definition.js';
import type { ReadJournalPort, ReadStepOutcome } from './read-journal.port.js';
import type { ReadOutcome } from './read-outcome.js';
import type { ReadStep } from './read-steps.js';

/**
 * ReadExecutor — THE executor of the Séquence de Lecture (F4.99 §1): six
 * frozen steps, "réception → identité → R-C → lecture → réponse → journal",
 * in this order, no other (closure law: three Sequences, no fourth path).
 *
 * The Lecture:
 * - NEVER mutates, retains, publishes, or decides — it reads and answers;
 * - refuses as a VALUE when the right misses (R-C, pas 3) or when nothing is
 *   readable (motivated, never silence — F2.6);
 * - NEVER retries: a technical throw becomes a Failure VALUE and the caller
 *   may ask again (a read is idempotent; transport retries are M-8's);
 * - journals every executed step under its CorrelationId (A-10) — a
 *   SequenceExecutionException propagates raw (A-7: a caller defect is never
 *   converted).
 */

export interface ReadInput {
  readonly payload: unknown;
  readonly actor: ActorRef;
  readonly correlationId: CorrelationId;
}

export interface ReadExecutorOptions<TQuery, TView, TResponse, TRefusal extends SequenceRefusalLike> {
  readonly definition: ReadDefinition<TQuery, TView, TResponse, TRefusal>;
  readonly journal: ReadJournalPort;
}

export class ReadExecutor<TQuery, TView, TResponse, TRefusal extends SequenceRefusalLike> {
  private readonly definition: ReadDefinition<TQuery, TView, TResponse, TRefusal>;
  private readonly journal: ReadJournalPort;

  constructor(options: ReadExecutorOptions<TQuery, TView, TResponse, TRefusal>) {
    this.definition = options.definition;
    this.journal = options.journal;
  }

  async execute(input: ReadInput): Promise<ReadOutcome<TResponse, TRefusal>> {
    let queryType = 'Unknown';
    const record = (step: ReadStep, outcome: ReadStepOutcome, note?: string): void => {
      this.journal.record({
        correlationId: input.correlationId,
        step,
        queryType,
        outcome,
        ...(note !== undefined ? { note } : {}),
      });
    };

    // Pas 1 — Reception: malformed → Exception channel, end.
    const received = this.definition.receive(input.payload);
    if (!received.ok) {
      record('Reception', 'exception', received.error[0]?.code);
      return { kind: 'exception', violations: received.error };
    }
    const query = received.value;
    queryType = this.definition.queryTypeOf(query);
    record('Reception', 'advanced');

    // Pas 2 — Identity: the authenticated ActorRef, injected (A-6). No time.
    const actor = input.actor;
    record('IdentityInjection', 'advanced');

    // Pas 3 — R-C: the declared grid on the injected identity.
    try {
      const right = await this.definition.entitled(query, actor);
      if (!right.ok) {
        record('RightsCheck', 'refused', right.error.reason);
        record('Journal', 'advanced');
        return { kind: 'refused', refusal: right.error };
      }
      record('RightsCheck', 'advanced');
    } catch (error) {
      return this.failure(record, 'RightsCheck', 'READ.RIGHTS_FAILURE', error);
    }

    // Pas 4 — Lecture: Read Model or source, via the port.
    let view: TView;
    try {
      const found = await this.definition.read(query);
      if (!found.some) {
        const refusal = this.definition.absent(query);
        record('Reading', 'refused', refusal.reason);
        record('Journal', 'advanced');
        return { kind: 'refused', refusal };
      }
      view = found.value;
      record('Reading', 'advanced');
    } catch (error) {
      return this.failure(record, 'Reading', 'READ.READING_FAILURE', error);
    }

    // Pas 5 — Réponse: the pure mapping; the domain never exits directly.
    const response = this.definition.respond(view);
    record('Response', 'advanced');

    // Pas 6 — Journal: the execution is journaled; the answer returns.
    record('Journal', 'advanced');
    return { kind: 'answered', response };
  }

  /** A technical throw is a Failure VALUE (A-7) — journaled, never silent. */
  private failure(
    record: (step: ReadStep, outcome: ReadStepOutcome, note?: string) => void,
    step: ReadStep,
    code: string,
    error: unknown,
  ): ReadOutcome<TResponse, TRefusal> {
    if (error instanceof SequenceExecutionException) {
      throw error;
    }
    const failure = sequenceFailure(code, describe(error));
    record(step, 'failure', failure.code);
    record('Journal', 'advanced');
    return { kind: 'failure', failure };
  }
}

const describe = (error: unknown): string =>
  error instanceof Error ? error.message : String(error);
