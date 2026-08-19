import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { Session } from './aggregate/session.js';
import { SessionSnapshotCorruptException } from './errors/identity-exceptions.js';
import { openSession } from './factories/session-factory.js';
import { commandIdOf, credentialIdOf, sessionIdOf } from './ids/identifiers.js';
import { ProofRequirementPolicy } from './policies/proof-requirement.policy.js';
import type { SessionSnapshot } from './snapshots/session-snapshot.js';
import { proofStrengthOf } from './value-objects/proof-strength.js';
import { isTerminalSessionState } from './value-objects/session-state.js';

const T0 = instantOf(1_000);
const T1 = instantOf(2_000);
const policy = new ProofRequirementPolicy({ acceptedStrengths: ['standard', 'elevated'] });

const opened = () => {
  const born = openSession(
    {
      commandId: commandIdOf('cmd-1'),
      sessionId: sessionIdOf('sess-1'),
      credentialId: credentialIdOf('cred-1'),
      presentedStrength: proofStrengthOf('standard'),
      openedAt: T0,
    },
    policy,
  );
  if (!born.ok) throw new Error('unreachable');
  return born.value;
};

describe('Session — opened on proof, two distinct terminals, never a fact', () => {
  it('opens on a sufficient proof: Active, provenance carried, version 1', () => {
    const session = opened();
    expect(session.state.kind).toBe('Active');
    expect(session.credentialId).toBe('cred-1');
    expect(session.version).toBe(1);
  });

  it('refuses an insufficient proof — ProofUnavailable (the ratified family), nothing is born', () => {
    const refused = openSession(
      {
        commandId: commandIdOf('cmd-2'),
        sessionId: sessionIdOf('sess-2'),
        credentialId: credentialIdOf('cred-1'),
        presentedStrength: proofStrengthOf('weak'),
        openedAt: T0,
      },
      policy,
    );
    expect(refused.ok).toBe(false);
    if (!refused.ok) expect(refused.error.reason).toBe('ProofUnavailable');
  });

  it('ends — the person\'s own act, terminal, without touching the proof', () => {
    const ended = opened().end({ commandId: commandIdOf('cmd-3'), sessionId: sessionIdOf('sess-1'), endedAt: T1 });
    expect(ended.ok).toBe(true);
    if (ended.ok) {
      expect(ended.value.state.kind).toBe('Ended');
      expect(isTerminalSessionState(ended.value.state)).toBe(true);
      expect(ended.value.version).toBe(2);
    }
  });

  it('revokes — the suffered terminal, motive carried', () => {
    const revoked = opened().revoke({
      commandId: commandIdOf('cmd-4'),
      sessionId: sessionIdOf('sess-1'),
      motive: 'credential-revoked',
      revokedAt: T1,
    });
    expect(revoked.ok).toBe(true);
    if (revoked.ok && revoked.value.state.kind === 'Revoked') {
      expect(revoked.value.state.motive).toBe('credential-revoked');
    }
  });

  it('both terminals refuse further verbs — R-B, motivated Decisions', () => {
    const ended = opened().end({ commandId: commandIdOf('c'), sessionId: sessionIdOf('sess-1'), endedAt: T1 });
    if (!ended.ok) throw new Error('unreachable');
    const again = ended.value.revoke({ commandId: commandIdOf('c2'), sessionId: sessionIdOf('sess-1'), motive: 'x', revokedAt: T1 });
    expect(again.ok).toBe(false);
    if (!again.ok) expect(again.error.reason).toBe('TransitionUnavailable');
    const endTwice = ended.value.end({ commandId: commandIdOf('c3'), sessionId: sessionIdOf('sess-1'), endedAt: T1 });
    expect(endTwice.ok).toBe(false);
  });

  it('NEVER A FACT, STRUCTURALLY: the unit has no pendingFacts field at all', () => {
    const session = opened();
    expect(Object.keys(session).sort()).toEqual(['credentialId', 'id', 'state', 'version']);
    expect('pendingFacts' in session).toBe(false);
  });

  it('snapshot round-trips all three states; corruption throws', () => {
    const active = opened();
    expect(Session.fromSnapshot(active.snapshot()).snapshot()).toEqual(active.snapshot());
    const ended = active.end({ commandId: commandIdOf('c'), sessionId: sessionIdOf('sess-1'), endedAt: T1 });
    if (!ended.ok) throw new Error('unreachable');
    expect(Session.fromSnapshot(ended.value.snapshot()).state.kind).toBe('Ended');
    const revoked = active.revoke({ commandId: commandIdOf('c'), sessionId: sessionIdOf('sess-1'), motive: 'm', revokedAt: T1 });
    if (!revoked.ok) throw new Error('unreachable');
    expect(Session.fromSnapshot(revoked.value.snapshot()).state.kind).toBe('Revoked');
    const corrupt: SessionSnapshot = { ...active.snapshot(), version: 0 };
    expect(() => Session.fromSnapshot(corrupt)).toThrow(SessionSnapshotCorruptException);
  });
});

describe('ProofRequirementPolicy.compose — MFA (Story #111/#113): the declared product table, nothing else', () => {
  const composing = new ProofRequirementPolicy({
    acceptedStrengths: ['elevated'],
    compositions: [{ of: ['standard', 'standard'], yields: 'elevated' }],
  });

  it('one verified factor presents its own strength — composition is identity', () => {
    const composed = composing.compose([proofStrengthOf('standard')]);
    expect(composed.ok && composed.value).toBe('standard');
  });

  it('a DECLARED combination composes, order-insensitively', () => {
    const composed = composing.compose([proofStrengthOf('standard'), proofStrengthOf('standard')]);
    expect(composed.ok && composed.value).toBe('elevated');
  });

  it('an UNDECLARED combination refuses — fail closed, no guessed ordering', () => {
    const composed = composing.compose([proofStrengthOf('standard'), proofStrengthOf('elevated')]);
    expect(!composed.ok && composed.error.reason).toBe('ProofUnavailable');
  });

  it('nothing verified composes into nothing', () => {
    const composed = composing.compose([]);
    expect(!composed.ok && composed.error.reason).toBe('ProofUnavailable');
  });
});
