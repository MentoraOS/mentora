import type { IdGenerator } from '@mentora/kernel';

/**
 * Deterministic, well-formed UUIDv4-shaped ids from a seed: the same seed always
 * yields the same sequence. Uses a splitmix32-style PRNG — small, fast, and
 * good enough for identifier diversity in tests (NOT cryptographic).
 */
export class SeededUuidGenerator implements IdGenerator {
  #state: number;

  constructor(seed: number) {
    // Force to uint32; any integer seed is fine.
    this.#state = seed >>> 0;
  }

  #nextUint32(): number {
    // splitmix32
    this.#state = (this.#state + 0x9e3779b9) >>> 0;
    let z = this.#state;
    z ^= z >>> 16;
    z = Math.imul(z, 0x21f0aaad);
    z ^= z >>> 15;
    z = Math.imul(z, 0x735a2d97);
    z ^= z >>> 15;
    return z >>> 0;
  }

  #hex(bits: number): string {
    // Produce `bits`/4 hex chars from the PRNG.
    let out = '';
    let remaining = bits;
    while (remaining > 0) {
      const take = Math.min(remaining, 32);
      const word = this.#nextUint32() >>> (32 - take);
      out += word.toString(16).padStart(take / 4, '0');
      remaining -= take;
    }
    return out;
  }

  generate(): string {
    // Canonical v4 layout: 8-4-4-4-12 with version and variant nibbles fixed.
    const a = this.#hex(32);
    const b = this.#hex(16);
    const c = this.#hex(12);
    const dNibble = (8 + (this.#nextUint32() & 0x3)).toString(16); // 8|9|a|b
    const d = this.#hex(12);
    const e = this.#hex(48);
    return `${a}-${b}-4${c}-${dNibble}${d}-${e}`;
  }
}
