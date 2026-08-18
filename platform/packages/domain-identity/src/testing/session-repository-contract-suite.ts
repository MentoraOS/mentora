import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import type { Session } from '../aggregate/session.js';
import { openSession } from '../factories/session-factory.js';
import { commandIdOf, credentialIdOf, sessionIdOf } from '../ids/identifiers.js';
import { ProofRequirementPolicy } from '../policies/proof-requirement.policy.js';
import type { SessionRepository } from '../ports/session-repository.js';
import { proofStrengthOf } from '../value-objects/proof-strength.js';

/**
 * SessionRepositoryContractSuite — the port's promises written ONCE (I-10),
 * on its own subpath (the barrels lesson). THE promise this suite exists
 * for: the registry retains STATE ONLY — a session never touches any
 * Outbox de faits; the PostgreSQL implementation must prove the same.
 */

export interface SessionRepositoryProvider {
  make(): Promise<{ repository: SessionRepository }>;
}

const policy = new ProofRequirementPolicy({ acceptedStrengths: ['standard'] });

export const openedSession = (id: string, credential: string): Session => {
  const born = openSession(
    {
      commandId: commandIdOf('cmd-' + id),
      sessionId: sessionIdOf(id),
      credentialId: credentialIdOf(credential),
      presentedStrength: proofStrengthOf('standard'),
      openedAt: instantOf(1_000),
    },
    policy,
  );
  if (!born.ok) throw new Error('unreachable');
  return born.value;
};

export const sessionRepositoryContractSuite = (
  name: string,
  provider: SessionRepositoryProvider,
): void => {
  describe(`SessionRepository contract — ${name}`, () => {
    it('retains an opened session and reconstitutes it by Identifier', async () => {
      const { repository } = await provider.make();
      const session = openedSession('sess-1', 'cred-1');
      expect((await repository.retain(session)).ok).toBe(true);
      const back = await repository.byId(session.id);
      expect(back.some && back.value.state.kind).toBe('Active');
    });

    it('absence is a value', async () => {
      const { repository } = await provider.make();
      expect((await repository.byId(sessionIdOf('sess-ghost'))).some).toBe(false);
    });

    it('activeByCredential is the cascade probe: actives only, per credential', async () => {
      const { repository } = await provider.make();
      await repository.retain(openedSession('sess-1', 'cred-1'));
      await repository.retain(openedSession('sess-2', 'cred-1'));
      await repository.retain(openedSession('sess-3', 'cred-2'));
      const ended = openedSession('sess-1', 'cred-1').end({
        commandId: commandIdOf('cmd-e'),
        sessionId: sessionIdOf('sess-1'),
        endedAt: instantOf(2_000),
      });
      if (!ended.ok) throw new Error('unreachable');
      await repository.retain(ended.value);
      const actives = await repository.activeByCredential(credentialIdOf('cred-1'));
      expect(actives.map((session) => session.id)).toEqual([sessionIdOf('sess-2')]);
    });

    it('retains both terminals faithfully', async () => {
      const { repository } = await provider.make();
      const session = openedSession('sess-1', 'cred-1');
      await repository.retain(session);
      const revoked = session.revoke({
        commandId: commandIdOf('cmd-r'),
        sessionId: session.id,
        motive: 'credential-revoked',
        revokedAt: instantOf(2_000),
      });
      if (!revoked.ok) throw new Error('unreachable');
      expect((await repository.retain(revoked.value)).ok).toBe(true);
      const back = await repository.byId(session.id);
      expect(back.some && back.value.state.kind).toBe('Revoked');
    });

    it('a stale retention is the transient FAILURE channel — thrown, never a Refusal', async () => {
      const { repository } = await provider.make();
      const session = openedSession('sess-1', 'cred-1');
      await repository.retain(session);
      await expect(repository.retain(session)).rejects.toThrow();
    });

    it('accepts an OPTIONAL RetentionContext (RFC-001) — and still has NOTHING to carry it to', async () => {
      const { repository } = await provider.make();
      const retained = await repository.retain(openedSession('sess-ctx', 'cred-ctx'), {
        correlationId: 'corr-1',
      });
      expect(retained.ok).toBe(true);
      const back = await repository.byId(sessionIdOf('sess-ctx'));
      expect(back.some && back.value.state.kind).toBe('Active');
    });
  });
};
