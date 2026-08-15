import type { ActorRef, CorrelationId } from '@mentora/contracts';
import type { Option, Result } from '@mentora/kernel';
import { err, none, ok, some } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { SequenceReceptionException } from './errors/sequence-errors.js';
import { QueryDispatch } from './read/query-dispatch.js';
import type { ReadDefinition } from './read/read-definition.js';
import { ReadExecutor } from './read/read-executor.js';
import { READ_STEPS, readStepIndex } from './read/read-steps.js';
import type { SequenceRefusalLike, SequenceViolation } from './result/sequence-outcome.js';
import { RecordingReadJournal } from './testing/recording-read-journal.js';

/**
 * The Séquence de Lecture proven with a DOMAIN-FREE definition (a plain
 * record view): six frozen steps, "réception → identité → R-C → lecture →
 * réponse → journal" (F4.99 §1) — no mutation, no retention, no retry.
 */

interface TestQuery {
  readonly type: string;
  readonly id: string;
}
interface TestView {
  readonly id: string;
  readonly value: number;
  readonly secret: string;
}
interface TestResponse {
  readonly id: string;
  readonly value: number;
}

interface ReaderBehaviour {
  denyRight?: boolean;
  throwAtRights?: boolean;
  throwAtRead?: boolean;
  readThrowsSequenceException?: boolean;
}

const makeDefinition = (
  behaviour: ReaderBehaviour = {},
): ReadDefinition<TestQuery, TestView, TestResponse, SequenceRefusalLike> => ({
  queryTypeOf: (wire) => wire.type,
  receive: (payload): Result<TestQuery, readonly SequenceViolation[]> => {
    const raw = payload as Partial<TestQuery> | null;
    if (raw === null || typeof raw !== 'object' || typeof raw.id !== 'string') {
      return err([{ code: 'CONTRACT.FIELD_MISSING', field: 'id', message: 'id required' }]);
    }
    return ok({ type: raw.type ?? 'TestQuery', id: raw.id });
  },
  entitled: (): Promise<Result<void, SequenceRefusalLike>> => {
    if (behaviour.throwAtRights === true) {
      return Promise.reject(new Error('rights source unreachable'));
    }
    if (behaviour.denyRight === true) {
      return Promise.resolve(err({ reason: 'RightMissing', message: 'not a right holder' }));
    }
    return Promise.resolve(ok(undefined));
  },
  read: (query): Promise<Option<TestView>> => {
    if (behaviour.readThrowsSequenceException === true) {
      return Promise.reject(
        new SequenceReceptionException([
          { code: 'CONTRACT.FIELD_TYPE', field: 'x', message: 'malformed inside read' },
        ]),
      );
    }
    if (behaviour.throwAtRead === true) {
      return Promise.reject(new Error('read model unreachable'));
    }
    return Promise.resolve(
      query.id === 'ghost' ? none : some({ id: query.id, value: 42, secret: 'never-leaves' }),
    );
  },
  absent: () => ({ reason: 'ViewUnavailable', message: 'nothing readable' }),
  respond: (view) => ({ id: view.id, value: view.value }),
});

const ACTOR = 'actor-1' as ActorRef;
const CORRELATION = 'corr-read-1' as CorrelationId;

const runner = (behaviour?: ReaderBehaviour) => {
  const journal = new RecordingReadJournal();
  const executor = new ReadExecutor({ definition: makeDefinition(behaviour), journal });
  const run = (payload: unknown) => executor.execute({ payload, actor: ACTOR, correlationId: CORRELATION });
  return { journal, executor, run };
};

describe('the frozen six (F4.99 §1 — no fourth path)', () => {
  it('an answered read journals ALL SIX steps in the exact frozen order', async () => {
    const { journal, run } = runner();
    const outcome = await run({ id: 'v1' });
    expect(outcome.kind).toBe('answered');
    expect(journal.steps()).toEqual([...READ_STEPS]);
  });

  it('the order is immutable at runtime and R-C PRECEDES the lecture', () => {
    expect(Object.isFrozen(READ_STEPS)).toBe(true);
    expect(() => {
      (READ_STEPS as unknown as string[]).push('MutationStep');
    }).toThrow(TypeError);
    expect(readStepIndex('RightsCheck')).toBeLessThan(readStepIndex('Reading'));
    expect(readStepIndex('Response')).toBeLessThan(readStepIndex('Journal'));
  });

  it('the six steps contain NO retention, NO publication, NO time injection', () => {
    const steps: readonly string[] = READ_STEPS;
    expect(steps).not.toContain('AtomicRetention');
    expect(steps).not.toContain('Publication');
    expect(steps).not.toContain('TimeInjection');
  });
});

describe('the answer', () => {
  it('maps the view to the response — the raw view never exits', async () => {
    const { run } = runner();
    const outcome = await run({ id: 'v1' });
    expect(outcome.kind === 'answered' && outcome.response).toEqual({ id: 'v1', value: 42 });
  });
});

describe('refusals — motivated values, never silence (F4.1 §5, F2.6)', () => {
  it('a missing right refuses at pas 3 and the lecture NEVER runs', async () => {
    const { journal, run } = runner({ denyRight: true });
    const outcome = await run({ id: 'v1' });
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') {
      expect(outcome.refusal.reason).toBe('RightMissing');
    }
    expect(journal.steps()).not.toContain('Reading');
    expect(journal.steps().at(-1)).toBe('Journal');
  });

  it('nothing readable refuses motivated after the lecture', async () => {
    const { journal, run } = runner();
    const outcome = await run({ id: 'ghost' });
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') {
      expect(outcome.refusal.reason).toBe('ViewUnavailable');
    }
    expect(journal.outcomes()).toContainEqual(['Reading', 'refused']);
  });
});

describe('the other channels (A-7 — never mixed)', () => {
  it('a malformed payload ends at Reception: exception outcome, single record', async () => {
    const { journal, run } = runner();
    const outcome = await run({ nope: 1 });
    expect(outcome.kind).toBe('exception');
    expect(journal.outcomes()).toEqual([['Reception', 'exception']]);
  });

  it('a technical throw at the lecture is a Failure VALUE — journaled, NOT retried', async () => {
    const { journal, run } = runner({ throwAtRead: true });
    const outcome = await run({ id: 'v1' });
    expect(outcome.kind).toBe('failure');
    if (outcome.kind === 'failure') {
      expect(outcome.failure.code).toBe('READ.READING_FAILURE');
      expect(outcome.failure.retryable).toBe(true);
    }
    expect(journal.steps().filter((step) => step === 'Reading')).toHaveLength(1);
  });

  it('a technical throw at the rights source is a Failure too', async () => {
    const { run } = runner({ throwAtRights: true });
    const outcome = await run({ id: 'v1' });
    expect(outcome.kind === 'failure' && outcome.failure.code).toBe('READ.RIGHTS_FAILURE');
  });

  it('a SequenceExecutionException propagates RAW (a caller defect is never converted)', async () => {
    const { run } = runner({ readThrowsSequenceException: true });
    await expect(run({ id: 'v1' })).rejects.toBeInstanceOf(SequenceReceptionException);
  });
});

describe('the Query Dispatch (F4.1 §6 — table fermée, un lecteur par Query)', () => {
  const carrierOf = (queryType: string) => {
    const journal = new RecordingReadJournal();
    const executor = new ReadExecutor({ definition: makeDefinition(), journal });
    return {
      queryType,
      execute: (input: Parameters<ReadExecutor<TestQuery, TestView, TestResponse, SequenceRefusalLike>['execute']>[0]) =>
        executor.execute(input),
    };
  };

  it('routes a query to its ONE reader and returns its ONE answer', async () => {
    const dispatch = new QueryDispatch([carrierOf('TestQuery'), carrierOf('OtherQuery')]);
    const outcome = await dispatch.dispatch({
      payload: { type: 'TestQuery', id: 'v1' },
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('answered');
    expect(dispatch.queryTypes).toEqual(['TestQuery', 'OtherQuery']);
  });

  it('an unknown query type is a malformed call — the Exception channel', async () => {
    const dispatch = new QueryDispatch([carrierOf('TestQuery')]);
    const outcome = await dispatch.dispatch({
      payload: { type: 'NobodyCarriesThis' },
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('exception');
    if (outcome.kind === 'exception') {
      expect(outcome.violations[0]?.code).toBe('CONTRACT.UNKNOWN_CONTRACT');
    }
  });

  it('two carriers for the same Query refuse at assembly — fail closed', () => {
    expect(() => new QueryDispatch([carrierOf('TestQuery'), carrierOf('TestQuery')])).toThrow();
  });
});
