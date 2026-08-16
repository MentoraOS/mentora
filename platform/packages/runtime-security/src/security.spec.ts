import { describe, expect, it } from 'vitest';

import { CryptoRandomGenerator } from './random-generator.js';
import { secretReferenceOf } from './secret-reference.js';
import { InMemorySecretResolver } from './secret-resolver.js';

describe('SecretReference (the name, never the value — I-8)', () => {
  it('brands a non-blank name and refuses blanks', () => {
    expect(secretReferenceOf('vault/postgres/main')).toBe('vault/postgres/main');
    expect(() => secretReferenceOf('   ')).toThrow();
  });
});

describe('InMemorySecretResolver (vestibule double)', () => {
  it('resolves a known reference and refuses an unknown one — fail closed', async () => {
    const resolver = new InMemorySecretResolver({ 'vault/probe': 'value-1' });
    const hit = await resolver.resolve(secretReferenceOf('vault/probe'));
    expect(hit.ok && hit.value).toBe('value-1');
    const miss = await resolver.resolve(secretReferenceOf('vault/absent'));
    expect(!miss.ok && miss.error).toEqual({ code: 'SECRET.UNKNOWN', reference: 'vault/absent' });
  });
});

describe('CryptoRandomGenerator (CSPRNG — never Math.random)', () => {
  it('yields the demanded lengths and does not repeat', () => {
    const random = new CryptoRandomGenerator();
    expect(random.bytes(16)).toHaveLength(16);
    const first = random.hex(16);
    expect(first).toMatch(/^[0-9a-f]{32}$/);
    expect(random.hex(16)).not.toBe(first);
  });
});
