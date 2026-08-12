import type { Brand } from '../types/brand.js';

/**
 * Time primitives.
 *
 * Reading the current time is impure, so it is a **port** (`Clock`) — never a
 * `Date.now()` call buried in a library. This is F4.1 A-6 made concrete: time is
 * injected, captured once per execution, and the domain only ever sees an
 * `Instant` value (F3.1.99 §5: "l'horloge n'entre jamais dans l'unité").
 */

/** Milliseconds since the Unix epoch, branded so it is not just any number. */
export type EpochMillis = Brand<number, 'EpochMillis'>;

/** A point in time as a plain, immutable value. */
export interface Instant {
  readonly epochMillis: EpochMillis;
}

/** Port: the source of "now". Implemented by an adapter (system clock, test clock). */
export interface Clock {
  now(): Instant;
}

/** Construct an `Instant` from epoch milliseconds. */
export const instantOf = (epochMillis: number): Instant => ({
  epochMillis: epochMillis as EpochMillis,
});

/** Is `a` strictly before `b`? */
export const isBefore = (a: Instant, b: Instant): boolean => a.epochMillis < b.epochMillis;

/** Is `a` strictly after `b`? */
export const isAfter = (a: Instant, b: Instant): boolean => a.epochMillis > b.epochMillis;

/** Do `a` and `b` denote the same instant? */
export const isEqualInstant = (a: Instant, b: Instant): boolean => a.epochMillis === b.epochMillis;
