import type { Option } from '@mentora/kernel';
import { invariant, isDefined, none, some } from '@mentora/kernel';

/**
 * Immutable, total array helpers. Access that could be out of range returns an
 * `Option` rather than `undefined`, so the caller cannot forget the empty case.
 */

/** Is the array empty? */
export const isEmpty = <T>(array: readonly T[]): boolean => array.length === 0;

/** The first element, if any. */
export const head = <T>(array: readonly T[]): Option<T> =>
  array.length === 0 ? none : some(array[0] as T);

/** The last element, if any. */
export const last = <T>(array: readonly T[]): Option<T> =>
  array.length === 0 ? none : some(array[array.length - 1] as T);

/** Split into consecutive chunks of at most `size`. */
export const chunk = <T>(array: readonly T[], size: number): T[][] => {
  invariant(size > 0, 'chunk size must be greater than 0');
  const out: T[][] = [];
  for (let i = 0; i < array.length; i += size) {
    out.push(array.slice(i, i + size));
  }
  return out;
};

/** Distinct elements, preserving first-seen order (by SameValueZero equality). */
export const unique = <T>(array: readonly T[]): T[] => [...new Set(array)];

/** Distinct elements by a derived key, preserving first-seen order. */
export const uniqueBy = <T, K>(array: readonly T[], key: (item: T) => K): T[] => {
  const seen = new Set<K>();
  const out: T[] = [];
  for (const item of array) {
    const k = key(item);
    if (!seen.has(k)) {
      seen.add(k);
      out.push(item);
    }
  }
  return out;
};

/** Split into `[matching, notMatching]`. */
export const partition = <T>(
  array: readonly T[],
  predicate: (item: T) => boolean,
): readonly [T[], T[]] => {
  const matching: T[] = [];
  const notMatching: T[] = [];
  for (const item of array) {
    (predicate(item) ? matching : notMatching).push(item);
  }
  return [matching, notMatching];
};

/** Group elements by a string key. */
export const groupBy = <T, K extends string>(
  array: readonly T[],
  key: (item: T) => K,
): Record<K, T[]> => {
  // Partial during construction: a freshly-seen key genuinely has no bucket yet.
  const out: Partial<Record<K, T[]>> = {};
  for (const item of array) {
    const k = key(item);
    const bucket = out[k];
    if (bucket === undefined) {
      out[k] = [item];
    } else {
      bucket.push(item);
    }
  }
  return out as Record<K, T[]>;
};

/** Drop `null`/`undefined`, narrowing the element type. */
export const compact = <T>(array: ReadonlyArray<T | null | undefined>): T[] =>
  array.filter(isDefined);

/** `[start, endExclusive)` as an array of integers. */
export const range = (start: number, endExclusive: number): number[] => {
  const out: number[] = [];
  for (let i = start; i < endExclusive; i += 1) {
    out.push(i);
  }
  return out;
};
