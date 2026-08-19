import { createHash, randomBytes } from 'node:crypto';

/**
 * PKCE (RFC 7636, S256 only) — the code-interception guard of the
 * Authorization Code flow (ADR-0004 §1). The verifier is minted fresh per
 * entry attempt and lives ONLY for that attempt (state, not a secret of
 * the vault — it seals one round trip). `plain` is deliberately absent:
 * S256 or nothing.
 */

export interface PkcePair {
  readonly verifier: string;
  readonly challenge: string;
  readonly method: 'S256';
}

export const mintPkce = (): PkcePair => {
  const verifier = randomBytes(32).toString('base64url');
  return { verifier, challenge: challengeOf(verifier), method: 'S256' };
};

export const challengeOf = (verifier: string): string =>
  createHash('sha256').update(verifier).digest('base64url');
