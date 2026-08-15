import type { CorrelationId } from '@mentora/contracts';
import type { Clock } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';

import { SequenceExecutionException } from '../errors/sequence-errors.js';
import type { SequenceFailure } from '../result/sequence-outcome.js';
import { sequenceFailure } from '../result/sequence-outcome.js';

import type { ReactionDefinition, ReactionResult } from './reaction-definition.js';
import type { ReactionJournalPort, ReactionStepOutcome } from './reaction-journal.port.js';
import type { ReactionOutcome } from './reaction-outcome.js';
import type { ReactionStep } from './reaction-steps.js';

/**
 * ReactionExecutor — THE executor of the Séquence de Réaction (F4.99 §1):
 * six frozen steps, "Réception du fait → Injections → Réaction → Rétention
 * atomique → Relais → Journal", in this order, no other.
 *
 * - Pas 1 runs ONCE: reception by the published language, then the Inbox
 *   deduplication by FACT IDENTITY (M-4) — an already-seen fact is a
 *   duplicate outcome, absorbed (at-least-once, loi 15);
 * - Pas 2 runs ONCE: the propagated correlation, ONE instant (A-6);
 * - Pas 3-4 form the retryable heart: a TECHNICAL throw (position load or
 *   atomic retention — S-3: an optimistic conflict is a Failure) re-enters
 *   at pas 3; the reaction itself is PURE and deterministic, so replay is
 *   safe; the injections never re-run;
 * - the budget exhausted, the execution is ABANDONED and journaled (M-8:
 *   "les retries sont bornés; au-delà : Quarantaine + Signal — rien ne
 *   meurt sans témoin") — the transport's redelivery may try again later;
 * - Pas 5 is STRUCTURAL: the command-outbox RELAY reads what was retained
 *   and dispatches at-least-once (same law as Publication, A-4) — in
 *   process the step exists, is journaled, and does nothing;
 * - a SequenceExecutionException propagates RAW (A-7).
 */

export interface ReactionInput {
  readonly payload: unknown;
  readonly correlationId: CorrelationId;
}

export interface ReactionExecutorOptions<TFact, TPosition, TCommand> {
  readonly definition: ReactionDefinition<TFact, TPosition, TCommand>;
  readonly clock: Clock;
  readonly journal: ReactionJournalPort;
  /** Technical configuration (I-5): total attempts for retryable Failures. */
  readonly maxAttempts?: number;
}

export class ReactionExecutor<TFact, TPosition, TCommand> {
  private readonly definition: ReactionDefinition<TFact, TPosition, TCommand>;
  private readonly clock: Clock;
  private readonly journal: ReactionJournalPort;
  private readonly maxAttempts: number;

  constructor(options: ReactionExecutorOptions<TFact, TPosition, TCommand>) {
    invariant(options.maxAttempts === undefined || options.maxAttempts >= 1, 'maxAttempts >= 1');
    this.definition = options.definition;
    this.clock = options.clock;
    this.journal = options.journal;
    this.maxAttempts = options.maxAttempts ?? 1;
  }

  async execute(input: ReactionInput): Promise<ReactionOutcome<TPosition, TCommand>> {
    let factType = 'Unknown';
    let instantMs = 0;
    let attempt = 1;
    const record = (step: ReactionStep, outcome: ReactionStepOutcome, note?: string): void => {
      this.journal.record({
        correlationId: input.correlationId,
        step,
        factType,
        occurredAtMs: instantMs,
        attempt,
        outcome,
        ...(note !== undefined ? { note } : {}),
      });
    };

    // Pas 1 — Réception du fait: published language, then the Inbox.
    const received = this.definition.receive(input.payload);
    if (!received.ok) {
      record('FactReception', 'exception', received.error[0]?.code);
      return { kind: 'exception', violations: received.error };
    }
    const fact = received.value;
    factType = this.definition.factTypeOf(fact);
    const factIdentity = this.definition.factIdentityOf(fact);
    const alreadySeen = await this.definition.seen(factIdentity);
    if (alreadySeen) {
      record('FactReception', 'duplicate', factIdentity);
      return { kind: 'duplicate', factIdentity };
    }
    record('FactReception', 'advanced');

    // Pas 2 — Injections: propagated correlation, ONE instant (A-6).
    const instant = this.clock.now();
    instantMs = instant.epochMillis;
    record('Injections', 'advanced');

    // Pas 3-4 — the retryable heart.
    const journeyKey = this.definition.journeyKeyOf(fact);
    let lastFailure: SequenceFailure | undefined;

    for (attempt = 1; attempt <= this.maxAttempts; attempt += 1) {
      // Pas 3 — Réaction: load the position, run the PURE function.
      let result: ReactionResult<TPosition, TCommand>;
      try {
        const position = await this.definition.positionOf(journeyKey);
        result = this.definition.react(position, fact, instant);
        record('Reaction', 'advanced');
      } catch (error) {
        lastFailure = this.failure(record, 'Reaction', 'REACTION.REACTION_FAILURE', error);
        continue;
      }

      // Pas 4 — Rétention atomique: Inbox mark + position + commands, ONE write.
      try {
        await this.definition.retain(factIdentity, journeyKey, result);
        record('AtomicRetention', 'advanced');
      } catch (error) {
        lastFailure = this.failure(record, 'AtomicRetention', 'REACTION.RETENTION_FAILURE', error);
        continue;
      }

      // Pas 5 — Relais: structural — the command-outbox relay owns dispatch.
      record('Relay', 'advanced');

      // Pas 6 — Journal: the execution is journaled; the reaction is done.
      record('Journal', 'advanced');
      return { kind: 'reacted', position: result.position, commands: result.commands, attempts: attempt };
    }

    // Budget exhausted: the abandon journal — never silent (M-8).
    attempt = this.maxAttempts;
    invariant(lastFailure !== undefined, 'abandon requires a failure');
    record('Journal', 'abandoned', lastFailure.code);
    return { kind: 'abandoned', failure: lastFailure, attempts: this.maxAttempts };
  }

  /** A technical throw is a Failure VALUE (A-7) — journaled, retry re-enters at pas 3. */
  private failure(
    record: (step: ReactionStep, outcome: ReactionStepOutcome, note?: string) => void,
    step: ReactionStep,
    code: string,
    error: unknown,
  ): SequenceFailure {
    if (error instanceof SequenceExecutionException) {
      throw error;
    }
    const failure = sequenceFailure(code, describe(error));
    record(step, 'failure', failure.code);
    return failure;
  }
}

const describe = (error: unknown): string =>
  error instanceof Error ? error.message : String(error);
