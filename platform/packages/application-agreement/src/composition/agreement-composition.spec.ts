import { RecordingJournal, RecordingReadJournal } from '@mentora/application-kernel';
import type { ActorRef, CorrelationId } from '@mentora/contracts';
import { AGREEMENT_COMMAND_TYPES } from '@mentora/contracts-agreement';
import type { AgreementId, ClientId, ExpertId } from '@mentora/contracts-agreement';
import type { Agreement, AgreementRefusal, AgreementRepository } from '@mentora/domain-agreement';
import type { Option, Result } from '@mentora/kernel';
import { instantOf, none, ok, some } from '@mentora/kernel';
import { FakeClock } from '@mentora/testing-clock';
import { describe, expect, it } from 'vitest';

import { InMemoryAgreementStateReadPort } from '../query/testing/agreement-read-doubles.js';

import type { AgreementCompositionProviders } from './agreement-composition.js';
import { composeAgreement } from './agreement-composition.js';

/**
 * The Root's conformity: ONE composition point builds the WHOLE graph
 * explicitly (Pure DI — F4.4 §2/I-2), the closed tables cover exactly the
 * ratified catalogue (boot validation, fail closed — F4.4 §7), the Policies
 * are built HERE with injected product parameters (F4.1 §4), and every
 * pipeline shares the SAME injected instances (clock, journal, repository).
 */

const HOUR = 3_600_000;
const T0 = instantOf(1_000_000_000);
const SLOT = { startMs: T0.epochMillis + 10 * HOUR, endMs: T0.epochMillis + 11 * HOUR };
const FRAME = [{ startMs: T0.epochMillis, endMs: T0.epochMillis + 100 * HOUR }];
const ACTOR = 'actor-1' as ActorRef;
const CORRELATION = 'corr-root-1' as CorrelationId;

class InMemoryAgreementRepository implements AgreementRepository {
  private readonly store = new Map<string, Agreement>();

  byId(id: AgreementId): Promise<Option<Agreement>> {
    const found = this.store.get(id);
    return Promise.resolve(found === undefined ? none : some(found));
  }

  byExpertAndWindow(): Promise<readonly Agreement[]> {
    return Promise.resolve([]);
  }

  retain(agreement: Agreement): Promise<Result<void, AgreementRefusal>> {
    this.store.set(agreement.id, agreement.retained());
    return Promise.resolve(ok(undefined));
  }

  stored(id: string): Agreement | undefined {
    return this.store.get(id);
  }
}

const base = (type: string, id: string) => ({
  type,
  contractVersion: 1,
  commandId: `cmd-${type}-${id}`,
  agreementId: id,
});
const requestPayload = (id = 'agr-1') => ({
  ...base('RequestAgreement', id),
  clientId: 'cli-1',
  expertId: 'exp-1',
  offerId: 'off-1',
  slot: SLOT,
  availabilityWindows: FRAME,
});
const acceptPayload = (id = 'agr-1') => ({ ...base('AcceptAgreement', id), expertId: 'exp-1' });
const confirmPayload = (id = 'agr-1') => ({
  ...base('ConfirmAgreement', id),
  settlementReference: 'settlement-1',
});
const cancelPayload = (id = 'agr-1') => ({
  ...base('CancelAgreement', id),
  cancelledBy: { role: 'Expert', id: 'exp-1' },
  motive: 'schedule conflict',
});

const providersOf = (overrides: Partial<AgreementCompositionProviders> = {}) => {
  const repository = new InMemoryAgreementRepository();
  const readPort = new InMemoryAgreementStateReadPort('time-tooling' as ActorRef);
  const commandJournal = new RecordingJournal();
  const readJournal = new RecordingReadJournal();
  const providers: AgreementCompositionProviders = {
    repository,
    stateReadPort: readPort,
    readRightsPort: readPort,
    clock: FakeClock.at(T0),
    idGenerator: { generate: () => 'generated-1' },
    commandJournal,
    readJournal,
    product: {
      reschedule: { minimumNoticeMillis: HOUR, maximumReschedules: 3 },
      cancellation: { minimumNoticeMillis: HOUR },
    },
    ...overrides,
  };
  return { providers, repository, readPort, commandJournal, readJournal };
};

const dispatchCommand = (
  assembly: ReturnType<typeof composeAgreement>,
  payload: unknown,
) => assembly.commandDispatch.dispatch({ payload, actor: ACTOR, correlationId: CORRELATION });

describe('the ONE composition point (F4.4 §2 — Pure DI, readable graph)', () => {
  it('assembles the complete graph: nine services, three dispatches, two policies', () => {
    const { providers } = providersOf();
    const assembly = composeAgreement(providers);
    expect(Object.keys(assembly.services)).toEqual([
      'request',
      'accept',
      'reject',
      'confirm',
      'reschedule',
      'cancel',
      'lapse',
      'elapse',
      'stateQuery',
    ]);
    expect(assembly.policies.reschedule).toBeDefined();
    expect(assembly.policies.cancellation).toBeDefined();
    expect(assembly.machinery.clock).toBe(providers.clock);
    expect(assembly.machinery.idGenerator).toBe(providers.idGenerator);
  });

  it('the command table carries EXACTLY the ratified catalogue (boot validation, F4.4 §7)', () => {
    const assembly = composeAgreement(providersOf().providers);
    expect([...assembly.commandDispatch.commandTypes].sort()).toEqual(
      [...AGREEMENT_COMMAND_TYPES].sort(),
    );
  });

  it('the query table serves exactly the ONE ratified read (F3.3 §5)', () => {
    const assembly = composeAgreement(providersOf().providers);
    expect(assembly.queryDispatch.queryTypes).toEqual(['AgreementStateQuery']);
  });

  it('the reaction table is CLOSED AND EMPTY — the 1C-5/1C-6 STOPs are law here', async () => {
    const assembly = composeAgreement(providersOf().providers);
    expect(assembly.reactionDispatch.factTypes).toEqual([]);
    const outcome = await assembly.reactionDispatch.dispatch({
      payload: { type: 'AgreementElapsed' },
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('exception');
  });
});

describe('the assembled graph runs — same injected instances everywhere', () => {
  it('a full journey flows through the Command Dispatch over the ONE shared repository', async () => {
    const { providers, repository } = providersOf();
    const assembly = composeAgreement(providers);
    expect((await dispatchCommand(assembly, requestPayload())).kind).toBe('executed');
    expect((await dispatchCommand(assembly, acceptPayload())).kind).toBe('executed');
    expect((await dispatchCommand(assembly, confirmPayload())).kind).toBe('executed');
    expect(repository.stored('agr-1')?.state.kind).toBe('Confirmed');
  });

  it('all EIGHT carriers route through the dispatch (reject, reschedule, cancel, lapse, elapse)', async () => {
    const { providers, repository } = providersOf();
    const assembly = composeAgreement(providers);

    await dispatchCommand(assembly, requestPayload('agr-r'));
    expect(
      (await dispatchCommand(assembly, { ...base('RejectAgreement', 'agr-r'), expertId: 'exp-1' }))
        .kind,
    ).toBe('executed');
    expect(repository.stored('agr-r')?.state.kind).toBe('Rejected');

    await dispatchCommand(assembly, requestPayload('agr-l'));
    expect((await dispatchCommand(assembly, base('LapseAgreementRequest', 'agr-l'))).kind).toBe(
      'executed',
    );
    expect(repository.stored('agr-l')?.state.kind).toBe('Lapsed');

    await dispatchCommand(assembly, requestPayload('agr-e'));
    await dispatchCommand(assembly, acceptPayload('agr-e'));
    await dispatchCommand(assembly, confirmPayload('agr-e'));
    expect(
      (
        await dispatchCommand(assembly, {
          ...base('RescheduleAgreement', 'agr-e'),
          requestedBy: { role: 'Client', id: 'cli-1' },
          newSlot: { startMs: SLOT.startMs + 20 * HOUR, endMs: SLOT.startMs + 21 * HOUR },
        })
      ).kind,
    ).toBe('executed');
    expect((await dispatchCommand(assembly, base('ElapseAgreement', 'agr-e'))).kind).toBe(
      'executed',
    );
    expect(repository.stored('agr-e')?.state.kind).toBe('Elapsed');

    await dispatchCommand(assembly, requestPayload('agr-c'));
    await dispatchCommand(assembly, acceptPayload('agr-c'));
    await dispatchCommand(assembly, confirmPayload('agr-c'));
    expect((await dispatchCommand(assembly, cancelPayload('agr-c'))).kind).toBe('executed');
    expect(repository.stored('agr-c')?.state.kind).toBe('Cancelled');
  });

  it('every service journals into the ONE shared command journal with the ONE clock (A-6/A-10)', async () => {
    const { providers, commandJournal } = providersOf();
    const assembly = composeAgreement(providers);
    await dispatchCommand(assembly, requestPayload());
    await dispatchCommand(assembly, acceptPayload());
    expect(commandJournal.entries).toHaveLength(20);
    for (const entry of commandJournal.entries) {
      expect(entry.correlationId).toBe(CORRELATION);
      if (entry.step !== 'Reception' && entry.step !== 'IdentityInjection') {
        expect(entry.occurredAtMs).toBe(T0.epochMillis);
      }
    }
  });

  it('the query side answers through the Query Dispatch over the shared read journal', async () => {
    const { providers, readPort, readJournal } = providersOf();
    const assembly = composeAgreement(providers);
    readPort.seed({
      agreementId: 'agr-1' as AgreementId,
      stateKind: 'Confirmed',
      slot: { startMs: SLOT.startMs, endMs: SLOT.endMs },
      version: 3,
      clientId: 'cli-1' as ClientId,
      expertId: 'exp-1' as ExpertId,
    });
    const outcome = await assembly.queryDispatch.dispatch({
      payload: { type: 'AgreementStateQuery', contractVersion: 1, agreementId: 'agr-1' },
      actor: 'cli-1' as unknown as ActorRef,
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('answered');
    expect(readJournal.entries.length).toBeGreaterThan(0);
  });

  it('the Policies are built by the Root with INJECTED product parameters (F4.1 §4)', async () => {
    const { providers } = providersOf();
    const strict = composeAgreement({
      ...providers,
      product: {
        reschedule: providers.product.reschedule,
        cancellation: { minimumNoticeMillis: 100 * HOUR },
      },
    });
    await dispatchCommand(strict, requestPayload());
    await dispatchCommand(strict, acceptPayload());
    await dispatchCommand(strict, confirmPayload());
    const outcome = await dispatchCommand(strict, cancelPayload());
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') {
      expect(outcome.refusal.reason).toBe('CancellationWindowClosed');
    }
  });

  it('the technical retry budget flows from the Root (I-5)', async () => {
    const { providers } = providersOf();
    const assembly = composeAgreement({ ...providers, technical: { commandMaxAttempts: 2 } });
    expect((await dispatchCommand(assembly, requestPayload())).kind).toBe('executed');
  });
});

describe('the Command Dispatch properties (F4.1 §6) through the assembly', () => {
  it('demands the act identity before routing (F4.1 §3)', async () => {
    const assembly = composeAgreement(providersOf().providers);
    const outcome = await dispatchCommand(assembly, {
      ...requestPayload(),
      commandId: undefined,
    });
    expect(outcome.kind).toBe('exception');
    if (outcome.kind === 'exception') {
      expect(outcome.violations[0]?.field).toBe('commandId');
    }
  });

  it('an unknown Command has no carrier — the Exception channel', async () => {
    const assembly = composeAgreement(providersOf().providers);
    const outcome = await dispatchCommand(assembly, {
      ...base('ExpireAgreement', 'agr-1'),
    });
    expect(outcome.kind).toBe('exception');
    if (outcome.kind === 'exception') {
      expect(outcome.violations[0]?.code).toBe('CONTRACT.UNKNOWN_CONTRACT');
    }
  });
});
