import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import type { AvailabilityFrame } from '../aggregate/availability-frame.js';
import type { ChangeAvailabilityFrame } from '../commands/account-commands.js';
import { changeAvailabilityFrameBirth } from '../factories/account-factory.js';
import { commandIdOf, personIdOf } from '../ids/identifiers.js';
import type { AvailabilityFrameRepository } from '../ports/account-repository.js';

/**
 * AvailabilityFrameRepositoryContractSuite — the port's promises written
 * ONCE (I-10), on its own subpath. The frame is born at its first change
 * (RFC-003 P2) and identified by the person.
 */

export interface AvailabilityFrameRepositoryProvider {
  make(): Promise<{ repository: AvailabilityFrameRepository }>;
}

export const changeOf = (
  person: string,
  windows: readonly [number, number][],
  at = 1_000,
): ChangeAvailabilityFrame => ({
  commandId: commandIdOf(`cmd-${person}-${String(at)}`),
  personId: personIdOf(person),
  windows: windows.map(([start, end]) => ({ start: instantOf(start), end: instantOf(end) })),
  changedAt: instantOf(at),
});

export const bornFrame = (person: string): AvailabilityFrame => {
  const result = changeAvailabilityFrameBirth(changeOf(person, [[1_000, 2_000]]));
  if (!result.ok) throw new Error('unreachable');
  return result.value;
};

export const availabilityFrameRepositoryContractSuite = (
  name: string,
  provider: AvailabilityFrameRepositoryProvider,
): void => {
  describe(`AvailabilityFrameRepository contract — ${name}`, () => {
    it('retains the first change (the birth) and reconstitutes the frame by the person', async () => {
      const { repository } = await provider.make();
      const frame = bornFrame('person-1');
      expect((await repository.retain(frame)).ok).toBe(true);
      const back = await repository.byId(frame.id);
      expect(back.some && back.value.windows).toHaveLength(1);
      expect(back.some && back.value.version).toBe(1);
      expect(back.some && back.value.pendingFacts).toHaveLength(0);
    });

    it('absence is a value', async () => {
      const { repository } = await provider.make();
      expect((await repository.byId(personIdOf('person-ghost'))).some).toBe(false);
    });

    it('retains successive changes — the photo is the latest set of windows', async () => {
      const { repository } = await provider.make();
      const frame = bornFrame('person-1');
      await repository.retain(frame);
      const loaded = await repository.byId(frame.id);
      if (!loaded.some) throw new Error('unreachable');
      const changed = loaded.value.change(changeOf('person-1', [[5_000, 6_000], [7_000, 8_000]], 2_000));
      if (!changed.ok) throw new Error('unreachable');
      expect((await repository.retain(changed.value)).ok).toBe(true);
      const back = await repository.byId(frame.id);
      expect(back.some && back.value.windows.map((window) => window.start.epochMillis)).toEqual([5_000, 7_000]);
      expect(back.some && back.value.version).toBe(2);
    });

    it('refuses a rebirth under a person whose frame lives — R-B, a motivated VALUE', async () => {
      const { repository } = await provider.make();
      await repository.retain(bornFrame('person-1'));
      const again = await repository.retain(bornFrame('person-1'));
      expect(!again.ok && again.error.reason).toBe('TransitionUnavailable');
    });

    it('a stale version is a TRANSIENT FAILURE — thrown, never a Decision (S-3)', async () => {
      const { repository } = await provider.make();
      const frame = bornFrame('person-1');
      await repository.retain(frame);
      const loaded = await repository.byId(frame.id);
      if (!loaded.some) throw new Error('unreachable');
      const a = loaded.value.change(changeOf('person-1', [[5_000, 6_000]], 2_000));
      const b = loaded.value.change(changeOf('person-1', [[9_000, 9_500]], 2_000));
      if (!a.ok || !b.ok) throw new Error('unreachable');
      await repository.retain(a.value);
      await expect(repository.retain(b.value)).rejects.toThrow(/version conflict/);
    });
  });
};
