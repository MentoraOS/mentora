import type { AgreementRepository } from '@mentora/domain-agreement';
import { agreementIdOf, expertIdOf, timeSlotOf } from '@mentora/domain-agreement';
import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { AgreementVersionConflictError } from '../errors/agreement-persistence-errors.js';

import { AgreementPersistenceMother, MOTHER_T0 } from './agreement-persistence-mother.js';

/**
 * AgreementPersistenceContractSuite — the port's promises written ONCE,
 * executed against EVERY implementation (F4.4 I-10; the 0C describeContract
 * discipline): the in-memory double of the application specs and the real
 * PostgreSQL adapter must exhibit THE SAME behavior.
 */

export interface AgreementRepositoryProvider {
  /** A fresh, empty repository for each test. */
  make(): Promise<AgreementRepository>;
}

const HOUR = 3_600_000;

export const agreementPersistenceContractSuite = (
  name: string,
  provider: AgreementRepositoryProvider,
): void => {
  const mother = new AgreementPersistenceMother();

  describe(`AgreementRepository contract — ${name}`, () => {
    it('retains a birth and reconstitutes the WHOLE unit by Identifier (S-2)', async () => {
      const repository = await provider.make();
      const requested = mother.requested();
      expect((await repository.retain(requested)).ok).toBe(true);
      const loaded = await repository.byId(agreementIdOf('agr-1'));
      expect(loaded.some).toBe(true);
      if (loaded.some) {
        expect(loaded.value.toSnapshot()).toEqual(requested.retained().toSnapshot());
        expect(loaded.value.pendingFacts).toHaveLength(0);
      }
    });

    it('retains successive acts — the version advances, the photo is the latest', async () => {
      const repository = await provider.make();
      const requested = mother.requested();
      await repository.retain(requested);
      const loadedRequested = await repository.byId(agreementIdOf('agr-1'));
      expect(loadedRequested.some && loadedRequested.value.state.kind).toBe('Requested');
      await repository.retain(mother.acceptOf(requested.retained()));
      const loadedAccepted = await repository.byId(agreementIdOf('agr-1'));
      expect(loadedAccepted.some && loadedAccepted.value.state.kind).toBe('Accepted');
      expect(loadedAccepted.some && loadedAccepted.value.version).toBe(2);
    });

    it('refuses a second birth under the same Identifier — R-B, a motivated VALUE', async () => {
      const repository = await provider.make();
      await repository.retain(mother.requested());
      const second = await repository.retain(mother.requested());
      expect(!second.ok && second.error.reason).toBe('TransitionUnavailable');
    });

    it('a stale version is a TRANSIENT FAILURE, never a Decision (S-3)', async () => {
      const repository = await provider.make();
      const requested = mother.requested();
      await repository.retain(requested);
      const accepted = mother.acceptOf(requested.retained());
      expect((await repository.retain(accepted)).ok).toBe(true);
      // Two Sequences, one version: replaying the SAME accepted unit expects
      // stored v1 — but v2 is stored (F5.2 §4).
      await expect(repository.retain(accepted)).rejects.toBeInstanceOf(
        AgreementVersionConflictError,
      );
    });

    it('the declared R-A key refuses two CONFIRMED agreements of one expert on overlapping slots', async () => {
      const repository = await provider.make();
      await repository.retain(mother.confirmed({ id: 'agr-a' }));
      const overlapping = mother.confirmed({ id: 'agr-b' });
      const outcome = await repository.retain(overlapping);
      expect(!outcome.ok && outcome.error.reason).toBe('TimeSlotUnavailable');
      // The rollback is total: nothing partial exists (A-3).
      expect((await repository.byId(agreementIdOf('agr-b'))).some).toBe(false);
    });

    it('non-overlapping or non-confirmed slots pass the key', async () => {
      const repository = await provider.make();
      await repository.retain(mother.confirmed({ id: 'agr-a' }));
      const later = await repository.retain(
        mother.confirmed({ id: 'agr-c', slotStartMs: MOTHER_T0.epochMillis + 50 * HOUR }),
      );
      expect(later.ok).toBe(true);
      const requestedOverlap = await repository.retain(mother.requested({ id: 'agr-d' }));
      expect(requestedOverlap.ok).toBe(true);
    });

    it('byExpertAndWindow walks ONLY the confirmed, overlapping units (R-A walk)', async () => {
      const repository = await provider.make();
      await repository.retain(mother.confirmed({ id: 'agr-a' }));
      await repository.retain(
        mother.confirmed({ id: 'agr-far', slotStartMs: MOTHER_T0.epochMillis + 500 * HOUR }),
      );
      await repository.retain(mother.requested({ id: 'agr-req', slotStartMs: MOTHER_T0.epochMillis + 11 * HOUR }));
      const window = timeSlotOf(
        instantOf(MOTHER_T0.epochMillis),
        instantOf(MOTHER_T0.epochMillis + 100 * HOUR),
      );
      if (!window.ok) {
        throw new Error('window');
      }
      const found = await repository.byExpertAndWindow(expertIdOf('exp-1'), window.value);
      expect(found.map((unit) => unit.id)).toEqual(['agr-a']);
    });

    it('an unknown Identifier is none — never an invention', async () => {
      const repository = await provider.make();
      expect((await repository.byId(agreementIdOf('ghost'))).some).toBe(false);
    });
  });
};
