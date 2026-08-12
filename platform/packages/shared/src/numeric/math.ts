import type { Option } from '@mentora/kernel';
import { none, some } from '@mentora/kernel';

/** Pure numeric helpers. */

/** Constrain `value` to the inclusive `[min, max]` range. */
export const clamp = (value: number, min: number, max: number): number =>
  Math.min(Math.max(value, min), max);

/** Sum of the values (0 for an empty array). */
export const sum = (values: readonly number[]): number => values.reduce((acc, n) => acc + n, 0);

/** Arithmetic mean, or `none` for an empty array. */
export const mean = (values: readonly number[]): Option<number> =>
  values.length === 0 ? none : some(sum(values) / values.length);

/** Round `value` to `decimals` decimal places. */
export const roundTo = (value: number, decimals: number): number => {
  const factor = 10 ** decimals;
  return Math.round(value * factor) / factor;
};
