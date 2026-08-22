import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import type { SupportRequest } from '../aggregate/support-request.js';
import { openSupportRequest } from '../factories/subscription-factory.js';
import { commandIdOf, personIdOf, supportRequestIdOf } from '../ids/identifiers.js';
import type { SupportRequestRepository } from '../ports/subscription-repository.js';

/**
 * SupportRequestRepositoryContractSuite — the port's promises written ONCE
 * (I-10). THE promise this suite exists for: the registry retains STATE
 * ONLY — a support request never touches any Outbox de faits (precedent:
 * the Session suite); the Lot A04 schema must prove it by absence.
 */

export interface SupportRequestRepositoryProvider {
  make(): Promise<{ repository: SupportRequestRepository }>;
}

export const openedRequest = (id: string, requester = 'person-1'): SupportRequest => {
  const result = openSupportRequest({
    commandId: commandIdOf('cmd-' + id),
    supportRequestId: supportRequestIdOf(id),
    requesterId: personIdOf(requester),
    motive: 'billing',
    openedAt: instantOf(1_000),
  });
  if (!result.ok) throw new Error('unreachable');
  return result.value;
};

export const supportRequestRepositoryContractSuite = (
  name: string,
  provider: SupportRequestRepositoryProvider,
): void => {
  describe(`SupportRequestRepository contract — ${name}`, () => {
    it('retains an opened request and reconstitutes it by Identifier — state only, nothing to empty', async () => {
      const { repository } = await provider.make();
      const opened = openedRequest('sr-1');
      expect((await repository.retain(opened)).ok).toBe(true);
      const back = await repository.byId(opened.id);
      expect(back.some && back.value.state.kind).toBe('Opened');
      expect(back.some && back.value.unretainedActs).toBe(0);
      expect(back.some && 'pendingFacts' in back.value).toBe(false);
    });

    it('absence is a value', async () => {
      const { repository } = await provider.make();
      expect((await repository.byId(supportRequestIdOf('sr-ghost'))).some).toBe(false);
    });

    it('retains the terminal — handled stays handled', async () => {
      const { repository } = await provider.make();
      const opened = openedRequest('sr-1');
      await repository.retain(opened);
      const loaded = await repository.byId(opened.id);
      if (!loaded.some) throw new Error('unreachable');
      const handled = loaded.value.handle({
        commandId: commandIdOf('cmd-h'),
        supportRequestId: opened.id,
        handledAt: instantOf(2_000),
      });
      if (!handled.ok) throw new Error('unreachable');
      expect((await repository.retain(handled.value)).ok).toBe(true);
      const back = await repository.byId(opened.id);
      expect(back.some && back.value.state.kind).toBe('Handled');
      expect(back.some && back.value.version).toBe(2);
    });

    it('refuses a second birth under the same Identifier — R-B', async () => {
      const { repository } = await provider.make();
      await repository.retain(openedRequest('sr-1'));
      const again = await repository.retain(openedRequest('sr-1', 'person-2'));
      expect(!again.ok && again.error.reason).toBe('TransitionUnavailable');
    });

    it('a stale version is the transient FAILURE channel — thrown, never a Refusal (S-3)', async () => {
      const { repository } = await provider.make();
      const opened = openedRequest('sr-1');
      await repository.retain(opened);
      const loaded = await repository.byId(opened.id);
      if (!loaded.some) throw new Error('unreachable');
      const handle = { commandId: commandIdOf('cmd-h'), supportRequestId: opened.id, handledAt: instantOf(2_000) };
      const a = loaded.value.handle(handle);
      const b = loaded.value.handle(handle);
      if (!a.ok || !b.ok) throw new Error('unreachable');
      await repository.retain(a.value);
      await expect(repository.retain(b.value)).rejects.toThrow(/version conflict/);
    });
  });
};
