import { RecordingJournal } from '@mentora/application-kernel';
import type { ActorRef, CorrelationId } from '@mentora/contracts';
import { InMemorySessionRepository, ProofRequirementPolicy } from '@mentora/domain-identity';
import { instantOf } from '@mentora/kernel';
import { FakeClock } from '@mentora/testing-clock';
import { describe, expect, it } from 'vitest';

import {
  EndSessionApplicationService,
  OpenSessionApplicationService,
  RevokeSessionApplicationService,
} from './session-application-services.js';
import type { SessionSequenceMachinery } from './session-application-services.js';

/** Conformity to the Séquence for the three Session carriers (catalog 72-74). */

const T0 = instantOf(1_000_000_000);
const ACTOR = 'actor-1' as ActorRef;
const CORRELATION = 'corr-1' as CorrelationId;

const harness = () => {
  const repository = new InMemorySessionRepository();
  const machinery: SessionSequenceMachinery = { clock: FakeClock.at(T0), journal: new RecordingJournal() };
  const proofRequirement = new ProofRequirementPolicy({ acceptedStrengths: ['standard'] });
  return {
    repository,
    open: new OpenSessionApplicationService({ repository, proofRequirement }, machinery),
    end: new EndSessionApplicationService({ repository }, machinery),
    revoke: new RevokeSessionApplicationService({ repository }, machinery),
  };
};

const openWire = (over: Record<string, unknown> = {}): Record<string, unknown> => ({
  type: 'OpenSession',
  contractVersion: 1,
  commandId: 'cmd-o1',
  sessionId: 'sess-1',
  credentialId: 'cred-1',
  presentedStrength: 'standard',
  ...over,
});

describe('Session carriers — conformity to the Séquence', () => {
  it('opens on sufficient proof, end to end; instant injected; STATE retained without any fact', async () => {
    const { repository, open } = harness();
    const outcome = await open.execute({ payload: openWire(), actor: ACTOR, correlationId: CORRELATION });
    expect(outcome.kind).toBe('executed');
    const back = await repository.byId('sess-1' as never);
    expect(back.some && back.value.state.kind).toBe('Active');
    if (back.some) expect('pendingFacts' in back.value).toBe(false);
  });

  it('refuses an insufficient proof — ProofUnavailable, a VALUE', async () => {
    const { open } = harness();
    const outcome = await open.execute({
      payload: openWire({ presentedStrength: 'weak' }),
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('refused');
    if (outcome.kind === 'refused') expect(outcome.refusal.reason).toBe('ProofUnavailable');
  });

  it('refuses opening under an inhabited Identifier — R-B', async () => {
    const { open } = harness();
    await open.execute({ payload: openWire(), actor: ACTOR, correlationId: CORRELATION });
    const second = await open.execute({
      payload: openWire({ commandId: 'cmd-o2' }),
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(second.kind).toBe('refused');
  });

  it('ends then refuses the dead session; revoking an absent one refuses too', async () => {
    const { open, end, revoke } = harness();
    await open.execute({ payload: openWire(), actor: ACTOR, correlationId: CORRELATION });
    const ended = await end.execute({
      payload: { type: 'EndSession', contractVersion: 1, commandId: 'cmd-e1', sessionId: 'sess-1' },
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(ended.kind).toBe('executed');
    const afterEnd = await revoke.execute({
      payload: { type: 'RevokeSession', contractVersion: 1, commandId: 'cmd-r1', sessionId: 'sess-1', motive: 'x' },
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(afterEnd.kind).toBe('refused');
    const ghost = await revoke.execute({
      payload: { type: 'RevokeSession', contractVersion: 1, commandId: 'cmd-r2', sessionId: 'ghost', motive: 'x' },
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(ghost.kind).toBe('refused');
  });

  it('revokes an active session — the suffered terminal (cascade verb ready)', async () => {
    const { repository, open, revoke } = harness();
    await open.execute({ payload: openWire(), actor: ACTOR, correlationId: CORRELATION });
    const outcome = await revoke.execute({
      payload: { type: 'RevokeSession', contractVersion: 1, commandId: 'cmd-r1', sessionId: 'sess-1', motive: 'credential-revoked' },
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('executed');
    const back = await repository.byId('sess-1' as never);
    expect(back.some && back.value.state.kind).toBe('Revoked');
  });

  it('cross-carrier wire dies as the caller defect (A-1); malformed wire dies at reception', async () => {
    const { end } = harness();
    const foreign = await end.execute({ payload: openWire(), actor: ACTOR, correlationId: CORRELATION });
    expect(foreign.kind).toBe('exception');
    const malformed = await end.execute({
      payload: { type: 'EndSession', contractVersion: 1, commandId: ' ', sessionId: 'sess-1' },
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(malformed.kind).toBe('exception');
  });
});
