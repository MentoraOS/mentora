/**
 * `Option<T>` — a value that may be present (`Some`) or absent (`None`), made
 * explicit in the type. It replaces `null`/`undefined` at API boundaries so that
 * "absent" is a case the caller must handle, not a landmine. Bridges to `Result`
 * via `toResult`.
 */

import type { Result } from './result.js';
import { err, ok } from './result.js';

export interface Some<T> {
  readonly some: true;
  readonly value: T;
}

export interface None {
  readonly some: false;
}

export type Option<T> = Some<T> | None;

/** Construct a present value. */
export const some = <T>(value: T): Some<T> => ({ some: true, value });

/** The absent value (a singleton — it carries no data). */
export const none: None = { some: false };

/** Type guard: present. */
export const isSome = <T>(option: Option<T>): option is Some<T> => option.some;

/** Type guard: absent. */
export const isNone = <T>(option: Option<T>): option is None => !option.some;

/** Lift a nullable value into an `Option`. */
export const fromNullable = <T>(value: T | null | undefined): Option<NonNullable<T>> =>
  value === null || value === undefined ? none : some(value as NonNullable<T>);

/** Transform the value if present. */
export const mapOption = <T, U>(option: Option<T>, f: (value: T) => U): Option<U> =>
  option.some ? some(f(option.value)) : none;

/** Chain a second optional step (monadic bind). */
export const flatMapOption = <T, U>(
  option: Option<T>,
  f: (value: T) => Option<U>,
): Option<U> => (option.some ? f(option.value) : none);

/** The value if present, or a fallback. */
export const getOrElse = <T>(option: Option<T>, fallback: T): T =>
  option.some ? option.value : fallback;

/** Convert to a `Result`, supplying the error to use when absent. */
export const toResult = <T, E>(option: Option<T>, onNone: () => E): Result<T, E> =>
  option.some ? ok(option.value) : err(onNone());
