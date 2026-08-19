import { randomBytes, scrypt, timingSafeEqual } from 'node:crypto';

import type { PasswordHasher } from '@mentora/runtime-security';

/**
 * ScryptPasswordHasher — the vestibule's password digest MECHANISM (Story
 * #97), implementing the runtime-security surface with the PLATFORM's
 * vetted KDF (node:crypto scrypt — nothing hand-rolled, zero new
 * dependency; T-24: the cryptography demonstrates, it never decides).
 * Self-describing digest format `scrypt$N$r$p$salt$hash` (base64url): the
 * parameters ride WITH the digest so they can harden later without a
 * migration (S-7 by format). Verification is constant-time.
 */

const N = 16_384;
const R = 8;
const P = 1;
const KEY_LENGTH = 32;
const SALT_LENGTH = 16;

const derive = (password: string, salt: Buffer, n: number, r: number, p: number): Promise<Buffer> =>
  new Promise((resolve, reject) => {
    scrypt(password, salt, KEY_LENGTH, { N: n, r, p }, (error, derived) => {
      if (error !== null) {
        reject(error);
        return;
      }
      resolve(derived);
    });
  });

export class ScryptPasswordHasher implements PasswordHasher {
  async hash(password: string): Promise<string> {
    const salt = randomBytes(SALT_LENGTH);
    const derived = await derive(password, salt, N, R, P);
    return `scrypt$${String(N)}$${String(R)}$${String(P)}$${salt.toString('base64url')}$${derived.toString('base64url')}`;
  }

  async verify(password: string, hashed: string): Promise<boolean> {
    const parts = hashed.split('$');
    if (parts.length !== 6 || parts[0] !== 'scrypt') {
      return false;
    }
    const [, n, r, p, salt, expected] = parts;
    const expectedBuffer = Buffer.from(expected as string, 'base64url');
    const derived = await derive(
      password,
      Buffer.from(salt as string, 'base64url'),
      Number(n),
      Number(r),
      Number(p),
    );
    return derived.length === expectedBuffer.length && timingSafeEqual(derived, expectedBuffer);
  }
}
