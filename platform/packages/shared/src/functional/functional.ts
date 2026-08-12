/**
 * Small functional-composition helpers. `pipe` threads a value left-to-right
 * through a series of functions, which reads in the order things happen (unlike
 * nested calls). Overloads keep every step fully typed.
 */

/** Returns its argument unchanged. */
export const identity = <T>(value: T): T => value;

/** Returns a thunk that always yields `value`. */
export const constant =
  <T>(value: T): (() => T) =>
  () =>
    value;

/** Does nothing. Useful as a default callback. */
export const noop = (): void => undefined;

/* eslint-disable @typescript-eslint/no-explicit-any -- variadic pipe needs an unconstrained implementation signature; the overloads above are fully typed. */
export function pipe<A, B>(value: A, ab: (a: A) => B): B;
export function pipe<A, B, C>(value: A, ab: (a: A) => B, bc: (b: B) => C): C;
export function pipe<A, B, C, D>(value: A, ab: (a: A) => B, bc: (b: B) => C, cd: (c: C) => D): D;
export function pipe<A, B, C, D, E>(
  value: A,
  ab: (a: A) => B,
  bc: (b: B) => C,
  cd: (c: C) => D,
  de: (d: D) => E,
): E;
export function pipe(value: unknown, ...fns: ReadonlyArray<(x: any) => unknown>): unknown {
  return fns.reduce((acc, fn) => fn(acc), value);
}
/* eslint-enable @typescript-eslint/no-explicit-any */
