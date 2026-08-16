import type { Result } from '@mentora/kernel';

import type { SecretReference } from './secret-reference.js';
import type { SecretViolation } from './secret-resolver.js';

/**
 * Cryptographic SURFACES — interfaces only, DELIBERATELY unimplemented:
 * "toute chaîne de fabrication est signée, attestée, vérifiée" (T-21) and
 * "la cryptographie démontre ; elle ne décide jamais" (T-24) — real
 * primitives come from vetted providers behind adapters, never hand-rolled
 * in a foundation package. Keys live at the vault, addressed BY REFERENCE
 * (I-8: "un secret n'a qu'un lieu ; ailleurs, seulement son nom").
 *
 * PasswordHasher exists for the VESTIBULE only: "Credential" and "Session"
 * are the frozen property of the I&A domain (F5.4 §2) — no domain package
 * ever sees a password or this surface.
 */

export interface Encryptor {
  encrypt(plain: Uint8Array, keyReference: SecretReference): Promise<Uint8Array>;
}

export interface Decryptor {
  decrypt(sealed: Uint8Array, keyReference: SecretReference): Promise<Uint8Array>;
}

export interface Hasher {
  readonly algorithm: string;
  hash(bytes: Uint8Array): Promise<Uint8Array>;
}

export interface PasswordHasher {
  hash(password: string): Promise<string>;
  verify(password: string, hashed: string): Promise<boolean>;
}

export interface KeyProvider {
  keyFor(reference: SecretReference): Promise<Result<Uint8Array, SecretViolation>>;
}
