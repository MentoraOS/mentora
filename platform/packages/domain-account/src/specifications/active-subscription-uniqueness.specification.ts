import type { Subscription } from '../aggregate/subscription.js';

/**
 * ActiveSubscriptionUniquenessSpecification — THE DECLARED R-A RULE of the
 * Subscription (canon F3.2-B: "invariant : une souscription active à la
 * fois (clé R-A)" ; "R-A sur l'unicité d'abonnement actif"). Same
 * constitutional split as the reference (ActiveCredentialUniqueness): the
 * RULE lives here, readable and testable; the KEY is applied STRUCTURALLY
 * by the registry at retention (Lot A04: a partial unique index on the
 * holder WHERE Active); the refusal is the motivated Decision
 * `SubscriptionAlreadyExists`. The unit never scans the world.
 */
export class ActiveSubscriptionUniquenessSpecification {
  /** True when the two subscriptions would violate the R-A key together. */
  conflicts(candidate: Subscription, existing: Subscription): boolean {
    return (
      candidate.id !== existing.id &&
      candidate.state.kind === 'Active' &&
      existing.state.kind === 'Active' &&
      candidate.personId === existing.personId
    );
  }
}
