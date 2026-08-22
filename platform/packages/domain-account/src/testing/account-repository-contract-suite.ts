import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import type { Account } from '../aggregate/account.js';
import { registerPerson } from '../factories/account-factory.js';
import { commandIdOf, deviceIdOf, personIdOf } from '../ids/identifiers.js';
import type { AccountRepository } from '../ports/account-repository.js';
import { verificationStateOf } from '../value-objects/verification-state.js';

/**
 * AccountRepositoryContractSuite — the port's promises written ONCE (I-10):
 * the in-memory reference today, the PostgreSQL registry of Lot A04
 * tomorrow (its acceptance criterion). Lives on its own subpath
 * ('@mentora/domain-account/account-contract-suite'): it imports the test
 * runner (the barrels lesson).
 */

export interface AccountRepositoryProvider {
  make(): Promise<{ repository: AccountRepository }>;
}

export const bornAccount = (person: string): Account => {
  const result = registerPerson({
    commandId: commandIdOf('cmd-' + person),
    personId: personIdOf(person),
    verificationState: verificationStateOf('unverified'),
    registeredAt: instantOf(1_000),
  });
  if (!result.ok) throw new Error('unreachable');
  return result.value;
};

export const accountRepositoryContractSuite = (
  name: string,
  provider: AccountRepositoryProvider,
): void => {
  describe(`AccountRepository contract — ${name}`, () => {
    it('retains a newborn and reconstitutes it by Identifier (the person), facts emptied', async () => {
      const { repository } = await provider.make();
      const born = bornAccount('person-1');
      expect((await repository.retain(born)).ok).toBe(true);
      const back = await repository.byId(born.id);
      expect(back.some).toBe(true);
      if (back.some) {
        expect(back.value.state.kind).toBe('Active');
        expect(back.value.pendingFacts).toHaveLength(0);
        expect(back.value.unretainedActs).toBe(0);
        expect(back.value.version).toBe(1);
      }
    });

    it('an unknown Identifier is none — absence is a value, never an error', async () => {
      const { repository } = await provider.make();
      expect((await repository.byId(personIdOf('person-ghost'))).some).toBe(false);
    });

    it('retains a STATE-ONLY act (device) — the version advanced without a fact (the version law)', async () => {
      const { repository } = await provider.make();
      const born = bornAccount('person-1');
      await repository.retain(born);
      const loaded = await repository.byId(born.id);
      if (!loaded.some) throw new Error('unreachable');
      const registered = loaded.value.registerDevice({
        commandId: commandIdOf('cmd-dev'),
        personId: born.id,
        deviceId: deviceIdOf('dev-1'),
        registeredAt: instantOf(2_000),
      });
      if (!registered.ok) throw new Error('unreachable');
      expect(registered.value.pendingFacts).toHaveLength(0);
      expect((await repository.retain(registered.value)).ok).toBe(true);
      const back = await repository.byId(born.id);
      expect(back.some && back.value.version).toBe(2);
      expect(back.some && back.value.devices).toHaveLength(1);
    });

    it('refuses a second birth under the same person — R-B, a motivated VALUE', async () => {
      const { repository } = await provider.make();
      await repository.retain(bornAccount('person-1'));
      const again = await repository.retain(bornAccount('person-1'));
      expect(again.ok).toBe(false);
      if (!again.ok) {
        expect(again.error.reason).toBe('TransitionUnavailable');
      }
    });

    it('a stale version is a TRANSIENT FAILURE — thrown, never a Decision (S-3)', async () => {
      const { repository } = await provider.make();
      const born = bornAccount('person-1');
      await repository.retain(born);
      const loaded = await repository.byId(born.id);
      if (!loaded.some) throw new Error('unreachable');
      const first = loaded.value.close({
        commandId: commandIdOf('cmd-c1'),
        personId: born.id,
        motive: 'leaving',
        closedAt: instantOf(3_000),
      });
      const second = loaded.value.close({
        commandId: commandIdOf('cmd-c2'),
        personId: born.id,
        motive: 'leaving-too',
        closedAt: instantOf(3_000),
      });
      if (!first.ok || !second.ok) throw new Error('unreachable');
      expect((await repository.retain(first.value)).ok).toBe(true);
      await expect(repository.retain(second.value)).rejects.toThrow(/version conflict/);
    });

    it('retains the terminal — closed stays closed', async () => {
      const { repository } = await provider.make();
      const born = bornAccount('person-1');
      await repository.retain(born);
      const loaded = await repository.byId(born.id);
      if (!loaded.some) throw new Error('unreachable');
      const closed = loaded.value.close({
        commandId: commandIdOf('cmd-c'),
        personId: born.id,
        motive: 'leaving',
        closedAt: instantOf(3_000),
      });
      if (!closed.ok) throw new Error('unreachable');
      await repository.retain(closed.value);
      const back = await repository.byId(born.id);
      expect(back.some && back.value.state.kind).toBe('Closed');
    });
  });
};
