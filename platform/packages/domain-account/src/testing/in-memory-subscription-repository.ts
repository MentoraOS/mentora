import type { Option, Result } from '@mentora/kernel';
import { err, none, ok, some } from '@mentora/kernel';

import type { Subscription } from '../aggregate/subscription.js';
import type { SupportRequest } from '../aggregate/support-request.js';
import type { SubscriptionRefusal, SupportRequestRefusal } from '../decisions/account-refusal.js';
import { subscriptionRefusal, supportRequestRefusal } from '../decisions/account-refusal.js';
import type { PersonId, SubscriptionId, SupportRequestId } from '../ids/identifiers.js';
import { ActiveSubscriptionUniquenessSpecification } from '../specifications/active-subscription-uniqueness.specification.js';

/**
 * The REFERENCE implementations of the Lot A02 ports (I-10): the R-A key
 * applied AND released at retention (an ended subscription frees the
 * holder), the version law, R-B at birth, state-only retention for the
 * SupportRequest. Pure classes — no test-runner import.
 */

const staleError = (id: string, retained: number, expected: number): Error =>
  new Error(`version conflict on ${id}: retained ${retained}, expected ${expected}`);

export class InMemorySubscriptionRepository {
  private readonly store = new Map<string, { unit: Subscription; version: number }>();
  private readonly uniqueness = new ActiveSubscriptionUniquenessSpecification();

  byId(id: SubscriptionId): Promise<Option<Subscription>> {
    const found = this.store.get(id);
    return Promise.resolve(found === undefined ? none : some(found.unit));
  }

  activeByHolder(personId: PersonId): Promise<Option<Subscription>> {
    for (const { unit } of this.store.values()) {
      if (unit.state.kind === 'Active' && unit.personId === personId) {
        return Promise.resolve(some(unit));
      }
    }
    return Promise.resolve(none);
  }

  retain(subscription: Subscription): Promise<Result<void, SubscriptionRefusal>> {
    const existing = this.store.get(subscription.id);
    const expectedPrevious = subscription.version - subscription.unretainedActs;
    if (existing === undefined && expectedPrevious !== 0) {
      return Promise.reject(staleError(subscription.id, 0, expectedPrevious));
    }
    if (existing !== undefined && expectedPrevious === 0) {
      return Promise.resolve(
        err(
          subscriptionRefusal(
            'TransitionUnavailable',
            'A Subscription already lives under this Identifier — a new unit requires a new identity (R-B)',
          ),
        ),
      );
    }
    if (existing !== undefined && existing.version !== expectedPrevious) {
      return Promise.reject(staleError(subscription.id, existing.version, expectedPrevious));
    }
    // THE R-A KEY, applied structurally at retention — and RELEASED: an
    // ended subscription no longer conflicts.
    for (const { unit: other } of this.store.values()) {
      if (this.uniqueness.conflicts(subscription, other)) {
        return Promise.resolve(
          err(
            subscriptionRefusal(
              'SubscriptionAlreadyExists',
              'An ACTIVE Subscription already exists for this holder (R-A key)',
            ),
          ),
        );
      }
    }
    this.store.set(subscription.id, { unit: subscription.retained(), version: subscription.version });
    return Promise.resolve(ok(undefined));
  }
}

export class InMemorySupportRequestRepository {
  private readonly store = new Map<string, { unit: SupportRequest; version: number }>();

  byId(id: SupportRequestId): Promise<Option<SupportRequest>> {
    const found = this.store.get(id);
    return Promise.resolve(found === undefined ? none : some(found.unit));
  }

  retain(request: SupportRequest): Promise<Result<void, SupportRequestRefusal>> {
    const existing = this.store.get(request.id);
    const expectedPrevious = request.version - request.unretainedActs;
    if (existing === undefined && expectedPrevious !== 0) {
      return Promise.reject(staleError(request.id, 0, expectedPrevious));
    }
    if (existing !== undefined && expectedPrevious === 0) {
      return Promise.resolve(
        err(
          supportRequestRefusal(
            'TransitionUnavailable',
            'A SupportRequest already lives under this Identifier — a new unit requires a new identity (R-B)',
          ),
        ),
      );
    }
    if (existing !== undefined && existing.version !== expectedPrevious) {
      return Promise.reject(staleError(request.id, existing.version, expectedPrevious));
    }
    this.store.set(request.id, { unit: request.retained(), version: request.version });
    return Promise.resolve(ok(undefined));
  }
}
