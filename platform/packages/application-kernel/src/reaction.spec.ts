import type { CorrelationId } from '@mentora/contracts';
import type { Instant, Option, Result } from '@mentora/kernel';
import { err, instantOf, none, ok, some } from '@mentora/kernel';
import { FakeClock } from '@mentora/testing-clock';
import { describe, expect, it } from 'vitest';

import { SequenceReceptionException } from './errors/sequence-errors.js';
import { ReactionBuilder } from './reaction/reaction-builder.js';
import type { ReactionDefinition, ReactionResult } from './reaction/reaction-definition.js';
import { ReactionDispatch } from './reaction/reaction-dispatch.js';
import { ReactionExecutor } from './reaction/reaction-executor.js';
import { REACTION_STEPS, reactionStepIndex } from './reaction/reaction-steps.js';
import type { SequenceViolation } from './result/sequence-outcome.js';
import { RecordingReactionJournal } from './testing/recording-reaction-journal.js';

/**
 * The Séquence de Réaction proven with a DOMAIN-FREE journey (a counter
 * position emitting probe commands): six frozen steps (F4.99 §1), Inbox
 * dedup by fact identity, PURE deterministic reaction, atomic retention of
 * the Outbox de commandes, structural relay, journal — no fourth path.
 */

interface TestFact {
  readonly type: string;
  readonly id: string;
  readonly sequence: number;
}
interface TestPosition {
  readonly key: string;
  readonly reacted: number;
}
interface TestCommand {
  readonly type: string;
  readonly journeyKey: string;
  readonly atMs: number;
}

interface JourneyBehaviour {
  throwAtPositionTimes?: number;
  throwAtRetainTimes?: number;
  reactThrowsSequenceException?: boolean;
}

const makeDefinition = (behaviour: JourneyBehaviour = {}) => {
  let positionThrowsLeft = behaviour.throwAtPositionTimes ?? 0;
  let retainThrowsLeft = behaviour.throwAtRetainTimes ?? 0;
  const seenIdentities = new Set<string>();
  const positions = new Map<string, TestPosition>();
  const retained: Array<{
    factIdentity: string;
    journeyKey: string;
    result: ReactionResult<TestPosition, TestCommand>;
  }> = [];

  const definition: ReactionDefinition<TestFact, TestPosition, TestCommand> = {
    factTypeOf: (fact) => fact.type,
    factIdentityOf: (fact) => `${fact.id}#${String(fact.sequence)}`,
    journeyKeyOf: (fact) => fact.id,
    receive: (payload): Result<TestFact, readonly SequenceViolation[]> => {
      const raw = payload as Partial<TestFact> | null;
      if (raw === null || typeof raw !== 'object' || typeof raw.id !== 'string') {
        return err([{ code: 'CONTRACT.FIELD_MISSING', field: 'id', message: 'id required' }]);
      }
      return ok({ type: raw.type ?? 'TestFact', id: raw.id, sequence: raw.sequence ?? 1 });
    },
    seen: (factIdentity) => Promise.resolve(seenIdentities.has(factIdentity)),
    positionOf: (journeyKey): Promise<Option<TestPosition>> => {
      if (positionThrowsLeft > 0) {
        positionThrowsLeft -= 1;
        return Promise.reject(new Error('position store unreachable'));
      }
      const position = positions.get(journeyKey);
      return Promise.resolve(position === undefined ? none : some(position));
    },
    react: (position, fact, instant: Instant): ReactionResult<TestPosition, TestCommand> => {
      if (behaviour.reactThrowsSequenceException === true) {
        throw new SequenceReceptionException([
          { code: 'CONTRACT.FIELD_TYPE', field: 'x', message: 'malformed inside react' },
        ]);
      }
      const before = position.some ? position.value.reacted : 0;
      return {
        position: { key: fact.id, reacted: before + 1 },
        commands: [{ type: 'ProbeCommand', journeyKey: fact.id, atMs: instant.epochMillis }],
      };
    },
    retain: (factIdentity, journeyKey, result) => {
      if (retainThrowsLeft > 0) {
        retainThrowsLeft -= 1;
        return Promise.reject(new Error('optimistic conflict'));
      }
      seenIdentities.add(factIdentity);
      positions.set(journeyKey, result.position);
      retained.push({ factIdentity, journeyKey, result });
      return Promise.resolve();
    },
  };
  return { definition, seenIdentities, positions, retained };
};

const CORRELATION = 'corr-react-1' as CorrelationId;
const T0 = instantOf(7_000_000);

const runner = (behaviour?: JourneyBehaviour, maxAttempts = 1) => {
  const journey = makeDefinition(behaviour);
  const journal = new RecordingReactionJournal();
  const executor = new ReactionBuilder<TestFact, TestPosition, TestCommand>()
    .withDefinition(journey.definition)
    .withClock(FakeClock.at(T0))
    .withJournal(journal)
    .withMaxAttempts(maxAttempts)
    .build();
  const run = (payload: unknown) => executor.execute({ payload, correlationId: CORRELATION });
  return { ...journey, journal, executor, run };
};

describe('the frozen six (F4.99 §1 — no fourth path)', () => {
  it('a reacted execution journals ALL SIX steps in the exact frozen order', async () => {
    const { journal, run } = runner();
    const outcome = await run({ id: 'j1', sequence: 1 });
    expect(outcome.kind).toBe('reacted');
    expect(journal.steps()).toEqual([...REACTION_STEPS]);
  });

  it('the order is immutable and retention PRECEDES the relay (Outbox de commandes)', () => {
    expect(Object.isFrozen(REACTION_STEPS)).toBe(true);
    expect(() => {
      (REACTION_STEPS as unknown as string[]).push('PublicationStage');
    }).toThrow(TypeError);
    expect(reactionStepIndex('Reaction')).toBeLessThan(reactionStepIndex('AtomicRetention'));
    expect(reactionStepIndex('AtomicRetention')).toBeLessThan(reactionStepIndex('Relay'));
  });
});

describe('the Inbox — dedup by FACT IDENTITY (M-4, at-least-once loi 15)', () => {
  it('an already-consumed fact is a DUPLICATE outcome, absorbed, nothing re-reacted', async () => {
    const { journal, retained, run } = runner();
    expect((await run({ id: 'j1', sequence: 1 })).kind).toBe('reacted');
    const redelivered = await run({ id: 'j1', sequence: 1 });
    expect(redelivered.kind).toBe('duplicate');
    if (redelivered.kind === 'duplicate') {
      expect(redelivered.factIdentity).toBe('j1#1');
    }
    expect(retained).toHaveLength(1);
    expect(journal.outcomes()).toContainEqual(['FactReception', 'duplicate']);
  });

  it('a NEW fact of the same journey advances the position (2nd reaction sees the 1st)', async () => {
    const { positions, run } = runner();
    await run({ id: 'j1', sequence: 1 });
    const second = await run({ id: 'j1', sequence: 2 });
    expect(second.kind === 'reacted' && second.position.reacted).toBe(2);
    expect(positions.get('j1')?.reacted).toBe(2);
  });
});

describe('the pure reaction and the atomic retention', () => {
  it('yields the new position AND the emitted commands, retained in ONE act', async () => {
    const { retained, run } = runner();
    const outcome = await run({ id: 'j1', sequence: 1 });
    expect(outcome.kind).toBe('reacted');
    if (outcome.kind === 'reacted') {
      expect(outcome.position).toEqual({ key: 'j1', reacted: 1 });
      expect(outcome.commands).toEqual([
        { type: 'ProbeCommand', journeyKey: 'j1', atMs: T0.epochMillis },
      ]);
    }
    // ONE retention call carrying mark + position + commands together.
    expect(retained).toHaveLength(1);
    expect(retained[0]?.factIdentity).toBe('j1#1');
    expect(retained[0]?.result.commands).toHaveLength(1);
  });

  it('the ONE injected instant reaches the reaction (A-6) — deterministic replay', async () => {
    const { run } = runner();
    const outcome = await run({ id: 'j1', sequence: 1 });
    expect(outcome.kind === 'reacted' && outcome.commands[0]?.atMs).toBe(T0.epochMillis);
  });
});

describe('the channels — no Refusal exists here (P-3: a PM never decides)', () => {
  it('a malformed payload is the Exception channel — single journal record', async () => {
    const { journal, run } = runner();
    const outcome = await run({ nonsense: true });
    expect(outcome.kind).toBe('exception');
    expect(journal.outcomes()).toEqual([['FactReception', 'exception']]);
  });

  it('a technical retention Failure retries from pas 3; injections run ONCE', async () => {
    const { journal, run } = runner({ throwAtRetainTimes: 1 }, 3);
    const outcome = await run({ id: 'j1', sequence: 1 });
    expect(outcome.kind).toBe('reacted');
    if (outcome.kind === 'reacted') {
      expect(outcome.attempts).toBe(2);
    }
    const steps = journal.steps();
    expect(steps.filter((step) => step === 'FactReception')).toHaveLength(1);
    expect(steps.filter((step) => step === 'Injections')).toHaveLength(1);
    expect(steps.filter((step) => step === 'Reaction')).toHaveLength(2);
    expect(journal.outcomes()).toContainEqual(['AtomicRetention', 'failure']);
  });

  it('a position-store Failure is retryable too', async () => {
    const { run } = runner({ throwAtPositionTimes: 1 }, 2);
    const outcome = await run({ id: 'j1', sequence: 1 });
    expect(outcome.kind === 'reacted' && outcome.attempts).toBe(2);
  });

  it('an exhausted TECHNICAL budget ABANDONS with a journaled witness (M-8)', async () => {
    const { journal, run } = runner({ throwAtRetainTimes: 99 }, 2);
    const outcome = await run({ id: 'j1', sequence: 1 });
    expect(outcome.kind).toBe('abandoned');
    if (outcome.kind === 'abandoned') {
      expect(outcome.attempts).toBe(2);
      expect(outcome.failure.code).toBe('REACTION.RETENTION_FAILURE');
      expect(outcome.failure.retryable).toBe(true);
    }
    expect(journal.entries.at(-1)?.outcome).toBe('abandoned');
  });

  it('a SequenceExecutionException propagates RAW (A-7)', async () => {
    const { run } = runner({ reactThrowsSequenceException: true });
    await expect(run({ id: 'j1', sequence: 1 })).rejects.toBeInstanceOf(SequenceReceptionException);
  });
});

describe('the journal (A-10 — correlated, deterministic, content-free)', () => {
  it('every record carries the correlation, the fact type and the attempt', async () => {
    const { journal, run } = runner({ throwAtRetainTimes: 1 }, 2);
    await run({ id: 'j1', sequence: 1 });
    for (const entry of journal.entries) {
      expect(entry.correlationId).toBe(CORRELATION);
      expect(entry.factType).toBe('TestFact');
      expect(entry.attempt === 1 || entry.attempt === 2).toBe(true);
    }
  });
});

describe('the ReactionDispatch (M-5 — table close, declared, no discovery)', () => {
  const carrierOf = (factType: string) => {
    const journey = makeDefinition();
    const executor = new ReactionExecutor({
      definition: journey.definition,
      clock: FakeClock.at(T0),
      journal: new RecordingReactionJournal(),
    });
    return {
      factType,
      execute: (input: Parameters<ReactionExecutor<TestFact, TestPosition, TestCommand>['execute']>[0]) =>
        executor.execute(input),
    };
  };

  it('routes a fact to its ONE declared reaction', async () => {
    const dispatch = new ReactionDispatch([carrierOf('TestFact'), carrierOf('OtherFact')]);
    const outcome = await dispatch.dispatch({
      payload: { type: 'TestFact', id: 'j1', sequence: 1 },
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('reacted');
    expect(dispatch.factTypes).toEqual(['TestFact', 'OtherFact']);
  });

  it('an unknown fact type is the Exception channel — no dynamic discovery', async () => {
    const dispatch = new ReactionDispatch([carrierOf('TestFact')]);
    const outcome = await dispatch.dispatch({
      payload: { type: 'NobodyConsumesThis' },
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('exception');
  });

  it('two reactions for the same fact refuse at assembly — fail closed', () => {
    expect(() => new ReactionDispatch([carrierOf('TestFact'), carrierOf('TestFact')])).toThrow();
  });
});

describe('the builder (fail closed)', () => {
  it('refuses to build without definition, clock or journal', () => {
    expect(() => new ReactionBuilder().build()).toThrow();
    expect(() =>
      new ReactionBuilder<TestFact, TestPosition, TestCommand>()
        .withDefinition(makeDefinition().definition)
        .build(),
    ).toThrow();
    expect(() => new ReactionBuilder().withMaxAttempts(0)).toThrow();
  });
});
