import { ReadExecutor, RecordingReadJournal, READ_STEPS } from '@mentora/application-kernel';
import type { ActorRef, CorrelationId } from '@mentora/contracts';
import type { AgreementId, ClientId, ExpertId } from '@mentora/contracts-agreement';
import { afterEach, describe, expect, it, vi } from 'vitest';

import { agreementQueryDispatch } from './dispatch/agreement-query-dispatch.js';
import { AgreementStateQueryApplicationService } from './services/agreement-state-query.application-service.js';
import { InMemoryAgreementStateReadPort } from './testing/agreement-read-doubles.js';

/**
 * The Agreement query side end to end on WIRE payloads: the ONE ratified read
 * (AgreementStateQuery, F3.3 §5) through the Séquence de Lecture — reception
 * by the published language, injected identity, the DECLARED grid ("les
 * parties, l'outillage du temps"), the lecture, the mapping ("l'état ⊘ les
 * conditions à des tiers"), the journal.
 */

const AGREEMENT = 'agr-1' as AgreementId;
const CLIENT = 'cli-1' as ClientId;
const EXPERT = 'exp-1' as ExpertId;
const TIME_TOOLING = 'time-tooling' as ActorRef;
const STRANGER = 'stranger-1' as ActorRef;
const CORRELATION = 'corr-q-1' as CorrelationId;

const VIEW = {
  agreementId: AGREEMENT,
  stateKind: 'Confirmed',
  slot: { startMs: 1_000, endMs: 2_000 },
  version: 3,
  clientId: CLIENT,
  expertId: EXPERT,
} as const;

const queryPayload = (id: string = AGREEMENT) => ({
  type: 'AgreementStateQuery',
  contractVersion: 1,
  agreementId: id,
});

const harness = () => {
  const port = new InMemoryAgreementStateReadPort(TIME_TOOLING);
  port.seed(VIEW);
  const journal = new RecordingReadJournal();
  const service = new AgreementStateQueryApplicationService(
    { readPort: port, rightsPort: port },
    { journal },
  );
  const run = (payload: unknown, actor: ActorRef) =>
    service.execute({ payload, actor, correlationId: CORRELATION });
  return { port, journal, service, run };
};

describe('the ONE ratified read, answered (F3.3 §5)', () => {
  it('a party reads the state; the response carries EXACTLY the published shape', async () => {
    const { run } = harness();
    const outcome = await run(queryPayload(), CLIENT as unknown as ActorRef);
    expect(outcome.kind).toBe('answered');
    if (outcome.kind === 'answered') {
      expect(outcome.response).toEqual({
        contractVersion: 1,
        type: 'AgreementStateResponse',
        agreementId: AGREEMENT,
        stateKind: 'Confirmed',
        slot: { startMs: 1_000, endMs: 2_000 },
        version: 3,
      });
      // "l'état ⊘ les conditions à des tiers": the parties NEVER exit.
      expect(Object.keys(outcome.response)).not.toContain('clientId');
      expect(Object.keys(outcome.response)).not.toContain('expertId');
    }
  });

  it('the expert and the time tooling are right holders too (the declared grid)', async () => {
    const { run } = harness();
    expect((await run(queryPayload(), EXPERT as unknown as ActorRef)).kind).toBe('answered');
    expect((await run(queryPayload(), TIME_TOOLING)).kind).toBe('answered');
  });

  it('journals the six frozen steps of the Lecture in exact order', async () => {
    const { journal, run } = harness();
    await run(queryPayload(), CLIENT as unknown as ActorRef);
    expect(journal.steps()).toEqual([...READ_STEPS]);
    for (const entry of journal.entries) {
      expect(entry.correlationId).toBe(CORRELATION);
    }
  });
});

describe('R-C — "refuse motivé si le droit manque" (F4.1 §5)', () => {
  it('a stranger is refused at pas 3 and the lecture NEVER runs', async () => {
    const { journal, run } = harness();
    const outcome = await run(queryPayload(), STRANGER);
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') {
      expect(outcome.refusal.reason).toBe('RightMissing');
    }
    expect(journal.steps()).not.toContain('Reading');
  });

  it('nothing readable under the Identifier refuses motivated — never silence', async () => {
    const { run } = harness();
    const outcome = await run(queryPayload('agr-ghost'), TIME_TOOLING);
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') {
      expect(outcome.refusal.reason).toBe('AgreementUnavailable');
    }
  });
});

describe('the other channels (A-7)', () => {
  it('a malformed payload is the Exception channel — single Reception record', async () => {
    const { journal, run } = harness();
    const outcome = await run({ type: 'AgreementStateQuery' }, CLIENT as unknown as ActorRef);
    expect(outcome.kind).toBe('exception');
    expect(journal.outcomes()).toEqual([['Reception', 'exception']]);
  });

  it('a COMMAND payload is not a Query of the dictionary — Exception', async () => {
    const { run } = harness();
    const outcome = await run(
      { type: 'ConfirmAgreement', contractVersion: 1, commandId: 'c1', agreementId: AGREEMENT },
      CLIENT as unknown as ActorRef,
    );
    expect(outcome.kind).toBe('exception');
  });

  it('a technical read-model incapacity is a Failure VALUE — never retried here', async () => {
    const { port, run } = harness();
    port.failReads = true;
    const outcome = await run(queryPayload(), TIME_TOOLING);
    expect(outcome.kind).toBe('failure');
    if (outcome.kind === 'failure') {
      expect(outcome.failure.code).toBe('READ.READING_FAILURE');
      expect(outcome.failure.retryable).toBe(true);
    }
  });
});

describe('the dispatch (F4.1 §6 — UN Query, UN lecteur, UNE réponse)', () => {
  it('routes AgreementStateQuery to its one reader', async () => {
    const { service } = harness();
    const dispatch = agreementQueryDispatch(service);
    expect(dispatch.queryTypes).toEqual(['AgreementStateQuery']);
    const outcome = await dispatch.dispatch({
      payload: queryPayload(),
      actor: CLIENT as unknown as ActorRef,
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('answered');
  });

  it('an unknown read (ListAgreement, SearchAgreement…) does not exist — Exception', async () => {
    const { service } = harness();
    const dispatch = agreementQueryDispatch(service);
    for (const invented of ['ListAgreement', 'SearchAgreement', 'BrowseAgreement', 'FindAgreement']) {
      const outcome = await dispatch.dispatch({
        payload: { type: invented, contractVersion: 1, agreementId: AGREEMENT },
        actor: CLIENT as unknown as ActorRef,
        correlationId: CORRELATION,
      });
      expect(outcome.kind).toBe('exception');
    }
  });
});

describe('the reader is BORING (F4.1 §7)', () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('one call to the service is exactly ONE call to the ReadExecutor', async () => {
    const spy = vi.spyOn(ReadExecutor.prototype, 'execute');
    const { run } = harness();
    await run(queryPayload(), CLIENT as unknown as ActorRef);
    expect(spy).toHaveBeenCalledTimes(1);
  });

  it('the service declares nothing beyond its constructor and execute', () => {
    expect(Object.getOwnPropertyNames(AgreementStateQueryApplicationService.prototype)).toEqual([
      'constructor',
      'execute',
    ]);
  });
});
