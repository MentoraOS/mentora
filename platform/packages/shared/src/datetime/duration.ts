import type { Instant } from '@mentora/kernel';
import { instantOf } from '@mentora/kernel';

/**
 * Pure duration helpers over the kernel's `Instant`. No `Date.now()` — the
 * current time is a `Clock` port (F4.1 A-6); these functions only transform
 * instants they are given.
 */

/** A span of time, in milliseconds. */
export type Millis = number;

export const SECOND_MS: Millis = 1_000;
export const MINUTE_MS: Millis = 60 * SECOND_MS;
export const HOUR_MS: Millis = 60 * MINUTE_MS;
export const DAY_MS: Millis = 24 * HOUR_MS;

/** A new instant, `millis` after `instant`. */
export const addMillis = (instant: Instant, millis: Millis): Instant =>
  instantOf(instant.epochMillis + millis);

/** The signed duration from `from` to `to`, in milliseconds. */
export const durationBetweenMillis = (from: Instant, to: Instant): Millis =>
  to.epochMillis - from.epochMillis;
