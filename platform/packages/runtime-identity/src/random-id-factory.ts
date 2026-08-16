import type { IdGenerator } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';

/**
 * RandomIdFactory — prefixed random identifiers for TECHNICAL artifacts
 * (instance names, temp markers). Never for domain identities: those are
 * branded ids minted through their owning language. Cryptographic source
 * only — Math.random never generates an identity.
 */
export class RandomIdFactory implements IdGenerator {
  constructor(
    private readonly prefix: string = '',
    private readonly bytes: number = 16,
  ) {
    invariant(bytes >= 8, 'a random id carries at least 8 bytes of entropy');
  }

  generate(): string {
    const buffer = new Uint8Array(this.bytes);
    globalThis.crypto.getRandomValues(buffer);
    const hex = [...buffer].map((byte) => byte.toString(16).padStart(2, '0')).join('');
    return this.prefix === '' ? hex : `${this.prefix}-${hex}`;
  }
}
