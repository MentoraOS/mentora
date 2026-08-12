/**
 * `Result<T, E>` — an operation that either succeeds with a `T` or fails with an
 * `E`, as a *value*. Failure is never an exception here; it is data you must
 * handle. This is the code realization of the Foundation's F3.1.14: a Decision
 * (accept/refuse, motivated) is a first-class return, and a Refusal is "la
 * moitié du contrat P4" — expected, healthy, carried as a value.
 *
 * Immutable, discriminated by `ok`, tree-shakable (all helpers are free
 * functions, not methods).
 */

export interface Ok<T> {
  readonly ok: true;
  readonly value: T;
}

export interface Err<E> {
  readonly ok: false;
  readonly error: E;
}

export type Result<T, E> = Ok<T> | Err<E>;

/** Construct a success. */
export const ok = <T>(value: T): Ok<T> => ({ ok: true, value });

/** Construct a failure. */
export const err = <E>(error: E): Err<E> => ({ ok: false, error });

/** Type guard: success. */
export const isOk = <T, E>(result: Result<T, E>): result is Ok<T> => result.ok;

/** Type guard: failure. */
export const isErr = <T, E>(result: Result<T, E>): result is Err<E> => !result.ok;

/** Transform the success value, leaving a failure untouched. */
export const map = <T, E, U>(result: Result<T, E>, f: (value: T) => U): Result<U, E> =>
  result.ok ? ok(f(result.value)) : result;

/** Transform the error value, leaving a success untouched. */
export const mapErr = <T, E, F>(result: Result<T, E>, f: (error: E) => F): Result<T, F> =>
  result.ok ? result : err(f(result.error));

/** Chain a second fallible step onto a success (monadic bind). */
export const andThen = <T, E, U>(
  result: Result<T, E>,
  f: (value: T) => Result<U, E>,
): Result<U, E> => (result.ok ? f(result.value) : result);

/** The success value, or a fallback on failure. */
export const unwrapOr = <T, E>(result: Result<T, E>, fallback: T): T =>
  result.ok ? result.value : fallback;

/** Fold both branches to a single value. */
export const matchResult = <T, E, U>(
  result: Result<T, E>,
  cases: { readonly ok: (value: T) => U; readonly err: (error: E) => U },
): U => (result.ok ? cases.ok(result.value) : cases.err(result.error));

/**
 * Run a throwing function and capture the outcome as a `Result`. The boundary
 * where an exception (someone else's) becomes a value (ours).
 */
export const fromThrowable = <T>(f: () => T): Result<T, unknown> => {
  try {
    return ok(f());
  } catch (error) {
    return err(error);
  }
};
