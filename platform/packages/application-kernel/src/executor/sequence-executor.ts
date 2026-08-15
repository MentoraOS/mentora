import type { ActorRef, CorrelationId } from '@mentora/contracts';
import type { Clock } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';

import type { SequenceDefinition } from '../interfaces/sequence-definition.js';
import type { SequenceJournalPort, SequenceStepOutcome } from '../journal/sequence-journal.port.js';
import type {
  SequenceFailure,
  SequenceOutcome,
  SequenceRefusalLike,
} from '../result/sequence-outcome.js';
import type { SequenceStep } from '../step/sequence-steps.js';
import type { ExecutionState, SequenceStage, StageSignal } from '../step/stages.js';
import {
  ActStage,
  AtomicRetentionStage,
  IdentityInjectionStage,
  LoadingStage,
  PublicationStage,
  ReceptionStage,
  RefusalReturnStage,
  ResponseAndJournalStage,
  SourceValiditiesStage,
  TimeInjectionStage,
} from '../step/stages.js';

/**
 * SequenceExecutor — THE executor of the Séquence de Commande (F4.1 §2). It
 * runs the ten frozen steps IN THE EXACT ORDER (A-2); no step can be skipped
 * except where the Sequence's own law commands it:
 * - a refusal at the validities, the act, or the structural retention returns
 *   immediately — no retention, no fact (pas 7); Publication is skipped
 *   because nothing was retained (A-4: publication READS retention);
 * - a retryable technical Failure re-enters at Loading (pas 4) — the
 *   injections are NEVER re-run: ONE instant per execution (A-6); replay is
 *   deduplicated downstream by the act identity (F4.1 §3);
 * - the retry budget exhausted, the execution is ABANDONED and journaled —
 *   never forced, never silent.
 *
 * Every executed step is journaled (A-10): step journal, error journal and
 * abandon journal — never a technical log (Journal ≠ Log, F5.3).
 */

export interface SequenceInput {
  readonly payload: unknown;
  readonly actor: ActorRef;
  readonly correlationId: CorrelationId;
}

export interface SequenceExecutorOptions<
  TWire,
  TCommand,
  TUnit,
  TRefusal extends SequenceRefusalLike,
> {
  readonly definition: SequenceDefinition<TWire, TCommand, TUnit, TRefusal>;
  readonly clock: Clock;
  readonly journal: SequenceJournalPort;
  /** Technical configuration (I-5): total attempts for retryable Failures. */
  readonly maxAttempts?: number;
}

export class SequenceExecutor<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike> {
  private readonly definition: SequenceDefinition<TWire, TCommand, TUnit, TRefusal>;
  private readonly clock: Clock;
  private readonly journal: SequenceJournalPort;
  private readonly maxAttempts: number;

  constructor(options: SequenceExecutorOptions<TWire, TCommand, TUnit, TRefusal>) {
    invariant(options.maxAttempts === undefined || options.maxAttempts >= 1, 'maxAttempts >= 1');
    this.definition = options.definition;
    this.clock = options.clock;
    this.journal = options.journal;
    this.maxAttempts = options.maxAttempts ?? 1;
  }

  async execute(input: SequenceInput): Promise<SequenceOutcome<TUnit, TRefusal>> {
    const state: ExecutionState<TWire, TCommand, TUnit, TRefusal> = {
      correlationId: input.correlationId,
      payload: input.payload,
      inputActor: input.actor,
      commandType: 'Unknown',
      attempt: 1,
      actor: undefined,
      instant: undefined,
      commandId: undefined,
      wire: undefined,
      loaded: undefined,
      command: undefined,
      unit: undefined,
      refusal: undefined,
    };

    // ----- steps 1-3: run ONCE (one reception, one injection block — A-6).
    const reception = new ReceptionStage(this.definition);
    const receptionSignal = await reception.run(state);
    if (receptionSignal.signal === 'exception') {
      this.record(state, 'Reception', 'exception', receptionSignal.violations[0]?.code);
      return { kind: 'exception', violations: receptionSignal.violations };
    }
    this.record(state, 'Reception', 'advanced');

    await new IdentityInjectionStage<TWire, TCommand, TUnit, TRefusal>().run(state);
    this.record(state, 'IdentityInjection', 'advanced');
    await new TimeInjectionStage<TWire, TCommand, TUnit, TRefusal>(this.clock).run(state);
    this.record(state, 'TimeInjection', 'advanced');

    // ----- steps 4-8: the retryable heart; refusals exit through pas 7/10.
    const loading = new LoadingStage(this.definition);
    const validities = new SourceValiditiesStage(this.definition);
    const act = new ActStage(this.definition);
    const refusalReturn = new RefusalReturnStage<TWire, TCommand, TUnit, TRefusal>();
    const retention = new AtomicRetentionStage(this.definition);
    const publication = new PublicationStage<TWire, TCommand, TUnit, TRefusal>();
    const response = new ResponseAndJournalStage<TWire, TCommand, TUnit, TRefusal>();

    let lastFailure: SequenceFailure | undefined;

    for (let attempt = 1; attempt <= this.maxAttempts; attempt += 1) {
      state.attempt = attempt;
      state.refusal = undefined;
      state.unit = undefined;

      const attemptResult = await this.runAttempt(state, {
        loading,
        validities,
        act,
        refusalReturn,
        retention,
        publication,
        response,
      });

      if (attemptResult.kind !== 'retry') {
        return attemptResult.outcome;
      }
      lastFailure = attemptResult.failure;
    }

    // ----- retry budget exhausted: the abandon journal — never silent.
    invariant(lastFailure !== undefined, 'abandon requires a failure');
    this.record(state, 'ResponseAndJournal', 'abandoned', lastFailure.code);
    return { kind: 'abandoned', failure: lastFailure, attempts: this.maxAttempts };
  }

  private async runAttempt(
    state: ExecutionState<TWire, TCommand, TUnit, TRefusal>,
    stages: {
      loading: SequenceStage<TWire, TCommand, TUnit, TRefusal>;
      validities: SequenceStage<TWire, TCommand, TUnit, TRefusal>;
      act: SequenceStage<TWire, TCommand, TUnit, TRefusal>;
      refusalReturn: SequenceStage<TWire, TCommand, TUnit, TRefusal>;
      retention: SequenceStage<TWire, TCommand, TUnit, TRefusal>;
      publication: SequenceStage<TWire, TCommand, TUnit, TRefusal>;
      response: SequenceStage<TWire, TCommand, TUnit, TRefusal>;
    },
  ): Promise<
    | { kind: 'done'; outcome: SequenceOutcome<TUnit, TRefusal> }
    | { kind: 'retry'; failure: SequenceFailure }
  > {
    // Pas 4-6: loading, validities, act.
    for (const stage of [stages.loading, stages.validities, stages.act]) {
      const signal = await stage.run(state);
      const handled = this.handle(state, stage.step, signal);
      if (handled === 'refused') {
        return { kind: 'done', outcome: this.refusalPath(state, stages) };
      }
      if (handled !== 'advanced') {
        return this.failureOrRetry(signal);
      }
    }

    // Pas 7: nothing to return on the success path.
    await stages.refusalReturn.run(state);
    this.record(state, 'RefusalReturn', 'advanced');

    // Pas 8: atomic retention (structural R-A refusal possible).
    const retentionSignal = await stages.retention.run(state);
    const retentionHandled = this.handle(state, 'AtomicRetention', retentionSignal);
    if (retentionHandled === 'refused') {
      invariant(state.refusal !== undefined, 'refused retention carries its refusal');
      this.record(state, 'ResponseAndJournal', 'refused', state.refusal.reason);
      return {
        kind: 'done',
        outcome: { kind: 'refused', refusal: state.refusal, attempts: state.attempt },
      };
    }
    if (retentionHandled !== 'advanced') {
      return this.failureOrRetry(retentionSignal);
    }

    // Pas 9: structural — the relay owns publication (A-4).
    await stages.publication.run(state);
    this.record(state, 'Publication', 'advanced');

    // Pas 10: response + final journal.
    await stages.response.run(state);
    this.record(state, 'ResponseAndJournal', 'advanced');
    invariant(state.unit !== undefined, 'an executed sequence carries its unit');
    return {
      kind: 'done',
      outcome: { kind: 'executed', unit: state.unit, attempts: state.attempt },
    };
  }

  /** The pas-7 exit: refusal journaled, retention/publication skipped by law. */
  private refusalPath(
    state: ExecutionState<TWire, TCommand, TUnit, TRefusal>,
    stages: { refusalReturn: SequenceStage<TWire, TCommand, TUnit, TRefusal> },
  ): SequenceOutcome<TUnit, TRefusal> {
    invariant(state.refusal !== undefined, 'the refusal path carries its refusal');
    void stages.refusalReturn;
    this.record(state, 'RefusalReturn', 'refused', state.refusal.reason);
    this.record(state, 'ResponseAndJournal', 'advanced');
    return { kind: 'refused', refusal: state.refusal, attempts: state.attempt };
  }

  private failureOrRetry(
    signal: StageSignal<TRefusal>,
  ): { kind: 'retry'; failure: SequenceFailure } {
    invariant(signal.signal === 'failure', 'only failures reach the retry gate');
    return { kind: 'retry', failure: signal.failure };
  }

  /** Journal one step (A-10) and normalize the stage signal. */
  private handle(
    state: ExecutionState<TWire, TCommand, TUnit, TRefusal>,
    step: SequenceStep,
    signal: StageSignal<TRefusal>,
  ): 'advanced' | 'refused' | 'failure' {
    if (signal.signal === 'refuse') {
      state.refusal = signal.refusal;
      this.record(state, step, 'refused', signal.refusal.reason);
      return 'refused';
    }
    if (signal.signal === 'failure') {
      this.record(state, step, 'failure', signal.failure.code);
      return 'failure';
    }
    invariant(signal.signal === 'advance', 'exceptions end at reception');
    this.record(state, step, 'advanced');
    return 'advanced';
  }

  private record(
    state: ExecutionState<TWire, TCommand, TUnit, TRefusal>,
    step: SequenceStep,
    outcome: SequenceStepOutcome,
    note?: string,
  ): void {
    this.journal.record({
      correlationId: state.correlationId,
      step,
      commandType: state.commandType,
      occurredAtMs: state.instant?.epochMillis ?? 0,
      attempt: state.attempt,
      outcome,
      ...(note !== undefined ? { note } : {}),
    });
  }
}
