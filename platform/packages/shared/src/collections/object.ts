import type { UnknownRecord } from '@mentora/kernel';

/**
 * Immutable, typed object helpers. Each returns a new object; none mutates its
 * input.
 */

/** A new object with only the given keys. */
export const pick = <T extends object, K extends keyof T>(
  source: T,
  keys: readonly K[],
): Pick<T, K> => {
  const out = {} as Pick<T, K>;
  for (const key of keys) {
    out[key] = source[key];
  }
  return out;
};

/** A new object without the given keys. */
export const omit = <T extends object, K extends keyof T>(
  source: T,
  keys: readonly K[],
): Omit<T, K> => {
  const excluded = new Set<PropertyKey>(keys);
  const out: Record<PropertyKey, unknown> = {};
  for (const key of Object.keys(source) as Array<keyof T>) {
    if (!excluded.has(key)) {
      out[key] = source[key];
    }
  }
  return out as Omit<T, K>;
};

/** A new object with each value transformed. */
export const mapValues = <T extends object, U>(
  source: T,
  f: (value: T[keyof T], key: keyof T) => U,
): Record<keyof T, U> => {
  const out = {} as Record<keyof T, U>;
  for (const key of Object.keys(source) as Array<keyof T>) {
    out[key] = f(source[key], key);
  }
  return out;
};

/** Is the value a plain object (not null, not an array, not a class instance)? */
export const isPlainObject = (value: unknown): value is UnknownRecord => {
  if (typeof value !== 'object' || value === null) {
    return false;
  }
  const proto: unknown = Object.getPrototypeOf(value);
  return proto === Object.prototype || proto === null;
};
