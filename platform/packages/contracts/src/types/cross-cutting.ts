import type { Brand, Instant } from '@mentora/kernel';

/**
 * Transverse technical types used across packages. Not domain concepts.
 */

/**
 * A correlation id — the thread that ties the steps of one execution together
 * for observability. It rides on the transport **envelope**, never on a fact
 * (F4.3 M-3, F4.1 §9): the two layers never contaminate each other.
 */
export type CorrelationId = Brand<string, 'CorrelationId'>;

/** A thing that carries its creation instant. */
export interface Timestamped {
  readonly createdAt: Instant;
}

/** A thing addressable by an id of type `TId`. */
export interface Identifiable<TId> {
  readonly id: TId;
}
