import type { ActorRef, CommandId, CorrelationId } from '@mentora/contracts';
import type { Option, Result } from '@mentora/kernel';
import { instantOf, none, ok, some } from '@mentora/kernel';
import { FakeClock } from '@mentora/testing-clock';
import { describe, expect, it } from 'vitest';

import { SequenceReceptionException } from './errors/sequence-errors.js';
import { SequenceExecutor } from './executor/sequence-executor.js';
import type { SequenceDefinition } from './interfaces/sequence-definition.js';
import { ReactionBuilder } from './reaction/reaction-builder.js';
import type { ReactionDefinition } from './reaction/reaction-definition.js';
import { ReactionDispatch } from './reaction/reaction-dispatch.js';
import { ReactionReceptionException } from './reaction/reaction-errors.js';
import { QueryDispatch } from './read/query-dispatch.js';
import type { SequenceRefusalLike } from './result/sequence-outcome.js';
import { RecordingJournal } from './testing/recording-journal.js';
import { RecordingReactionJournal } from './testing/recording-reaction-journal.js';

/**
 * Edge-of-channel conformity across the three Sequences (A-7): raw
 * propagation of caller defects from EVERY I/O seam, non-Error technical
 * throws, non-object payloads at the dispatches, and the Exception classes
 * adapters throw at their boundaries. Additive spec — no frozen spec touched.
 */

const CORRELATION = 'corr-x' as CorrelationId;
const ACTOR = 'actor-x' as ActorRef;
const T0 = instantOf(1_000);

const CALLER_DEFECT = new SequenceReceptionException([
  { code: 'CONTRACT.FIELD_TYPE', field: 'x', message: 'caller defect' },
]);

type Unit = { readonly id: string };
type Refusal = SequenceRefusalLike;

const commandDefinition = (
  overrides: Partial<SequenceDefinition<{ id: string }, { id: string }, Unit, Refusal>>,
): SequenceDefinition<{ id: string }, { id: string }, Unit, Refusal> => ({
  commandTypeOf: () => 'ProbeCommand',
  actIdentityOf: (wire) => `act-${wire.id}` as CommandId,
  receive: (payload) => ok(payload as { id: string }),
  load: (): Promise<Option<Unit>> => Promise.resolve(none),
  validate: (wire): Promise<Result<{ id: string }, Refusal>> => Promise.resolve(ok(wire)),
  act: (_unit, command): Result<Unit, Refusal> => ok({ id: command.id }),
  retain: (): Promise<Result<void, Refusal>> => Promise.resolve(ok(undefined)),
  ...overrides,
});

const runCommand = (
  overrides: Partial<SequenceDefinition<{ id: string }, { id: string }, Unit, Refusal>>,
) =>
  new SequenceExecutor({
    definition: commandDefinition(overrides),
    clock: FakeClock.at(T0),
    journal: new RecordingJournal(),
  }).execute({ payload: { id: 'u1' }, actor: ACTOR, correlationId: CORRELATION });

describe('raw propagation from every I/O seam of the Séquence de Commande (A-7)', () => {
  it('a caller defect thrown at Loading propagates raw', async () => {
    await expect(
      runCommand({ load: () => Promise.reject(CALLER_DEFECT) }),
    ).rejects.toBeInstanceOf(SequenceReceptionException);
  });

  it('a caller defect thrown at SourceValidities propagates raw', async () => {
    await expect(
      runCommand({ validate: () => Promise.reject(CALLER_DEFECT) }),
    ).rejects.toBeInstanceOf(SequenceReceptionException);
  });

  it('a caller defect thrown at AtomicRetention propagates raw', async () => {
    await expect(
      runCommand({ retain: () => Promise.reject(CALLER_DEFECT) }),
    ).rejects.toBeInstanceOf(SequenceReceptionException);
  });
});

describe('the reaction channel edges', () => {
  const reactionDefinition: ReactionDefinition<{ id: string }, { n: number }, string> = {
    factTypeOf: () => 'ProbeFact',
    factIdentityOf: (fact) => fact.id,
    journeyKeyOf: (fact) => fact.id,
    receive: (payload) => ok(payload as { id: string }),
    seen: () => Promise.resolve(false),
    positionOf: (): Promise<Option<{ n: number }>> => Promise.resolve(some({ n: 0 })),
    react: (position) => ({
      position: { n: (position.some ? position.value.n : 0) + 1 },
      commands: [],
    }),
    // A non-Error throw: the Failure channel must describe it faithfully.
    // eslint-disable-next-line @typescript-eslint/prefer-promise-reject-errors -- the non-Error path is exactly what this spec proves
    retain: () => Promise.reject('raw-string-incident'),
  };

  it('a non-Error technical throw becomes a described Failure and abandons on budget 1', async () => {
    const executor = new ReactionBuilder<{ id: string }, { n: number }, string>()
      .withDefinition(reactionDefinition)
      .withClock(FakeClock.at(T0))
      .withJournal(new RecordingReactionJournal())
      .build();
    const outcome = await executor.execute({ payload: { id: 'f1' }, correlationId: CORRELATION });
    expect(outcome.kind).toBe('abandoned');
    if (outcome.kind === 'abandoned') {
      expect(outcome.failure.message).toBe('raw-string-incident');
    }
  });

  it('ReactionReceptionException carries its violations for adapter boundaries', () => {
    const exception = new ReactionReceptionException([
      { code: 'CONTRACT.FIELD_MISSING', field: 'type', message: 'type required' },
    ]);
    expect(exception.code).toBe('REACTION.RECEPTION');
    expect(exception.message).toContain('type (CONTRACT.FIELD_MISSING)');
    expect(exception.violations).toHaveLength(1);
  });
});

describe('the dispatches refuse non-object payloads (Exception channel values)', () => {
  it('ReactionDispatch: a primitive payload is a malformed call', async () => {
    const dispatch = new ReactionDispatch([]);
    const outcome = await dispatch.dispatch({ payload: 42, correlationId: CORRELATION });
    expect(outcome.kind).toBe('exception');
  });

  it('QueryDispatch: a primitive payload is a malformed call', async () => {
    const dispatch = new QueryDispatch([]);
    const outcome = await dispatch.dispatch({
      payload: 'not-an-object',
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('exception');
  });
});
