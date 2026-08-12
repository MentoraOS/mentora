import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

import { err, none, ok, some } from '@mentora/kernel';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { buildMany, defineFixture } from './fixtures.js';
import { compareToGoldenFile, toStableJson } from './golden.js';
import { registerMentoraMatchers } from './matchers.js';
import { RandomFactory } from './random.js';

beforeAll(() => {
  registerMentoraMatchers();
});

describe('matchers', () => {
  it('Result matchers pass and fail correctly', () => {
    expect(ok(42)).toBeOk();
    expect(ok(42)).toBeOkWith(42);
    expect(err('nope')).toBeErr();
    expect(err({ reason: 'x' })).toBeErrWith({ reason: 'x' });
    expect(ok(1)).not.toBeErr();
  });

  it('Option matchers', () => {
    expect(some('a')).toBeSomeWith('a');
    expect(none).toBeNone();
    expect(some(1)).not.toBeNone();
  });
});

describe('fixtures', () => {
  const aPerson = defineFixture(() => ({ name: 'Ada', age: 36 }));

  it('defaults + overrides, fresh object each call', () => {
    expect(aPerson()).toEqual({ name: 'Ada', age: 36 });
    expect(aPerson({ age: 41 })).toEqual({ name: 'Ada', age: 41 });
    expect(aPerson()).not.toBe(aPerson());
  });

  it('buildMany customizes by index', () => {
    const people = buildMany(aPerson, 3, (i) => ({ name: `p${String(i)}` }));
    expect(people.map((p) => p.name)).toEqual(['p0', 'p1', 'p2']);
  });
});

describe('RandomFactory', () => {
  it('same seed → same data; bounds respected', () => {
    const a = new RandomFactory(7);
    const b = new RandomFactory(7);
    expect([a.int(0, 100), a.string(8), a.bool()]).toEqual([b.int(0, 100), b.string(8), b.bool()]);
    const c = new RandomFactory(1);
    for (let i = 0; i < 100; i += 1) {
      const n = c.int(5, 10);
      expect(n).toBeGreaterThanOrEqual(5);
      expect(n).toBeLessThanOrEqual(10);
    }
  });

  it('shuffle is a deterministic permutation', () => {
    const items = [1, 2, 3, 4, 5];
    const s1 = new RandomFactory(9).shuffle(items);
    const s2 = new RandomFactory(9).shuffle(items);
    expect(s1).toEqual(s2);
    expect([...s1].sort((x, y) => x - y)).toEqual(items);
  });
});

describe('golden files', () => {
  let dir: string;
  beforeAll(() => {
    dir = mkdtempSync(join(tmpdir(), 'mentora-golden-'));
  });
  afterAll(() => {
    rmSync(dir, { recursive: true, force: true });
  });

  it('toStableJson sorts keys recursively', () => {
    expect(toStableJson({ b: 1, a: { d: 2, c: 3 } })).toBe(
      '{\n  "a": {\n    "c": 3,\n    "d": 2\n  },\n  "b": 1\n}\n',
    );
  });

  it('creates the golden on first run, then compares', () => {
    const path = join(dir, 'sample.golden.json');
    const first = compareToGoldenFile(path, toStableJson({ x: 1 }));
    expect(first.updated).toBe(true);
    const same = compareToGoldenFile(path, toStableJson({ x: 1 }));
    expect(same).toMatchObject({ matches: true, updated: false });
    const different = compareToGoldenFile(path, toStableJson({ x: 2 }));
    expect(different.matches).toBe(false);
  });
});
