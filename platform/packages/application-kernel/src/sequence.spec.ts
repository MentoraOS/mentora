import type { ActorRef, CommandId, CorrelationId } from '@mentora/contracts';
import type { Instant, Option, Result } from '@mentora/kernel';
import { err, instantOf, none, ok, some } from '@mentora/kernel';
import { FakeClock } from '@mentora/testing-clock';
import { describe, expect, it } from 'vitest';

import { SequenceBuilder } from './builder/sequence-builder.js';
import { SequenceExecutionException, SequenceReceptionException } from './errors/sequence-errors.js';
import type { SequenceDefinition } from './interfaces/sequence-definition.js';
import type { SequenceRefusalLike } from './result/sequence-outcome.js';
import { SEQUENCE_STEPS, sequenceStepIndex } from './step/sequence-steps.js';
import { RecordingJournal } from './testing/recording-journal.js';

/**
 * The generic pipeline proven with a DOMAIN-FREE test definition (a plain
 * counter unit): the kernel must never know Agreement. Every mandated
 * scenario: exact order, order immutability, success, refusal (validities /
 * act / structural retention), interruption (reception exception), retry,
 * abandon, journal, builder, context/injections.
 */

interface TestWire {
  readonly type: string;
  readonly id: string;
}
interface TestCommand {
  readonly id: string;
  readonly instant: Instant;
  readonly actor: ActorRef;
}
interface TestUnit {
  readonly id: string;
  readonly acted: boolean;
}
type TestRefusal = SequenceRefusalLike;

interface DefinitionBehaviour {
  refuseValidate?: boolean;
  refuseAct?: boolean;
  refuseRetain?: boolean;
  throwAtRetainTimes?: number;
  throwAtLoad?: boolean;
  actThrows?: boolean;
}

const makeDefinition = (
  behaviour: DefinitionBehaviour = {},
): SequenceDefinition<TestWire, TestCommand, TestUnit, TestRefusal> & {
  seenInstants: Instant[];
  seenActors: ActorRef[];
} => {
  let retainThrowsLeft = behaviour.throwAtRetainTimes ?? 0;
  const seenInstants: Instant[] = [];
  const seenActors: ActorRef[] = [];
  return {
    seenInstants,
    seenActors,
    commandTypeOf: (wire) => wire.type,
    actIdentityOf: (wire) => `act-${wire.id}` as CommandId,
    receive: (payload) => {
      const raw = payload as Partial<TestWire> | null;
      if (raw === null || typeof raw !== 'object' || typeof raw.id !== 'string') {
        return err([{ code: 'CONTRACT.FIELD_MISSING', field: 'id', message: 'id required' }]);
      }
      return ok({ type: raw.type ?? 'TestCommand', id: raw.id });
    },
    load: (wire): Promise<Option<TestUnit>> => {
      if (behaviour.throwAtLoad === true) {
        return Promise.reject(new Error('registry unreachable'));
      }
      return Promise.resolve(wire.id === 'new' ? none : some({ id: wire.id, acted: false }));
    },
    validate: (wire, instant, actor): Promise<Result<TestCommand, TestRefusal>> => {
      seenInstants.push(instant);
      seenActors.push(actor);
      if (behaviour.refuseValidate === true) {
        return Promise.resolve(err({ reason: 'ValidityRefused', message: 'source said no' }));
      }
      return Promise.resolve(ok({ id: wire.id, instant, actor }));
    },
    act: (unit, command): Result<TestUnit, TestRefusal> => {
      if (behaviour.actThrows === true) {
        throw new SequenceReceptionException([
          { code: 'CONTRACT.FIELD_TYPE', field: 'x', message: 'malformed inside act' },
        ]);
      }
      if (behaviour.refuseAct === true) {
        return err({ reason: 'TransitionUnavailable', message: 'unit said no' });
      }
      const base = unit.some ? unit.value : { id: command.id, acted: false };
      return ok({ ...base, acted: true });
    },
    retain: (): Promise<Result<void, TestRefusal>> => {
      if (retainThrowsLeft > 0) {
        retainThrowsLeft -= 1;
        return Promise.reject(new Error('optimistic conflict'));
      }
      if (behaviour.refuseRetain === true) {
        return Promise.resolve(
          err({ reason: 'TimeSlotUnavailable', message: 'structural R-A refusal' }),
        );
      }
      return Promise.resolve(ok(undefined));
    },
  };
};

const ACTOR = 'actor-1' as ActorRef;
const CORRELATION = 'corr-1' as CorrelationId;
const T0 = instantOf(42_000);

const runner = (behaviour?: DefinitionBehaviour, maxAttempts = 1) => {
  const journal = new RecordingJournal();
  const definition = makeDefinition(behaviour);
  const executor = new SequenceBuilder<TestWire, TestCommand, TestUnit, TestRefusal>()
    .withDefinition(definition)
    .withClock(FakeClock.at(T0))
    .withJournal(journal)
    .withMaxAttempts(maxAttempts)
    .build();
  return { journal, definition, executor };
};

describe('the frozen order (A-2 — ten steps, this order, no other)', () => {
  it('a successful run journals ALL TEN steps in the exact frozen order', async () => {
    const { journal, executor } = runner();
    const outcome = await executor.execute({ payload: { id: 'u1' }, actor: ACTOR, correlationId: CORRELATION });
    expect(outcome.kind).toBe('executed');
    expect(journal.steps()).toEqual([...SEQUENCE_STEPS]);
  });

  it('the order is immutable at runtime (frozen array)', () => {
    expect(Object.isFrozen(SEQUENCE_STEPS)).toBe(true);
    expect(() => {
      (SEQUENCE_STEPS as unknown as string[]).push('ProjectionStage');
    }).toThrow(TypeError);
  });

  it('Loading precedes SourceValidities (F4.1.99) and retention precedes publication (A-4)', () => {
    expect(sequenceStepIndex('Loading')).toBeLessThan(sequenceStepIndex('SourceValidities'));
    expect(sequenceStepIndex('AtomicRetention')).toBeLessThan(sequenceStepIndex('Publication'));
  });
});

describe('success path', () => {
  it('executes the act and returns the unit with attempts=1', async () => {
    const { executor } = runner();
    const outcome = await executor.execute({ payload: { id: 'u1' }, actor: ACTOR, correlationId: CORRELATION });
    expect(outcome.kind).toBe('executed');
    if (outcome.kind === 'executed') {
      expect(outcome.unit).toEqual({ id: 'u1', acted: true });
      expect(outcome.attempts).toBe(1);
    }
  });

  it('injects the ONE captured instant and the authenticated actor (A-6)', async () => {
    const { executor, definition } = runner();
    await executor.execute({ payload: { id: 'u1' }, actor: ACTOR, correlationId: CORRELATION });
    expect(definition.seenInstants).toEqual([T0]);
    expect(definition.seenActors).toEqual([ACTOR]);
  });

  it('births through the definition when nothing was loaded (Factory path)', async () => {
    const { executor } = runner();
    const outcome = await executor.execute({ payload: { id: 'new' }, actor: ACTOR, correlationId: CORRELATION });
    expect(outcome.kind === 'executed' && outcome.unit.acted).toBe(true);
  });
});

describe('interrupted pipeline (pas 1 — Exception channel, A-7)', () => {
  it('a malformed payload ends at Reception: exception outcome, single journal record', async () => {
    const { journal, executor } = runner();
    const outcome = await executor.execute({ payload: { nope: 1 }, actor: ACTOR, correlationId: CORRELATION });
    expect(outcome.kind).toBe('exception');
    expect(journal.outcomes()).toEqual([['Reception', 'exception']]);
  });

  it('a SequenceExecutionException thrown by the domain propagates RAW (never converted — A-7)', async () => {
    const { executor } = runner({ actThrows: true });
    await expect(
      executor.execute({ payload: { id: 'u1' }, actor: ACTOR, correlationId: CORRELATION }),
    ).rejects.toBeInstanceOf(SequenceExecutionException);
  });
});

describe('refusal paths (pas 7 — no retention, no fact, correlated journal)', () => {
  it('a validity refusal returns motivated; Act/Retention/Publication never run', async () => {
    const { journal, executor } = runner({ refuseValidate: true });
    const outcome = await executor.execute({ payload: { id: 'u1' }, actor: ACTOR, correlationId: CORRELATION });
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') expect(outcome.refusal.reason).toBe('ValidityRefused');
    const steps = journal.steps();
    expect(steps).not.toContain('Act');
    expect(steps).not.toContain('AtomicRetention');
    expect(steps).not.toContain('Publication');
    expect(steps.at(-1)).toBe('ResponseAndJournal');
  });

  it('an act refusal exits through RefusalReturn with its reason journaled', async () => {
    const { journal, executor } = runner({ refuseAct: true });
    const outcome = await executor.execute({ payload: { id: 'u1' }, actor: ACTOR, correlationId: CORRELATION });
    expect(outcome.kind).toBe('refused');
    expect(journal.outcomes()).toContainEqual(['Act', 'refused']);
    expect(journal.outcomes()).toContainEqual(['RefusalReturn', 'refused']);
    expect(journal.steps()).not.toContain('AtomicRetention');
    const refusalEntry = journal.entries.find((entry) => entry.step === 'RefusalReturn');
    expect(refusalEntry?.note).toBe('TransitionUnavailable');
  });

  it('a STRUCTURAL retention refusal (R-A key) returns motivated after pas 8', async () => {
    const { journal, executor } = runner({ refuseRetain: true });
    const outcome = await executor.execute({ payload: { id: 'u1' }, actor: ACTOR, correlationId: CORRELATION });
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') expect(outcome.refusal.reason).toBe('TimeSlotUnavailable');
    expect(journal.outcomes()).toContainEqual(['AtomicRetention', 'refused']);
    expect(journal.steps()).not.toContain('Publication');
  });
});

describe('retry & abandon (Failure channel — mechanical because a value)', () => {
  it('a retryable retention Failure re-enters at Loading; injections run ONCE', async () => {
    const { journal, executor, definition } = runner({ throwAtRetainTimes: 1 }, 3);
    const outcome = await executor.execute({ payload: { id: 'u1' }, actor: ACTOR, correlationId: CORRELATION });
    expect(outcome.kind).toBe('executed');
    if (outcome.kind === 'executed') expect(outcome.attempts).toBe(2);
    const steps = journal.steps();
    expect(steps.filter((step) => step === 'Reception')).toHaveLength(1);
    expect(steps.filter((step) => step === 'TimeInjection')).toHaveLength(1);
    expect(steps.filter((step) => step === 'Loading')).toHaveLength(2);
    expect(steps.filter((step) => step === 'AtomicRetention')).toHaveLength(2);
    // ONE instant for the whole execution, across attempts (A-6).
    expect(definition.seenInstants).toEqual([T0, T0]);
    expect(journal.outcomes()).toContainEqual(['AtomicRetention', 'failure']);
  });

  it('a loading Failure is retryable too', async () => {
    const { executor } = runner({ throwAtLoad: true }, 1);
    const outcome = await executor.execute({ payload: { id: 'u1' }, actor: ACTOR, correlationId: CORRELATION });
    expect(outcome.kind).toBe('abandoned');
  });

  it('exhausted retries ABANDON with a journaled abandon record — never silent', async () => {
    const { journal, executor } = runner({ throwAtRetainTimes: 99 }, 2);
    const outcome = await executor.execute({ payload: { id: 'u1' }, actor: ACTOR, correlationId: CORRELATION });
    expect(outcome.kind).toBe('abandoned');
    if (outcome.kind === 'abandoned') {
      expect(outcome.attempts).toBe(2);
      expect(outcome.failure.code).toBe('SEQUENCE.RETENTION_FAILURE');
      expect(outcome.failure.retryable).toBe(true);
    }
    const last = journal.entries.at(-1);
    expect(last?.outcome).toBe('abandoned');
    expect(last?.note).toBe('SEQUENCE.RETENTION_FAILURE');
  });
});

describe('the journal (A-10; Journal ≠ Log)', () => {
  it('every record carries the correlation, the command type and the attempt', async () => {
    const { journal, executor } = runner({ throwAtRetainTimes: 1 }, 2);
    await executor.execute({ payload: { id: 'u1' }, actor: ACTOR, correlationId: CORRELATION });
    for (const entry of journal.entries) {
      expect(entry.correlationId).toBe(CORRELATION);
      expect(entry.attempt === 1 || entry.attempt === 2).toBe(true);
    }
    const afterReception = journal.entries.filter((entry) => entry.step !== 'Reception');
    for (const entry of afterReception) {
      expect(entry.commandType).toBe('TestCommand');
    }
  });
});

describe('the builder (handlers never compose the stages — I-2/I-3)', () => {
  it('refuses to build without definition, clock or journal (fail closed)', () => {
    const bare = new SequenceBuilder<TestWire, TestCommand, TestUnit, TestRefusal>();
    expect(() => bare.build()).toThrow();
    expect(() =>
      new SequenceBuilder<TestWire, TestCommand, TestUnit, TestRefusal>()
        .withDefinition(makeDefinition())
        .build(),
    ).toThrow();
    expect(() => bare.withMaxAttempts(0)).toThrow();
  });
});
