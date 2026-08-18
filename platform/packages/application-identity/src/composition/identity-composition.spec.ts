import { RecordingJournal } from '@mentora/application-kernel';
import type { ActorRef, CorrelationId } from '@mentora/contracts';
import type { SessionId } from '@mentora/domain-identity';
import {
  InMemoryCredentialRepository,
  InMemorySessionRepository,
  sessionIdOf,
} from '@mentora/domain-identity';
import { instantOf } from '@mentora/kernel';
import { FakeClock } from '@mentora/testing-clock';
import { describe, expect, it } from 'vitest';

import { InMemorySessionStateRead, InMemoryCredentialStateRead } from '../read/testing/identity-read-doubles.js';

import type { IdentityCompositionProviders } from './identity-composition.js';
import { composeIdentityAccess } from './identity-composition.js';

/**
 * The Root's conformity (Stories #56/#60): ONE composition point builds the
 * WHOLE graph explicitly (Pure DI — F4.4 §2/I-2), the closed command table
 * covers exactly the ratified catalogue 70-74 (boot validation, fail closed
 * — F4.4 §7), the query AND reaction tables are CLOSED AND EMPTY by
 * constitutional state, the Policy is built HERE with injected product
 * parameters (F4.1 §4), and every pipeline shares the SAME injected
 * instances (clock, journal, repositories).
 */

const T0 = instantOf(1_000_000_000);
const ACTOR = 'actor-1' as ActorRef;
const CORRELATION = 'corr-root-1' as CorrelationId;

const establishPayload = (id = 'cred-1', person = 'person-1') => ({
  type: 'EstablishCredential',
  contractVersion: 1,
  commandId: `cmd-est-${id}`,
  credentialId: id,
  personId: person,
  principalFactor: { factorId: `factor-${id}`, kind: 'password', strength: 'standard' },
});
const revokeCredentialPayload = (id = 'cred-1') => ({
  type: 'RevokeCredential',
  contractVersion: 1,
  commandId: `cmd-revc-${id}`,
  credentialId: id,
  motive: 'rotation',
});
const openPayload = (id = 'sess-1', credential = 'cred-1', strength = 'standard') => ({
  type: 'OpenSession',
  contractVersion: 1,
  commandId: `cmd-open-${id}`,
  sessionId: id,
  credentialId: credential,
  presentedStrength: strength,
});
const endPayload = (id = 'sess-1') => ({
  type: 'EndSession',
  contractVersion: 1,
  commandId: `cmd-end-${id}`,
  sessionId: id,
});
const revokeSessionPayload = (id = 'sess-1') => ({
  type: 'RevokeSession',
  contractVersion: 1,
  commandId: `cmd-revs-${id}`,
  sessionId: id,
  motive: 'credential-revoked',
});

const providersOf = (overrides: Partial<IdentityCompositionProviders> = {}) => {
  const credentialRepository = new InMemoryCredentialRepository();
  const sessionRepository = new InMemorySessionRepository();
  const credentialStateRead = new InMemoryCredentialStateRead();
  const sessionStateRead = new InMemorySessionStateRead();
  const commandJournal = new RecordingJournal();
  const providers: IdentityCompositionProviders = {
    credentialRepository,
    sessionRepository,
    credentialStateRead,
    sessionStateRead,
    clock: FakeClock.at(T0),
    commandJournal,
    product: { proofRequirement: { acceptedStrengths: ['standard', 'elevated'] } },
    ...overrides,
  };
  return { providers, credentialRepository, sessionRepository, sessionStateRead, commandJournal };
};

const dispatchThrough = (
  assembly: ReturnType<typeof composeIdentityAccess>,
  payload: unknown,
) => assembly.commandDispatch.dispatch({ payload, actor: ACTOR, correlationId: CORRELATION });

describe('the ONE composition point (F4.4 §2 — Pure DI, readable graph)', () => {
  it('assembles the complete graph: five services, three dispatches, one policy, the gate read ports', () => {
    const { providers } = providersOf();
    const assembly = composeIdentityAccess(providers);
    expect(Object.keys(assembly.services).sort()).toEqual([
      'endSession',
      'establishCredential',
      'openSession',
      'revokeCredential',
      'revokeSession',
    ]);
    expect(assembly.policies.proofRequirement).toBeDefined();
    expect(assembly.readPorts.sessionState).toBe(providers.sessionStateRead);
    expect(assembly.readPorts.credentialState).toBe(providers.credentialStateRead);
    expect(assembly.machinery.clock).toBe(providers.clock);
  });

  it('the command table carries EXACTLY the ratified catalogue 70-74 (boot validation, F4.4 §7)', () => {
    const assembly = composeIdentityAccess(providersOf().providers);
    expect([...assembly.commandDispatch.commandTypes].sort()).toEqual([
      'EndSession',
      'EstablishCredential',
      'OpenSession',
      'RevokeCredential',
      'RevokeSession',
    ]);
  });

  it('the query table is CLOSED AND EMPTY — no I&A lecture exists among the 11 ratified (F3.3 §5)', () => {
    const assembly = composeIdentityAccess(providersOf().providers);
    expect(assembly.queryDispatch.queryTypes).toEqual([]);
  });

  it('the reaction table is CLOSED AND EMPTY — the cascade is a FUTURE Réaction, not code', () => {
    const assembly = composeIdentityAccess(providersOf().providers);
    expect(assembly.reactionDispatch.factTypes).toEqual([]);
  });
});

describe('the assembled graph runs — same injected instances everywhere', () => {
  it('a full journey flows through the Command Dispatch over the shared repositories', async () => {
    const { providers, sessionRepository } = providersOf();
    const assembly = composeIdentityAccess(providers);

    expect((await dispatchThrough(assembly, establishPayload())).kind).toBe('executed');
    expect((await dispatchThrough(assembly, openPayload('sess-1'))).kind).toBe('executed');
    expect((await dispatchThrough(assembly, openPayload('sess-2'))).kind).toBe('executed');
    expect((await dispatchThrough(assembly, endPayload('sess-1'))).kind).toBe('executed');
    expect((await dispatchThrough(assembly, revokeSessionPayload('sess-2'))).kind).toBe('executed');
    expect((await dispatchThrough(assembly, revokeCredentialPayload())).kind).toBe('executed');

    const ended = await sessionRepository.byId(sessionIdOf('sess-1'));
    expect(ended.some && ended.value.state.kind).toBe('Ended');
    const revoked = await sessionRepository.byId(sessionIdOf('sess-2'));
    expect(revoked.some && revoked.value.state.kind).toBe('Revoked');
  });

  it('the R-A key refuses through the WHOLE assembly with the settled reason', async () => {
    const assembly = composeIdentityAccess(providersOf().providers);
    await dispatchThrough(assembly, establishPayload('cred-1', 'person-1'));
    const outcome = await dispatchThrough(assembly, establishPayload('cred-2', 'person-1'));
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') {
      expect((outcome.refusal as { reason: string }).reason).toBe('CredentialAlreadyExists');
    }
  });

  it('the Policy judges with the INJECTED product parameters (F4.1 §4)', async () => {
    const assembly = composeIdentityAccess(providersOf().providers);
    await dispatchThrough(assembly, establishPayload());
    const weak = await dispatchThrough(assembly, openPayload('sess-w', 'cred-1', 'whisper'));
    expect(weak.kind).toBe('refused');
    if (weak.kind === 'refused') {
      expect((weak.refusal as { reason: string }).reason).toBe('ProofUnavailable');
    }
  });

  it('every service journals into the ONE shared command journal with the ONE clock (A-6/A-10)', async () => {
    const { providers, commandJournal } = providersOf();
    const assembly = composeIdentityAccess(providers);
    await dispatchThrough(assembly, establishPayload());
    await dispatchThrough(assembly, openPayload());
    const entries = commandJournal.entries;
    expect(entries.length).toBeGreaterThanOrEqual(2);
    expect(new Set(entries.map((entry) => entry.correlationId))).toEqual(new Set([CORRELATION]));
  });

  it('an unknown Command has no carrier — the Exception channel (closed table)', async () => {
    const assembly = composeIdentityAccess(providersOf().providers);
    const outcome = await dispatchThrough(assembly, {
      type: 'HijackSession',
      contractVersion: 1,
      commandId: 'cmd-x',
    });
    expect(outcome.kind).toBe('exception');
  });

  it('the gate reads session state through the pass-through port — a capability, never a Query', async () => {
    const { providers, sessionStateRead } = providersOf();
    const assembly = composeIdentityAccess(providers);
    sessionStateRead.seed({
      sessionId: 'sess-1' as SessionId,
      credentialId: 'cred-1' as never,
      stateKind: 'Active',
      version: 1,
    });
    const view = await assembly.readPorts.sessionState.stateOf(sessionIdOf('sess-1'));
    expect(view.some && view.value.stateKind).toBe('Active');
    const ghost = await assembly.readPorts.sessionState.stateOf(sessionIdOf('sess-ghost'));
    expect(ghost.some).toBe(false);
  });
});
