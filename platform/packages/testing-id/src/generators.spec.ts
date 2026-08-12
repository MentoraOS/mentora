import { isUuid } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { ConstantIdGenerator } from './constant-id-generator.js';
import { SeededUuidGenerator } from './seeded-uuid-generator.js';
import { SequentialIdGenerator } from './sequential-id-generator.js';

describe('SequentialIdGenerator', () => {
  it('produces prefix-1, prefix-2, … and resets', () => {
    const gen = new SequentialIdGenerator('agreement');
    expect(gen.generate()).toBe('agreement-1');
    expect(gen.generate()).toBe('agreement-2');
    gen.reset();
    expect(gen.generate()).toBe('agreement-1');
  });
});

describe('SeededUuidGenerator', () => {
  it('same seed → same sequence; different seed → different sequence', () => {
    const a1 = new SeededUuidGenerator(42);
    const a2 = new SeededUuidGenerator(42);
    const b = new SeededUuidGenerator(43);
    const seqA1 = [a1.generate(), a1.generate(), a1.generate()];
    const seqA2 = [a2.generate(), a2.generate(), a2.generate()];
    expect(seqA1).toEqual(seqA2);
    expect(seqA1[0]).not.toBe(b.generate());
  });

  it('produces canonical, kernel-valid UUIDs', () => {
    const gen = new SeededUuidGenerator(7);
    for (let i = 0; i < 20; i += 1) {
      const id = gen.generate();
      expect(isUuid(id), `not a uuid: ${id}`).toBe(true);
    }
  });
});

describe('ConstantIdGenerator', () => {
  it('always returns the same value', () => {
    const gen = new ConstantIdGenerator('fixed');
    expect(gen.generate()).toBe('fixed');
    expect(gen.generate()).toBe('fixed');
  });
});
