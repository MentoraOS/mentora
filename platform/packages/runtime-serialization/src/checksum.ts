/**
 * Checksums — integrity fingerprints for TECHNICAL artifacts (a fingerprint
 * demonstrates, it never decides — T-24 spirit). FNV-1a: deterministic,
 * dependency-free; cryptographic integrity (signatures, attestation) is the
 * supply chain's (T-21) and lives in adapters.
 */

export interface ChecksumCalculator {
  readonly algorithm: string;
  checksum(text: string): string;
}

export const fnv1a32Hex = (text: string): string => {
  let hash = 0x811c9dc5;
  for (let index = 0; index < text.length; index += 1) {
    hash ^= text.charCodeAt(index);
    hash = Math.imul(hash, 0x01000193) >>> 0;
  }
  return hash.toString(16).padStart(8, '0');
};

export const fnv1aChecksum: ChecksumCalculator = {
  algorithm: 'fnv1a-32',
  checksum: fnv1a32Hex,
};
