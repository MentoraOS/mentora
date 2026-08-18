import type { ActorRef, CommandId, CorrelationId } from '@mentora/contracts';
import type { Clock, Instant, Option } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';

import { SequenceExecutionException } from '../errors/sequence-errors.js';
import type { SequenceDefinition } from '../interfaces/sequence-definition.js';
import type { SequenceFailure, SequenceRefusalLike, SequenceViolation } from '../result/sequence-outcome.js';
import { sequenceFailure } from '../result/sequence-outcome.js';

import type { SequenceStep } from './sequence-steps.js';

/**
 * The ten steps as INDEPENDENT CLASSES, each with a single responsibility and
 * its law in the doc. The executor runs them in the frozen order (A-2); the
 * stages never know each other — they only read/write the execution state the
 * executor threads through them.
 */

/** The mutable state of ONE execution (see SequenceContext for the read view). */
export interface ExecutionState<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike> {
  readonly correlationId: CorrelationId;
  readonly payload: unknown;
  /** The authenticated actor handed in by the entering adapter/dispatch. */
  readonly inputActor: ActorRef;
  commandType: string;
  attempt: number;
  actor: ActorRef | undefined;
  instant: Instant | undefined;
  commandId: CommandId | undefined;
  wire: TWire | undefined;
  loaded: Option<TUnit> | undefined;
  command: TCommand | undefined;
  unit: TUnit | undefined;
  refusal: TRefusal | undefined;
}

/** What a stage tells the executor (never mixed — A-7). */
export type StageSignal<TRefusal extends SequenceRefusalLike> =
  | { readonly signal: 'advance' }
  | { readonly signal: 'exception'; readonly violations: readonly SequenceViolation[] }
  | { readonly signal: 'refuse'; readonly refusal: TRefusal }
  | { readonly signal: 'failure'; readonly failure: SequenceFailure };

export interface SequenceStage<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike> {
  readonly step: SequenceStep;
  run(state: ExecutionState<TWire, TCommand, TUnit, TRefusal>): Promise<StageSignal<TRefusal>>;
}

const ADVANCE = { signal: 'advance' } as const;

/** Pas 1 — payload → typed wire Command of the dictionary; malformed → end. */
export class ReceptionStage<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike>
  implements SequenceStage<TWire, TCommand, TUnit, TRefusal>
{
  readonly step = 'Reception' as const;

  constructor(private readonly definition: SequenceDefinition<TWire, TCommand, TUnit, TRefusal>) {}

  run(state: ExecutionState<TWire, TCommand, TUnit, TRefusal>): Promise<StageSignal<TRefusal>> {
    const received = this.definition.receive(state.payload);
    if (!received.ok) {
      return Promise.resolve({ signal: 'exception', violations: received.error });
    }
    state.wire = received.value;
    state.commandType = this.definition.commandTypeOf(received.value);
    state.commandId = this.definition.actIdentityOf(received.value);
    return Promise.resolve(ADVANCE);
  }
}

/** Pas 2 — the authenticated ActorRef, injected, never ambient (A-6). */
export class IdentityInjectionStage<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike>
  implements SequenceStage<TWire, TCommand, TUnit, TRefusal>
{
  readonly step = 'IdentityInjection' as const;

  run(state: ExecutionState<TWire, TCommand, TUnit, TRefusal>): Promise<StageSignal<TRefusal>> {
    state.actor = state.inputActor;
    return Promise.resolve(ADVANCE);
  }
}

/** Pas 3 — ONE instant captured for the whole execution (A-6). */
export class TimeInjectionStage<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike>
  implements SequenceStage<TWire, TCommand, TUnit, TRefusal>
{
  readonly step = 'TimeInjection' as const;

  constructor(private readonly clock: Clock) {}

  run(state: ExecutionState<TWire, TCommand, TUnit, TRefusal>): Promise<StageSignal<TRefusal>> {
    state.instant = this.clock.now();
    return Promise.resolve(ADVANCE);
  }
}

/**
 * Pas 4 — the registry, by Identifier, nothing else (R-A). An I/O throw is a
 * technical Failure (retryable — S-3); a SequenceExecutionException propagates raw
 * (A-7: "remonte telle quelle, jamais convertie").
 */
export class LoadingStage<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike>
  implements SequenceStage<TWire, TCommand, TUnit, TRefusal>
{
  readonly step = 'Loading' as const;

  constructor(private readonly definition: SequenceDefinition<TWire, TCommand, TUnit, TRefusal>) {}

  async run(state: ExecutionState<TWire, TCommand, TUnit, TRefusal>): Promise<StageSignal<TRefusal>> {
    invariant(state.wire !== undefined, 'Loading requires a received wire command (order is law)');
    try {
      state.loaded = await this.definition.load(state.wire);
      return ADVANCE;
    } catch (error) {
      if (error instanceof SequenceExecutionException) {
        throw error;
      }
      return {
        signal: 'failure',
        failure: sequenceFailure('SEQUENCE.LOADING_FAILURE', describe(error)),
      };
    }
  }
}

/**
 * Pas 5 — the synchronous source validities (loi 15) AND the wire→domain seam:
 * yields the typed domain command carrying validated data + the injected
 * instant. Refusals are motivated Decision VALUES.
 */
export class SourceValiditiesStage<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike>
  implements SequenceStage<TWire, TCommand, TUnit, TRefusal>
{
  readonly step = 'SourceValidities' as const;

  constructor(private readonly definition: SequenceDefinition<TWire, TCommand, TUnit, TRefusal>) {}

  async run(state: ExecutionState<TWire, TCommand, TUnit, TRefusal>): Promise<StageSignal<TRefusal>> {
    invariant(state.wire !== undefined, 'Validities require the wire command (order is law)');
    invariant(state.instant !== undefined, 'Validities require the injected instant (order is law)');
    invariant(state.actor !== undefined, 'Validities require the injected actor (order is law)');
    try {
      const validated = await this.definition.validate(state.wire, state.instant, state.actor);
      if (!validated.ok) {
        return { signal: 'refuse', refusal: validated.error };
      }
      state.command = validated.value;
      return ADVANCE;
    } catch (error) {
      if (error instanceof SequenceExecutionException) {
        throw error;
      }
      return {
        signal: 'failure',
        failure: sequenceFailure('SEQUENCE.VALIDITY_FAILURE', describe(error)),
      };
    }
  }
}

/**
 * Pas 6 — the Command on the unit: the unit (or its Factory, for births)
 * renders the Decision and gives birth to its facts INSIDE. Pure — nothing is
 * caught here: a thrown exception is a malformed call and propagates raw (A-7).
 */
export class ActStage<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike>
  implements SequenceStage<TWire, TCommand, TUnit, TRefusal>
{
  readonly step = 'Act' as const;

  constructor(private readonly definition: SequenceDefinition<TWire, TCommand, TUnit, TRefusal>) {}

  run(state: ExecutionState<TWire, TCommand, TUnit, TRefusal>): Promise<StageSignal<TRefusal>> {
    invariant(state.loaded !== undefined, 'Act requires the loading result (order is law)');
    invariant(state.command !== undefined, 'Act requires the validated command (order is law)');
    const decision = this.definition.act(state.loaded, state.command);
    if (!decision.ok) {
      return Promise.resolve({ signal: 'refuse', refusal: decision.error });
    }
    state.unit = decision.value;
    return Promise.resolve(ADVANCE);
  }
}

/**
 * Pas 7 — a refusal returns immediately: no retention, no fact, correlated
 * journal. On the success path there is nothing to return — the stage advances.
 */
export class RefusalReturnStage<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike>
  implements SequenceStage<TWire, TCommand, TUnit, TRefusal>
{
  readonly step = 'RefusalReturn' as const;

  run(state: ExecutionState<TWire, TCommand, TUnit, TRefusal>): Promise<StageSignal<TRefusal>> {
    if (state.refusal !== undefined) {
      return Promise.resolve({ signal: 'refuse', refusal: state.refusal });
    }
    return Promise.resolve(ADVANCE);
  }
}

/**
 * Pas 8 — the atomic retention: state + facts in the Outbox, ONE registry act,
 * talks to no one (A-3). The declared R-A key may refuse STRUCTURALLY (a
 * motivated Decision — F3.2-A); a thrown error is a technical Failure,
 * retryable (S-3: an optimistic conflict is a Failure, never a Decision).
 */
export class AtomicRetentionStage<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike>
  implements SequenceStage<TWire, TCommand, TUnit, TRefusal>
{
  readonly step = 'AtomicRetention' as const;

  constructor(private readonly definition: SequenceDefinition<TWire, TCommand, TUnit, TRefusal>) {}

  async run(state: ExecutionState<TWire, TCommand, TUnit, TRefusal>): Promise<StageSignal<TRefusal>> {
    invariant(state.unit !== undefined, 'Retention requires the acted unit (order is law)');
    try {
      // RFC-001 (RATIFIED, Option A) — the envelope values ride to the
      // retention so the Outbox de faits transports them: correlation is
      // the input's, causation is the ACT identity (the command caused the
      // facts). Envelope values only, never domain truth (A-9).
      const retained = await this.definition.retain(state.unit, {
        correlationId: state.correlationId,
        ...(state.commandId !== undefined ? { causationId: state.commandId } : {}),
      });
      if (!retained.ok) {
        return { signal: 'refuse', refusal: retained.error };
      }
      return ADVANCE;
    } catch (error) {
      if (error instanceof SequenceExecutionException) {
        throw error;
      }
      return {
        signal: 'failure',
        failure: sequenceFailure('SEQUENCE.RETENTION_FAILURE', describe(error)),
      };
    }
  }
}

/**
 * Pas 9 — Publication belongs to the OUTBOX RELAY (A-4): "le relais d'Outbox,
 * après la rétention, lit ce qui fut retenu et le porte au routage". In
 * process, this step is STRUCTURAL: it performs no I/O — phantom publication
 * is impossible by construction. It exists, it is journaled, it does nothing.
 */
export class PublicationStage<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike>
  implements SequenceStage<TWire, TCommand, TUnit, TRefusal>
{
  readonly step = 'Publication' as const;

  run(): Promise<StageSignal<TRefusal>> {
    return Promise.resolve(ADVANCE);
  }
}

/** Pas 10 — the Decision returns to the caller; the execution is journaled (A-10). */
export class ResponseAndJournalStage<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike>
  implements SequenceStage<TWire, TCommand, TUnit, TRefusal>
{
  readonly step = 'ResponseAndJournal' as const;

  run(): Promise<StageSignal<TRefusal>> {
    return Promise.resolve(ADVANCE);
  }
}

const describe = (error: unknown): string =>
  error instanceof Error ? error.message : String(error);
