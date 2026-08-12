import { assertNever, invariant } from '@mentora/kernel';

/**
 * Retry as a **pure description**. A `RetryPolicy` says how many attempts and how
 * long to wait; `computeBackoffMillis` derives the delay for a given attempt.
 * Actually *waiting* is an effect (a `Clock`/sleep port) supplied by the caller —
 * this module never sleeps, so it stays pure and testable.
 */

export type BackoffStrategy = 'fixed' | 'linear' | 'exponential';

export interface RetryPolicy {
  /** Total attempts, including the first. */
  readonly maxAttempts: number;
  /** Base delay used by the strategy. */
  readonly baseDelayMillis: number;
  /** How the delay grows with the attempt number. */
  readonly strategy: BackoffStrategy;
  /** Upper bound on any single delay. */
  readonly maxDelayMillis: number;
}

/** The delay (ms) before the given 1-based `attempt`, capped at `maxDelayMillis`. */
export const computeBackoffMillis = (policy: RetryPolicy, attempt: number): number => {
  invariant(attempt >= 1, 'attempt is 1-based');
  let raw: number;
  switch (policy.strategy) {
    case 'fixed':
      raw = policy.baseDelayMillis;
      break;
    case 'linear':
      raw = policy.baseDelayMillis * attempt;
      break;
    case 'exponential':
      raw = policy.baseDelayMillis * 2 ** (attempt - 1);
      break;
    default:
      return assertNever(policy.strategy);
  }
  return Math.min(raw, policy.maxDelayMillis);
};

/** Should another attempt be made after the given 1-based `attempt`? */
export const shouldRetry = (policy: RetryPolicy, attempt: number): boolean =>
  attempt < policy.maxAttempts;
