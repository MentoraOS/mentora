import { getOrElse } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { chunk, compact, groupBy, head, last, partition, unique, uniqueBy } from './array.js';

describe('array', () => {
  it('head/last return Option', () => {
    expect(getOrElse(head([1, 2, 3]), -1)).toBe(1);
    expect(getOrElse(last([1, 2, 3]), -1)).toBe(3);
    expect(getOrElse(head<number>([]), -1)).toBe(-1);
  });

  it('chunk splits into sized groups', () => {
    expect(chunk([1, 2, 3, 4, 5], 2)).toEqual([[1, 2], [3, 4], [5]]);
    expect(() => chunk([1], 0)).toThrow();
  });

  it('unique / uniqueBy preserve first-seen order', () => {
    expect(unique([1, 1, 2, 3, 3])).toEqual([1, 2, 3]);
    expect(uniqueBy([{ id: 1 }, { id: 1 }, { id: 2 }], (x) => x.id)).toEqual([{ id: 1 }, { id: 2 }]);
  });

  it('partition and groupBy', () => {
    expect(partition([1, 2, 3, 4], (n) => n % 2 === 0)).toEqual([
      [2, 4],
      [1, 3],
    ]);
    expect(groupBy(['a', 'bb', 'cc'], (s) => (s.length === 1 ? 'short' : 'long'))).toEqual({
      short: ['a'],
      long: ['bb', 'cc'],
    });
  });

  it('compact drops null/undefined', () => {
    expect(compact([1, null, 2, undefined, 3])).toEqual([1, 2, 3]);
  });
});
