import { RecordingJournal, RecordingReactionJournal, RecordingReadJournal } from '@mentora/application-kernel';
import type { ActorRef, CorrelationId } from '@mentora/contracts';
import {
  InMemoryAccountRepository,
  InMemoryAvailabilityFrameRepository,
  InMemorySubscriptionRepository,
  InMemorySupportRequestRepository,
} from '@mentora/domain-account';
import { instantOf } from '@mentora/kernel';
import { FakeClock } from '@mentora/testing-clock';
import { describe, expect, it } from 'vitest';

import { DevelopmentNoSettlementAdapter } from './acl/development-no-settlement-adapter.js';
import type { SettlementAclPort } from './acl/settlement-acl.port.js';
import type { AccountAssembly, AccountCompositionProviders } from './composition/account-composition.js';
import { composeAccount } from './composition/account-composition.js';
import { InMemoryChoreographyStore } from './reactions/account-choreography.js';
import { InMemoryAccountReadPorts } from './read/testing/account-read-doubles.js';

/**
 * The Account application over the memory references: the eleven carriers
 * through the dispatch, the two ratified lectures with their grids, the
 * declared choreography with its declared handler, the Settlement ACL, and
 * the boot validation of composeAccount (fail closed). No adapter exists
 * yet (Lot A04) — this is the law every real one must replay.
 */

const T0 = instantOf(1_000_000);
const HOLDER = 'person-1' as ActorRef;
const NOTIFICATION = 'notification-sanctioned' as ActorRef;
const CHOREOGRAPHY = 'account-choreography' as ActorRef;
const CORR = 'corr-1' as CorrelationId;

interface Harness {
  assembly: AccountAssembly;
  reads: InMemoryAccountReadPorts;
  settlement: DevelopmentNoSettlementAdapter;
  store: InMemoryChoreographyStore;
  journal: RecordingJournal;
}

const harness = (overrides: Partial<AccountCompositionProviders> = {}): Harness => {
  const reads = new InMemoryAccountReadPorts(NOTIFICATION);
  const settlement = new DevelopmentNoSettlementAdapter('development');
  const store = new InMemoryChoreographyStore();
  const journal = new RecordingJournal();
  const assembly = composeAccount({
    accountRepository: new InMemoryAccountRepository(),
    availabilityFrameRepository: new InMemoryAvailabilityFrameRepository(),
    subscriptionRepository: new InMemorySubscriptionRepository(),
    supportRequestRepository: new InMemorySupportRequestRepository(),
    availabilityFrameRead: reads,
    reachabilityRead: reads,
    readRights: reads,
    choreographyStore: store,
    settlement,
    clock: FakeClock.at(T0),
    commandJournal: journal,
    readJournal: new RecordingReadJournal(),
    reactionJournal: new RecordingReactionJournal(),
    choreographyActor: CHOREOGRAPHY,
    environment: 'development',
    product: {
      reachability: { admittedChannels: ['email', 'sms'] },
      subscription: { admittedOffers: ['offer-basic'] },
    },
    ...overrides,
  });
  return { assembly, reads, settlement, store, journal };
};

const command = (assembly: AccountAssembly, payload: Record<string, unknown>, actor: ActorRef = HOLDER) =>
  assembly.commandDispatch.dispatch({ payload: { contractVersion: 1, commandId: `cmd-${String(Math.random())}`, ...payload }, actor, correlationId: CORR });

describe('the eleven carriers through the closed dispatch (catalogue 36-46)', () => {
  it('the whole road of one person: register → prefer → reach → devices → frame → subscribe → support → close', async () => {
    const { assembly, settlement } = harness();
    const steps: Record<string, unknown>[] = [
      { type: 'RegisterPerson', personId: 'person-1', verificationState: 'unverified' },
      { type: 'ChangePreference', personId: 'person-1', preference: { kind: 'language', value: 'fr' } },
      { type: 'ChangeReachability', personId: 'person-1', channel: 'email' },
      { type: 'RegisterDevice', personId: 'person-1', deviceId: 'dev-1' },
      { type: 'RemoveDevice', personId: 'person-1', deviceId: 'dev-1' },
      { type: 'ChangeAvailabilityFrame', personId: 'person-1', windows: [{ startMs: 1, endMs: 2 }] },
      { type: 'ChangeAvailabilityFrame', personId: 'person-1', windows: [{ startMs: 5, endMs: 9 }] },
      { type: 'StartSubscription', personId: 'person-1', subscriptionId: 'sub-1', offerReference: 'offer-basic' },
      { type: 'OpenSupportRequest', personId: 'person-1', supportRequestId: 'sr-1', motive: 'billing' },
      { type: 'HandleSupportRequest', personId: 'person-1', supportRequestId: 'sr-1' },
      { type: 'EndSubscription', personId: 'person-1', subscriptionId: 'sub-1', motive: 'done' },
      { type: 'CloseAccount', personId: 'person-1', motive: 'leaving' },
    ];
    for (const step of steps) {
      const outcome = await command(assembly, step);
      expect(outcome.kind, String(step['type'])).toBe('executed');
    }
    // The Subscription commissioned its order through the ACL — visible, never hidden.
    expect(settlement.commissioned).toEqual([
      { subscriptionId: 'sub-1', commissioner: 'person-1', offerReference: 'offer-basic' },
    ]);
  });

  it('refusals are VALUES: R-B at birth, absence, the policies, the machine', async () => {
    const { assembly } = harness();
    await command(assembly, { type: 'RegisterPerson', personId: 'person-1', verificationState: 'v' });
    const rebirth = await command(assembly, { type: 'RegisterPerson', personId: 'person-1', verificationState: 'v' });
    expect(rebirth.kind === 'refused' && rebirth.refusal.reason).toBe('TransitionUnavailable');
    const absent = await command(assembly, { type: 'CloseAccount', personId: 'person-ghost', motive: 'm' });
    expect(absent.kind === 'refused' && absent.refusal.reason).toBe('TransitionUnavailable');
    const channel = await command(assembly, { type: 'ChangeReachability', personId: 'person-1', channel: 'pigeon' });
    expect(channel.kind === 'refused' && channel.refusal.reason).toBe('ChannelUnavailable');
    const offer = await command(assembly, { type: 'StartSubscription', personId: 'person-1', subscriptionId: 's', offerReference: 'offer-gold' });
    expect(offer.kind === 'refused' && offer.refusal.reason).toBe('OfferUnavailable');
    const window = await command(assembly, { type: 'ChangeAvailabilityFrame', personId: 'person-1', windows: [{ startMs: 9, endMs: 1 }] });
    expect(window.kind === 'refused' && window.refusal.reason).toBe('WindowUnavailable');
    const device = await command(assembly, { type: 'RemoveDevice', personId: 'person-1', deviceId: 'ghost' });
    expect(device.kind === 'refused' && device.refusal.reason).toBe('DeviceUnavailable');
  });

  it('the R-A key at retention: a second ACTIVE subscription for the holder is SubscriptionAlreadyExists', async () => {
    const { assembly } = harness();
    await command(assembly, { type: 'RegisterPerson', personId: 'person-1', verificationState: 'v' });
    await command(assembly, { type: 'StartSubscription', personId: 'person-1', subscriptionId: 'sub-1', offerReference: 'offer-basic' });
    const second = await command(assembly, { type: 'StartSubscription', personId: 'person-1', subscriptionId: 'sub-2', offerReference: 'offer-basic' });
    expect(second.kind === 'refused' && second.refusal.reason).toBe('SubscriptionAlreadyExists');
  });

  it('a malformed wire is the caller defect (exception channel); an unknown preference kind dies at the seam as a VALIDITY failure (lesson: enumerations belong to the published language)', async () => {
    const { assembly } = harness();
    const malformed = await command(assembly, { type: 'RegisterPerson', personId: ' ' });
    expect(malformed.kind).toBe('exception');
    await command(assembly, { type: 'RegisterPerson', personId: 'person-1', verificationState: 'v' });
    const unknownKind = await command(assembly, { type: 'ChangePreference', personId: 'person-1', preference: { kind: 'theme', value: 'dark' } });
    expect(unknownKind.kind === 'abandoned' && unknownKind.failure.code).toBe('SEQUENCE.VALIDITY_FAILURE');
  });

  it('the ACL refusing to commission is reported as a Failure — never hidden', async () => {
    const refusing: SettlementAclPort = {
      adapterName: 'test-refusing-settlement',
      commission: () => Promise.resolve({ ok: false, error: { code: 'SETTLEMENT.UNAVAILABLE', message: 'down' } }),
    };
    const { assembly } = harness({ settlement: refusing, environment: 'staging' });
    await command(assembly, { type: 'RegisterPerson', personId: 'person-1', verificationState: 'v' });
    const started = await command(assembly, { type: 'StartSubscription', personId: 'person-1', subscriptionId: 'sub-1', offerReference: 'offer-basic' });
    expect(started.kind === 'abandoned' && started.failure.code).toBe('SETTLEMENT.UNAVAILABLE');
  });
});

describe('the two ratified lectures (n°4 tous ; n°10 la Notification sanctionnée + le Titulaire)', () => {
  const query = (assembly: AccountAssembly, payload: Record<string, unknown>, actor: ActorRef) =>
    assembly.queryDispatch.dispatch({ payload: { contractVersion: 1, ...payload }, actor, correlationId: CORR });

  it('AvailabilityFrameQuery: everyone reads the published frame; absence is motivated', async () => {
    const { assembly, reads } = harness();
    reads.seedFrame({ personId: 'person-1' as never, windows: [{ startMs: 1, endMs: 2 }], version: 3 });
    const stranger = await query(assembly, { type: 'AvailabilityFrameQuery', personId: 'person-1' }, 'anyone' as ActorRef);
    expect(stranger.kind === 'answered' && stranger.response).toEqual({
      contractVersion: 1,
      type: 'AvailabilityFrameResponse',
      personId: 'person-1',
      windows: [{ startMs: 1, endMs: 2 }],
      version: 3,
    });
    const absent = await query(assembly, { type: 'AvailabilityFrameQuery', personId: 'person-9' }, 'anyone' as ActorRef);
    expect(absent.kind === 'refused' && absent.refusal.reason).toBe('AccountUnavailable');
  });

  it('ReachabilityQuery: the holder and the sanctioned Notification read; a stranger is RightMissing; the response STRIPS', async () => {
    const { assembly, reads } = harness();
    reads.seedReachability({ personId: 'person-1' as never, channel: 'email', accountState: 'Active' });
    const holder = await query(assembly, { type: 'ReachabilityQuery', personId: 'person-1' }, HOLDER);
    expect(holder.kind === 'answered' && holder.response).toEqual({
      contractVersion: 1,
      type: 'ReachabilityResponse',
      personId: 'person-1',
      channel: 'email',
    });
    const notification = await query(assembly, { type: 'ReachabilityQuery', personId: 'person-1' }, NOTIFICATION);
    expect(notification.kind).toBe('answered');
    const stranger = await query(assembly, { type: 'ReachabilityQuery', personId: 'person-1' }, 'person-2' as ActorRef);
    expect(stranger.kind === 'refused' && stranger.refusal.reason).toBe('RightMissing');
    reads.seedReachability({ personId: 'person-3' as never, accountState: 'Active' });
    const unset = await query(assembly, { type: 'ReachabilityQuery', personId: 'person-3' }, 'person-3' as ActorRef);
    expect(unset.kind === 'answered' && Object.keys(unset.response as object).includes('channel')).toBe(false);
  });

  it('a reader refuses a foreign query type and a malformed wire as violations', async () => {
    const { assembly } = harness();
    const unknown = await query(assembly, { type: 'ProfileQuery', personId: 'p' }, HOLDER);
    expect(unknown.kind).toBe('exception');
    const malformed = await query(assembly, { type: 'ReachabilityQuery', personId: '' }, HOLDER);
    expect(malformed.kind).toBe('exception');
  });
});

describe('the declared choreography (RFC-003 P3/P4) and its declared handler', () => {
  const fact = (assembly: AccountAssembly, payload: Record<string, unknown>) =>
    assembly.reactionDispatch.dispatch({ payload: { contractVersion: 1, ...payload }, correlationId: CORR });

  it('P3: AccountClosed → EndSubscription of the active one — learned from SubscriptionStarted, carried by the handler', async () => {
    const { assembly, store } = harness();
    await command(assembly, { type: 'RegisterPerson', personId: 'person-1', verificationState: 'v' });
    await command(assembly, { type: 'StartSubscription', personId: 'person-1', subscriptionId: 'sub-1', offerReference: 'offer-basic' });
    const started = await fact(assembly, { type: 'SubscriptionStarted', subscriptionId: 'sub-1', sequence: 1, occurredAtMs: 1, personId: 'person-1', offerReference: 'offer-basic' });
    expect(started.kind).toBe('reacted');
    const closed = await fact(assembly, { type: 'AccountClosed', personId: 'person-1', sequence: 2, occurredAtMs: 2, motive: 'leaving' });
    expect(closed.kind === 'reacted' && closed.commands).toHaveLength(1);
    expect(await store.pendingCommands()).toHaveLength(1);
    const outcomes = await assembly.drainChoreography();
    expect(outcomes.map((outcome) => outcome.kind)).toEqual(['executed']);
    expect(await store.pendingCommands()).toHaveLength(0);
    const again = await command(assembly, { type: 'EndSubscription', personId: 'person-1', subscriptionId: 'sub-1', motive: 'x' });
    expect(again.kind === 'refused' && again.refusal.reason).toBe('TransitionUnavailable'); // already ended by the choreography
  });

  it('P4: a FAILED Settlement report ends that subscription; an executed one changes nothing; a duplicate fact is a duplicate', async () => {
    const { assembly } = harness();
    await fact(assembly, { type: 'SubscriptionStarted', subscriptionId: 'sub-1', sequence: 1, occurredAtMs: 1, personId: 'person-1', offerReference: 'o' });
    const executed = await fact(assembly, { type: 'SettlementReport', personId: 'person-1', report: { kind: 'executed', subscriptionId: 'sub-1' } });
    expect(executed.kind === 'reacted' && executed.commands).toHaveLength(0);
    const failed = await fact(assembly, { type: 'SettlementReport', personId: 'person-1', report: { kind: 'failed', subscriptionId: 'sub-1', reason: 'declined' } });
    expect(failed.kind === 'reacted' && failed.commands[0]).toMatchObject({ type: 'EndSubscription', subscriptionId: 'sub-1', motive: 'settlement-failed' });
    const duplicate = await fact(assembly, { type: 'SettlementReport', personId: 'person-1', report: { kind: 'failed', subscriptionId: 'sub-1', reason: 'declined' } });
    expect(duplicate.kind).toBe('duplicate');
  });

  it('no active subscription → AccountClosed emits nothing; an unknown fact or a non-person-keyed fact is refused at reception', async () => {
    const { assembly } = harness();
    const closed = await fact(assembly, { type: 'AccountClosed', personId: 'person-1', sequence: 1, occurredAtMs: 1, motive: 'm' });
    expect(closed.kind === 'reacted' && closed.commands).toHaveLength(0);
    const foreign = await fact(assembly, { type: 'CredentialRevoked' });
    expect(foreign.kind).toBe('exception');
    const malformedReport = await fact(assembly, { type: 'SettlementReport', report: {} });
    expect(malformedReport.kind).toBe('exception');
  });
});

describe('composeAccount — boot validation, fail closed', () => {
  it('declares exactly the catalogues: 11 carriers, 2 readers, 3 consumed inputs; names its Settlement adapter', () => {
    const { assembly } = harness();
    expect(assembly.commandDispatch.commandTypes).toHaveLength(11);
    expect([...assembly.queryDispatch.queryTypes].sort()).toEqual(['AvailabilityFrameQuery', 'ReachabilityQuery']);
    expect(assembly.reactionDispatch.factTypes).toEqual(['SubscriptionStarted', 'AccountClosed', 'SettlementReport']);
    expect(assembly.settlement).toEqual({ adapterName: 'development-no-settlement (PROVISIONAL)', provisional: true });
  });

  it('the PROVISIONAL adapter refuses to exist outside development — at its construction AND at the composition', () => {
    expect(() => new DevelopmentNoSettlementAdapter('production')).toThrow(/PROVISIONAL/);
    const provisional = new DevelopmentNoSettlementAdapter('development');
    expect(() => harness({ settlement: provisional, environment: 'staging' })).toThrow(/pas de démarrage/);
  });

  it('shares ONE clock and ONE journal across the command side; the policies carry the product params', async () => {
    const { assembly, journal } = harness();
    await command(assembly, { type: 'RegisterPerson', personId: 'person-1', verificationState: 'v' });
    expect(journal.steps().length).toBeGreaterThan(0);
    expect(assembly.policies.reachability.judge('sms' as never).ok).toBe(true);
    expect(assembly.policies.subscription.judge('offer-basic').ok).toBe(true);
    expect(assembly.machinery.clock.now().epochMillis).toBe(T0.epochMillis);
  });
});
