import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

/**
 * Pure, technical validation helpers that return a `Result` rather than throwing.
 * These are TECHNICAL checks (shape, range) — not domain rules. Domain
 * invariants live in the domain packages (F3); a Specification there may of
 * course use these.
 */

/** A technical validation failure. Not a domain Reason. */
export interface ValidationError {
  readonly field: string;
  readonly rule: string;
  readonly message: string;
}

/** Require a non-blank string. */
export const requireNonEmptyString = (
  field: string,
  value: string,
): Result<string, ValidationError> =>
  value.trim().length > 0
    ? ok(value)
    : err({ field, rule: 'nonEmpty', message: `${field} must not be blank` });

/** Require a number within the inclusive range `[min, max]`. */
export const requireInRange = (
  field: string,
  value: number,
  min: number,
  max: number,
): Result<number, ValidationError> =>
  value >= min && value <= max
    ? ok(value)
    : err({ field, rule: 'range', message: `${field} must be within [${min}, ${max}]` });

/** Require a string no longer than `maxLength`. */
export const requireMaxLength = (
  field: string,
  value: string,
  maxLength: number,
): Result<string, ValidationError> =>
  value.length <= maxLength
    ? ok(value)
    : err({ field, rule: 'maxLength', message: `${field} must be at most ${maxLength} characters` });
