import { RecordingJournal, SEQUENCE_STEPS, SequenceExecutor } from '@mentora/application-kernel';
import type { ActorRef, CorrelationId } from '@mentora/contracts';
import type { Agreement, AgreementRefusal, AgreementRepository } from '@mentora/domain-agreement';
import {
  AgreementCancellationPolicy,
  ReschedulePolicy,
  agreementRefusal,
} from '@mentora/domain-agreement';
import type { Option, Result } from '@mentora/kernel';
import { err, instantOf, none, ok, some } from '@mentora/kernel';
import { FakeClock } from '@mentora/testing-clock';
import { afterEach, describe, expect, it, vi } from 'vitest';

import { AcceptAgreementApplicationService } from './accept-agreement.application-service.js';
import { AgreementSequenceApplicationService } from './agreement-sequence.application-service.js';
import type { AgreementSequenceMachinery } from './agreement-sequence.application-service.js';
import { CancelAgreementApplicationService } from './cancel-agreement.application-service.js';
import { ConfirmAgreementApplicationService } from './confirm-agreement.application-service.js';
import { ElapseAgreementApplicationService } from './elapse-agreement.application-service.js';
import { LapseAgreementRequestApplicationService } from './lapse-agreement-request.application-service.js';
import { RejectAgreementApplicationService } from './reject-agreement.application-service.js';
import { RequestAgreementApplicationService } from './request-agreement.application-service.js';
import { RescheduleAgreementApplicationService } from './reschedule-agreement.application-service.js';

/**
 * Conformity to the Séquence (F4.1 §10: "le test du service est un test de
 * conformité à la Séquence"). The eight carriers are driven END TO END with
 * WIRE payloads through the Golden Pipeline: reception by the published
 * language, injections, loading, the seam, the unit's Decision, atomic
 * retention — proving the pipeline of 1C-2 is REUSED, never reimplemented.
 */

const HOUR = 3_600_000;
const T0 = instantOf(1_000_000_000);
const SLOT = { startMs: T0.epochMillis + 10 * HOUR, endMs: T0.epochMillis + 11 * HOUR };
const FRAME = [{ startMs: T0.epochMillis, endMs: T0.epochMillis + 100 * HOUR }];
const ACTOR = 'actor-1' as ActorRef;
const CORRELATION = 'corr-1' as CorrelationId;

/** The registry double: byId + atomic retention, configurable channels. */
class InMemoryAgreementRepository implements AgreementRepository {
  private readonly store = new Map<string, Agreement>();
  failRetainTimes = 0;
  structuralRefusal = false;

  byId(id: Agreement['id']): Promise<Option<Agreement>> {
    const found = this.store.get(id);
    return Promise.resolve(found === undefined ? none : some(found));
  }

  byExpertAndWindow(): Promise<readonly Agreement[]> {
    return Promise.resolve([]);
  }

  retain(agreement: Agreement): Promise<Result<void, AgreementRefusal>> {
    if (this.failRetainTimes > 0) {
      this.failRetainTimes -= 1;
      return Promise.reject(new Error('optimistic conflict (S-3: a Failure, never a Decision)'));
    }
    if (this.structuralRefusal) {
      return Promise.resolve(
        err(agreementRefusal('TimeSlotUnavailable', 'the declared R-A key refuses structurally')),
      );
    }
    this.store.set(agreement.id, agreement.retained());
    return Promise.resolve(ok(undefined));
  }

  stored(id: string): Agreement {
    const found = this.store.get(id);
    if (found === undefined) {
      throw new Error(`nothing retained under ${id}`);
    }
    return found;
  }
}

// ------------------------------------------------------------ wire payloads

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
const rejectPayload = (id = 'agr-1') => ({ ...base('RejectAgreement', id), expertId: 'exp-1' });
const confirmPayload = (id = 'agr-1') => ({
  ...base('ConfirmAgreement', id),
  settlementReference: 'settlement-1',
});
const reschedulePayload = (id = 'agr-1', startMs = SLOT.startMs + 20 * HOUR) => ({
  ...base('RescheduleAgreement', id),
  requestedBy: { role: 'Client', id: 'cli-1' },
  newSlot: { startMs, endMs: startMs + HOUR },
});
const cancelPayload = (id = 'agr-1') => ({
  ...base('CancelAgreement', id),
  cancelledBy: { role: 'Expert', id: 'exp-1' },
  motive: 'schedule conflict',
});
const lapsePayload = (id = 'agr-1') => base('LapseAgreementRequest', id);
const elapsePayload = (id = 'agr-1') => base('ElapseAgreement', id);

// ------------------------------------------------------------------ harness

interface HarnessOptions {
  readonly maxAttempts?: number;
  readonly reschedule?: ConstructorParameters<typeof ReschedulePolicy>[0];
  readonly cancellation?: ConstructorParameters<typeof AgreementCancellationPolicy>[0];
}

const harness = (options: HarnessOptions = {}) => {
  const repository = new InMemoryAgreementRepository();
  const journal = new RecordingJournal();
  const machinery: AgreementSequenceMachinery = {
    clock: FakeClock.at(T0),
    journal,
    ...(options.maxAttempts !== undefined ? { maxAttempts: options.maxAttempts } : {}),
  };
  const reschedulePolicy = new ReschedulePolicy(
    options.reschedule ?? { minimumNoticeMillis: HOUR, maximumReschedules: 3 },
  );
  const cancellationPolicy = new AgreementCancellationPolicy(
    options.cancellation ?? { minimumNoticeMillis: HOUR },
  );
  const services = {
    request: new RequestAgreementApplicationService({ repository }, machinery),
    accept: new AcceptAgreementApplicationService({ repository }, machinery),
    reject: new RejectAgreementApplicationService({ repository }, machinery),
    confirm: new ConfirmAgreementApplicationService({ repository }, machinery),
    reschedule: new RescheduleAgreementApplicationService(
      { repository, reschedulePolicy },
      machinery,
    ),
    cancel: new CancelAgreementApplicationService({ repository, cancellationPolicy }, machinery),
    lapse: new LapseAgreementRequestApplicationService({ repository }, machinery),
    elapse: new ElapseAgreementApplicationService({ repository }, machinery),
  } as const;
  const run = (service: keyof typeof services, payload: unknown) =>
    services[service].execute({ payload, actor: ACTOR, correlationId: CORRELATION });
  return { repository, journal, services, run };
};

// --------------------------------------------------------------------- tests

describe('A-1 — one Command, one carrier (the SequenceDefinition binding)', () => {
  const foreign = [
    ['request', acceptPayload()],
    ['accept', elapsePayload()],
    ['reject', requestPayload()],
    ['confirm', rejectPayload()],
    ['reschedule', confirmPayload()],
    ['cancel', reschedulePayload()],
    ['lapse', cancelPayload()],
    ['elapse', lapsePayload()],
  ] as const;

  it.each(foreign)('%s refuses a well-formed command of ANOTHER use case', async (service, payload) => {
    const h = harness();
    const outcome = await h.run(service, payload);
    expect(outcome.kind).toBe('exception');
    if (outcome.kind === 'exception') {
      expect(outcome.violations[0]?.code).toBe('CONTRACT.UNKNOWN_CONTRACT');
    }
  });
});

describe('the golden journey — the pipeline reused eight times, never rebuilt', () => {
  it('request → accept → confirm → reschedule → elapse, each executed on attempt 1', async () => {
    const h = harness();
    const request = await h.run('request', requestPayload());
    expect(request.kind).toBe('executed');
    expect(h.repository.stored('agr-1').state.kind).toBe('Requested');

    const accept = await h.run('accept', acceptPayload());
    expect(accept.kind).toBe('executed');
    expect(h.repository.stored('agr-1').state.kind).toBe('Accepted');

    const confirm = await h.run('confirm', confirmPayload());
    expect(confirm.kind).toBe('executed');
    expect(h.repository.stored('agr-1').state.kind).toBe('Confirmed');

    const reschedule = await h.run('reschedule', reschedulePayload());
    expect(reschedule.kind).toBe('executed');
    expect(h.repository.stored('agr-1').reschedules).toHaveLength(1);

    const elapse = await h.run('elapse', elapsePayload());
    expect(elapse.kind).toBe('executed');
    expect(h.repository.stored('agr-1').state.kind).toBe('Elapsed');
    expect(h.repository.stored('agr-1').isTerminal).toBe(true);

    for (const outcome of [request, accept, confirm, reschedule, elapse]) {
      expect(outcome.kind === 'executed' && outcome.attempts).toBe(1);
    }
  });

  it('every execution journals the TEN frozen steps in the exact order (A-2, A-10)', async () => {
    const h = harness();
    await h.run('request', requestPayload());
    expect(h.journal.steps()).toEqual([...SEQUENCE_STEPS]);
  });

  it('reject and lapse end the Demande; the terminal refuses every later act (R-B)', async () => {
    const rejected = harness();
    await rejected.run('request', requestPayload());
    expect((await rejected.run('reject', rejectPayload())).kind).toBe('executed');
    expect(rejected.repository.stored('agr-1').state.kind).toBe('Rejected');

    const lapsed = harness();
    await lapsed.run('request', requestPayload());
    expect((await lapsed.run('lapse', lapsePayload())).kind).toBe('executed');
    expect(lapsed.repository.stored('agr-1').state.kind).toBe('Lapsed');
    const afterTerminal = await lapsed.run('accept', acceptPayload());
    expect(afterTerminal.kind).toBe('refused');
    if (afterTerminal.kind === 'refused') {
      expect(afterTerminal.refusal.reason).toBe('TransitionUnavailable');
    }
  });

  it('cancel ends a confirmed agreement under the published Policy', async () => {
    const h = harness();
    await h.run('request', requestPayload());
    await h.run('accept', acceptPayload());
    await h.run('confirm', confirmPayload());
    expect((await h.run('cancel', cancelPayload())).kind).toBe('executed');
    expect(h.repository.stored('agr-1').state.kind).toBe('Cancelled');
  });
});

describe('refusals — Decision VALUES transported untouched (A-7, pas 7)', () => {
  it('a command aimed at an uninhabited Identifier is refused, never thrown', async () => {
    const services = ['accept', 'reject', 'confirm', 'reschedule', 'cancel', 'lapse', 'elapse'] as const;
    const payloads = [
      acceptPayload('ghost'),
      rejectPayload('ghost'),
      confirmPayload('ghost'),
      reschedulePayload('ghost'),
      cancelPayload('ghost'),
      lapsePayload('ghost'),
      elapsePayload('ghost'),
    ];
    for (const [index, service] of services.entries()) {
      const h = harness();
      const outcome = await h.run(service, payloads[index]);
      expect(outcome.kind).toBe('refused');
      if (outcome.kind === 'refused') {
        expect(outcome.refusal.reason).toBe('TransitionUnavailable');
      }
    }
  });

  it('a second birth under the same Identifier is refused (R-B)', async () => {
    const h = harness();
    await h.run('request', requestPayload());
    const again = await h.run('request', requestPayload());
    expect(again.kind).toBe('refused');
    if (again.kind === 'refused') {
      expect(again.refusal.reason).toBe('TransitionUnavailable');
    }
  });

  it('a slot outside the published frame refuses at the FACTORY door — nothing retained', async () => {
    const h = harness();
    const outcome = await h.run('request', {
      ...requestPayload(),
      availabilityWindows: [{ startMs: 0, endMs: 1 }],
    });
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') {
      expect(outcome.refusal.reason).toBe('OutsideAvailabilityFrame');
    }
    expect(h.journal.steps()).not.toContain('AtomicRetention');
  });

  it('confirm out of order is the machine speaking, not the service', async () => {
    const h = harness();
    await h.run('request', requestPayload());
    const outcome = await h.run('confirm', confirmPayload());
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') {
      expect(outcome.refusal.reason).toBe('TransitionUnavailable');
    }
  });

  it('the published cancellation window refuses a late cancel (product parameters)', async () => {
    const h = harness({ cancellation: { minimumNoticeMillis: 100 * HOUR } });
    await h.run('request', requestPayload());
    await h.run('accept', acceptPayload());
    await h.run('confirm', confirmPayload());
    const outcome = await h.run('cancel', cancelPayload());
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') {
      expect(outcome.refusal.reason).toBe('CancellationWindowClosed');
    }
    expect(h.repository.stored('agr-1').state.kind).toBe('Confirmed');
  });

  it('the published reschedule limit refuses the extra change', async () => {
    const h = harness({ reschedule: { minimumNoticeMillis: HOUR, maximumReschedules: 1 } });
    await h.run('request', requestPayload());
    await h.run('accept', acceptPayload());
    await h.run('confirm', confirmPayload());
    expect((await h.run('reschedule', reschedulePayload())).kind).toBe('executed');
    const second = await h.run('reschedule', reschedulePayload('agr-1', SLOT.startMs + 40 * HOUR));
    expect(second.kind).toBe('refused');
    if (second.kind === 'refused') {
      expect(second.refusal.reason).toBe('RescheduleLimitReached');
    }
  });

  it('the declared R-A key refuses STRUCTURALLY at retention (TimeSlotUnavailable)', async () => {
    const h = harness();
    h.repository.structuralRefusal = true;
    const outcome = await h.run('request', requestPayload());
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') {
      expect(outcome.refusal.reason).toBe('TimeSlotUnavailable');
    }
  });
});

describe('exceptions, retries, abandons — the other two channels (A-7)', () => {
  it('a malformed payload ends at Reception: the Exception channel', async () => {
    const h = harness();
    const outcome = await h.run('request', { nonsense: true });
    expect(outcome.kind).toBe('exception');
    if (outcome.kind === 'exception') {
      expect(outcome.violations.length).toBeGreaterThan(0);
    }
    expect(h.journal.outcomes()).toEqual([['Reception', 'exception']]);
  });

  it('a technical retention Failure retries from Loading and succeeds (S-3)', async () => {
    const h = harness({ maxAttempts: 3 });
    h.repository.failRetainTimes = 1;
    const outcome = await h.run('request', requestPayload());
    expect(outcome.kind).toBe('executed');
    if (outcome.kind === 'executed') {
      expect(outcome.attempts).toBe(2);
    }
    expect(h.repository.stored('agr-1').state.kind).toBe('Requested');
  });

  it('an exhausted retry budget ABANDONS with a journaled witness — never silent', async () => {
    const h = harness({ maxAttempts: 2 });
    h.repository.failRetainTimes = 99;
    const outcome = await h.run('request', requestPayload());
    expect(outcome.kind).toBe('abandoned');
    if (outcome.kind === 'abandoned') {
      expect(outcome.attempts).toBe(2);
      expect(outcome.failure.retryable).toBe(true);
    }
    expect(h.journal.entries.at(-1)?.outcome).toBe('abandoned');
  });
});

describe('the service is BORING (F4.1 §7) — delegation only, zero talent', () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('one call to the service is exactly ONE call to the SequenceExecutor', async () => {
    const spy = vi.spyOn(SequenceExecutor.prototype, 'execute');
    const h = harness();
    await h.run('request', requestPayload());
    expect(spy).toHaveBeenCalledTimes(1);
  });

  it('the concrete services declare NOTHING beyond their constructor', () => {
    const concrete = [
      RequestAgreementApplicationService,
      AcceptAgreementApplicationService,
      RejectAgreementApplicationService,
      ConfirmAgreementApplicationService,
      RescheduleAgreementApplicationService,
      CancelAgreementApplicationService,
      LapseAgreementRequestApplicationService,
      ElapseAgreementApplicationService,
    ];
    for (const service of concrete) {
      expect(Object.getOwnPropertyNames(service.prototype)).toEqual(['constructor']);
    }
    expect(Object.getOwnPropertyNames(AgreementSequenceApplicationService.prototype)).toEqual([
      'constructor',
      'execute',
    ]);
  });
});
