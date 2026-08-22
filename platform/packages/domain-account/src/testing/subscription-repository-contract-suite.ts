import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import type { Subscription } from '../aggregate/subscription.js';
import { startSubscription } from '../factories/subscription-factory.js';
import { commandIdOf, personIdOf, subscriptionIdOf } from '../ids/identifiers.js';
import { SubscriptionPolicy } from '../policies/subscription.policy.js';
import type { SubscriptionRepository } from '../ports/subscription-repository.js';

/**
 * SubscriptionRepositoryContractSuite — the port's promises written ONCE
 * (I-10), on its own subpath. THE promise this suite exists for: the R-A
 * key "une souscription active à la fois" applied at retention AND
 * released when the subscription ends (precedent: the Credential suite).
 */

export interface SubscriptionRepositoryProvider {
  make(): Promise<{ repository: SubscriptionRepository }>;
}

const policy = new SubscriptionPolicy({ admittedOffers: ['offer-basic', 'offer-plus'] });

export const startedSubscription = (id: string, holder: string, offer = 'offer-basic'): Subscription => {
  const result = startSubscription(
    {
      commandId: commandIdOf('cmd-' + id),
      subscriptionId: subscriptionIdOf(id),
      personId: personIdOf(holder),
      offerReference: offer,
      startedAt: instantOf(1_000),
    },
    policy,
  );
  if (!result.ok) throw new Error('unreachable');
  return result.value;
};

const endOf = (id: string) => ({
  commandId: commandIdOf('cmd-end-' + id),
  subscriptionId: subscriptionIdOf(id),
  motive: 'done',
  endedAt: instantOf(2_000),
});

export const subscriptionRepositoryContractSuite = (
  name: string,
  provider: SubscriptionRepositoryProvider,
): void => {
  describe(`SubscriptionRepository contract — ${name}`, () => {
    it('retains a newborn and reconstitutes it by Identifier, facts emptied', async () => {
      const { repository } = await provider.make();
      const born = startedSubscription('sub-1', 'person-1');
      expect((await repository.retain(born)).ok).toBe(true);
      const back = await repository.byId(born.id);
      expect(back.some && back.value.state.kind).toBe('Active');
      expect(back.some && back.value.pendingFacts).toHaveLength(0);
      expect(back.some && back.value.version).toBe(1);
    });

    it('an unknown Identifier is none', async () => {
      const { repository } = await provider.make();
      expect((await repository.byId(subscriptionIdOf('sub-ghost'))).some).toBe(false);
    });

    it('APPLIES THE R-A KEY at retention: a second ACTIVE subscription for the same holder refuses', async () => {
      const { repository } = await provider.make();
      await repository.retain(startedSubscription('sub-1', 'person-1'));
      const second = await repository.retain(startedSubscription('sub-2', 'person-1', 'offer-plus'));
      expect(!second.ok && second.error.reason).toBe('SubscriptionAlreadyExists');
      // Another holder passes the key.
      expect((await repository.retain(startedSubscription('sub-3', 'person-2'))).ok).toBe(true);
    });

    it('RELEASES THE R-A KEY when the subscription ends: re-subscribing is a NEW unit (R-B)', async () => {
      const { repository } = await provider.make();
      const first = startedSubscription('sub-1', 'person-1');
      await repository.retain(first);
      const loaded = await repository.byId(first.id);
      if (!loaded.some) throw new Error('unreachable');
      const ended = loaded.value.end(endOf('sub-1'));
      if (!ended.ok) throw new Error('unreachable');
      expect((await repository.retain(ended.value)).ok).toBe(true);
      expect((await repository.activeByHolder(personIdOf('person-1'))).some).toBe(false);
      expect((await repository.retain(startedSubscription('sub-2', 'person-1'))).ok).toBe(true);
      const active = await repository.activeByHolder(personIdOf('person-1'));
      expect(active.some && active.value.id).toBe('sub-2');
    });

    it('activeByHolder is the probe: the ACTIVE one only, per holder', async () => {
      const { repository } = await provider.make();
      await repository.retain(startedSubscription('sub-1', 'person-1'));
      const probe = await repository.activeByHolder(personIdOf('person-1'));
      expect(probe.some && probe.value.id).toBe('sub-1');
      expect((await repository.activeByHolder(personIdOf('person-2'))).some).toBe(false);
    });

    it('refuses a second birth under the same Identifier — R-B', async () => {
      const { repository } = await provider.make();
      await repository.retain(startedSubscription('sub-1', 'person-1'));
      const again = await repository.retain(startedSubscription('sub-1', 'person-9'));
      expect(!again.ok && again.error.reason).toBe('TransitionUnavailable');
    });

    it('a stale version is a TRANSIENT FAILURE — thrown, never a Decision (S-3)', async () => {
      const { repository } = await provider.make();
      const born = startedSubscription('sub-1', 'person-1');
      await repository.retain(born);
      const loaded = await repository.byId(born.id);
      if (!loaded.some) throw new Error('unreachable');
      const a = loaded.value.end(endOf('sub-1'));
      const b = loaded.value.end(endOf('sub-1'));
      if (!a.ok || !b.ok) throw new Error('unreachable');
      await repository.retain(a.value);
      await expect(repository.retain(b.value)).rejects.toThrow(/version conflict/);
    });
  });
};
