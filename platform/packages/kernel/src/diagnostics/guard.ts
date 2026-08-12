import type { NonEmptyArray } from '../types/utility-types.js';

import { GuardError, InvariantViolationError } from './errors.js';

/**
 * Guards and assertions. These express *programmer* preconditions — things that
 * must be true or the code is wrong. They throw. They are NOT for domain
 * refusals (use `Result` for those).
 */

/** Narrows out `null`/`undefined` without throwing. */
export function isDefined<T>(value: T | null | undefined): value is T {
  return value !== null && value !== undefined;
}

/** Asserts a condition; throws `InvariantViolationError` if it does not hold. */
export function invariant(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new InvariantViolationError(message);
  }
}

/**
 * Returns `value` if it is defined, otherwise throws `GuardError`. Use at
 * boundaries where a value is required by contract.
 */
export function guardDefined<T>(value: T | null | undefined, name: string): T {
  if (value === null || value === undefined) {
    throw new GuardError(`${name} is required but was ${String(value)}`);
  }
  return value;
}

/**
 * Exhaustiveness helper for discriminated unions. Placing `assertNever(x)` in the
 * default branch of a switch turns a missing case into a compile error — the
 * code form of "aucune transition silencieuse" (F3.1.99 §5).
 */
export function assertNever(value: never, message = 'Unexpected value'): never {
  throw new InvariantViolationError(`${message}: ${JSON.stringify(value)}`);
}

/** Type guard: a non-empty array. */
export function isNonEmptyArray<T>(value: readonly T[]): value is NonEmptyArray<T> {
  return value.length > 0;
}
