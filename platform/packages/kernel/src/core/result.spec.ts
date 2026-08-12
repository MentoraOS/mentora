import { describe, expect, it } from 'vitest';

import { andThen, err, isErr, isOk, map, mapErr, matchResult, ok, unwrapOr } from './result.js';

describe('Result', () => {
  it('constructs and discriminates Ok/Err', () => {
    expect(isOk(ok(1))).toBe(true);
    expect(isErr(err('boom'))).toBe(true);
    expect(isOk(err('boom'))).toBe(false);
  });

  it('map transforms Ok and passes Err through', () => {
    expect(map(ok(2), (n) => n * 2)).toEqual(ok(4));
    expect(map(err<string>('e'), (n: number) => n * 2)).toEqual(err('e'));
  });

  it('mapErr transforms Err and passes Ok through', () => {
    expect(mapErr(err('e'), (s) => `${s}!`)).toEqual(err('e!'));
    expect(mapErr(ok(1), (s: string) => `${s}!`)).toEqual(ok(1));
  });

  it('andThen chains fallible steps', () => {
    const parse = (s: string) => (s === '' ? err('empty') : ok(s.length));
    expect(andThen(ok('abc'), parse)).toEqual(ok(3));
    expect(andThen(ok(''), parse)).toEqual(err('empty'));
    expect(andThen(err<string>('prior'), parse)).toEqual(err('prior'));
  });

  it('unwrapOr and matchResult fold both branches', () => {
    expect(unwrapOr(ok(5), 0)).toBe(5);
    expect(unwrapOr(err('e'), 0)).toBe(0);
    const label = matchResult(ok(5), { ok: (n) => `ok:${n}`, err: (e: string) => `err:${e}` });
    expect(label).toBe('ok:5');
  });
});
