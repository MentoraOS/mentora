import { invariant } from '@mentora/kernel';

/**
 * Seeded random data factory. All "random" test data flows from an explicit
 * seed, so a failing test reproduces exactly by re-running with the same seed.
 * Never `Math.random()` in a test — unseeded randomness is unreproducible.
 */
export class RandomFactory {
  #state: number;

  constructor(seed: number) {
    this.#state = seed >>> 0;
  }

  /** Next float in [0, 1). Deterministic (splitmix32). */
  nextFloat(): number {
    this.#state = (this.#state + 0x9e3779b9) >>> 0;
    let z = this.#state;
    z ^= z >>> 16;
    z = Math.imul(z, 0x21f0aaad);
    z ^= z >>> 15;
    z = Math.imul(z, 0x735a2d97);
    z ^= z >>> 15;
    return (z >>> 0) / 0x1_0000_0000;
  }

  /** Integer in [min, max] inclusive. */
  int(min: number, max: number): number {
    invariant(Number.isInteger(min) && Number.isInteger(max), 'bounds must be integers');
    invariant(min <= max, 'min must be <= max');
    return min + Math.floor(this.nextFloat() * (max - min + 1));
  }

  /** True with probability `p` (default 0.5). */
  bool(p = 0.5): boolean {
    return this.nextFloat() < p;
  }

  /** One element of a non-empty array. */
  pick<T>(items: readonly T[]): T {
    invariant(items.length > 0, 'cannot pick from an empty array');
    return items[this.int(0, items.length - 1)] as T;
  }

  /** A lowercase alphanumeric string of the given length. */
  string(length: number, alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789'): string {
    invariant(length >= 0, 'length must be >= 0');
    let out = '';
    for (let i = 0; i < length; i += 1) {
      out += alphabet.charAt(this.int(0, alphabet.length - 1));
    }
    return out;
  }

  /** A new array with the same elements in a deterministic shuffled order. */
  shuffle<T>(items: readonly T[]): T[] {
    const out = [...items];
    for (let i = out.length - 1; i > 0; i -= 1) {
      const j = this.int(0, i);
      const a = out[i] as T;
      out[i] = out[j] as T;
      out[j] = a;
    }
    return out;
  }
}
