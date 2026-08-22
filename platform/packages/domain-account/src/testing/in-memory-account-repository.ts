import type { Option, Result } from '@mentora/kernel';
import { err, none, ok, some } from '@mentora/kernel';

import type { Account } from '../aggregate/account.js';
import type { AvailabilityFrame } from '../aggregate/availability-frame.js';
import type { AccountRefusal, AvailabilityFrameRefusal } from '../decisions/account-refusal.js';
import { accountRefusal, availabilityFrameRefusal } from '../decisions/account-refusal.js';
import type { PersonId } from '../ids/identifiers.js';

/**
 * The REFERENCE implementations of the Lot A01 ports (I-10 precedent:
 * InMemoryCredentialRepository): they exhibit the exact behavior every real
 * registry must replay — the version law (expected previous =
 * version − unretainedActs; stale = thrown transient Failure, S-3), R-B at
 * birth (an inhabited identity refuses, a motivated VALUE). Pure classes —
 * no test-runner import (the barrels lesson).
 */

interface Retained<T> {
  readonly unit: T;
  readonly version: number;
}

const staleError = (id: string, retained: number, expected: number): Error =>
  new Error(`version conflict on ${id}: retained ${retained}, expected ${expected}`);

export class InMemoryAccountRepository {
  private readonly store = new Map<string, Retained<Account>>();

  byId(id: PersonId): Promise<Option<Account>> {
    const found = this.store.get(id);
    return Promise.resolve(found === undefined ? none : some(found.unit));
  }

  retain(account: Account): Promise<Result<void, AccountRefusal>> {
    const existing = this.store.get(account.id);
    const expectedPrevious = account.version - account.unretainedActs;
    if (existing === undefined && expectedPrevious !== 0) {
      return Promise.reject(staleError(account.id, 0, expectedPrevious));
    }
    if (existing !== undefined && expectedPrevious === 0) {
      // A birth under an inhabited identity — R-B, refused as a VALUE.
      return Promise.resolve(
        err(
          accountRefusal(
            'TransitionUnavailable',
            'An Account already lives under this person — a new unit requires a new identity (R-B)',
          ),
        ),
      );
    }
    if (existing !== undefined && existing.version !== expectedPrevious) {
      return Promise.reject(staleError(account.id, existing.version, expectedPrevious));
    }
    this.store.set(account.id, { unit: account.retained(), version: account.version });
    return Promise.resolve(ok(undefined));
  }
}

export class InMemoryAvailabilityFrameRepository {
  private readonly store = new Map<string, Retained<AvailabilityFrame>>();

  byId(id: PersonId): Promise<Option<AvailabilityFrame>> {
    const found = this.store.get(id);
    return Promise.resolve(found === undefined ? none : some(found.unit));
  }

  retain(frame: AvailabilityFrame): Promise<Result<void, AvailabilityFrameRefusal>> {
    const existing = this.store.get(frame.id);
    const expectedPrevious = frame.version - frame.unretainedActs;
    if (existing === undefined && expectedPrevious !== 0) {
      return Promise.reject(staleError(frame.id, 0, expectedPrevious));
    }
    if (existing !== undefined && expectedPrevious === 0) {
      return Promise.resolve(
        err(
          availabilityFrameRefusal(
            'TransitionUnavailable',
            'An AvailabilityFrame already lives for this person — change it, do not rebirth it (R-B)',
          ),
        ),
      );
    }
    if (existing !== undefined && existing.version !== expectedPrevious) {
      return Promise.reject(staleError(frame.id, existing.version, expectedPrevious));
    }
    this.store.set(frame.id, { unit: frame.retained(), version: frame.version });
    return Promise.resolve(ok(undefined));
  }
}
