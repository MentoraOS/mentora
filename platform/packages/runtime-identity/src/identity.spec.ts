import { describe, expect, it } from 'vitest';

import { createIdentityProvider } from './identity-provider.js';
import { RandomIdFactory } from './random-id-factory.js';
import { UuidFactory } from './uuid-factory.js';

const UUID_SHAPE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

describe('UuidFactory', () => {
  it('generates canonical, unique UUIDs from the cryptographic source', () => {
    const factory = new UuidFactory();
    const seen = new Set(Array.from({ length: 100 }, () => factory.generate()));
    expect(seen.size).toBe(100);
    for (const id of seen) {
      expect(id).toMatch(UUID_SHAPE);
    }
  });
});

describe('RandomIdFactory', () => {
  it('generates prefixed hex identifiers with the demanded entropy', () => {
    const factory = new RandomIdFactory('probe', 12);
    const id = factory.generate();
    expect(id).toMatch(/^probe-[0-9a-f]{24}$/);
    expect(factory.generate()).not.toBe(id);
  });

  it('without a prefix yields bare hex', () => {
    expect(new RandomIdFactory().generate()).toMatch(/^[0-9a-f]{32}$/);
  });

  it('refuses starvation-level entropy (fail closed)', () => {
    expect(() => new RandomIdFactory('x', 4)).toThrow();
  });
});

describe('createIdentityProvider', () => {
  it('bundles the two generators', () => {
    const provider = createIdentityProvider();
    expect(provider.uuids.generate()).toMatch(UUID_SHAPE);
    expect(provider.randoms.generate()).toMatch(/^[0-9a-f]{32}$/);
  });
});
