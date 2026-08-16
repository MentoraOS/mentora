/**
 * RandomGenerator — the cryptographic randomness surface (Nonce/Salt are
 * CRYPTO MECHANISMS, never nameable in a truth — F5.4 §10). Backed by the
 * platform CSPRNG; Math.random never produces security material.
 */

export interface RandomGenerator {
  bytes(length: number): Uint8Array;
  hex(length: number): string;
}

export class CryptoRandomGenerator implements RandomGenerator {
  bytes(length: number): Uint8Array {
    const buffer = new Uint8Array(length);
    globalThis.crypto.getRandomValues(buffer);
    return buffer;
  }

  hex(length: number): string {
    return [...this.bytes(length)].map((byte) => byte.toString(16).padStart(2, '0')).join('');
  }
}
