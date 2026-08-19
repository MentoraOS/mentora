import { createPublicKey, timingSafeEqual, verify as cryptoVerify } from 'node:crypto';

import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

/**
 * ID-token verification over the RAW protocol (ADR-0004 §3: zero provider
 * SDK; the platform's crypto verifies — T-24: it demonstrates, never
 * decides). RS256 and ES256, keys from the provider's JWKS by `kid`.
 * Every rejection is a flat, motivated string — nothing throws for a bad
 * token (a lying token is the CALLER's material, not our defect).
 */

export interface JsonWebKey {
  readonly kid?: string;
  readonly kty: string;
  readonly [claim: string]: unknown;
}

export interface IdTokenExpectation {
  readonly issuer: string;
  readonly audience: string;
  readonly nowSeconds: number;
  readonly nonce?: string;
}

export interface VerifiedIdToken {
  readonly subject: string;
  readonly claims: Readonly<Record<string, unknown>>;
}

const base64urlJson = (part: string): Record<string, unknown> | undefined => {
  try {
    return JSON.parse(Buffer.from(part, 'base64url').toString('utf8')) as Record<string, unknown>;
  } catch {
    return undefined;
  }
};

const ALGORITHMS: Readonly<Record<string, { hash: string; dsaEncoding?: 'ieee-p1363' }>> = {
  RS256: { hash: 'sha256' },
  ES256: { hash: 'sha256', dsaEncoding: 'ieee-p1363' },
};

export const verifyIdToken = (
  token: string,
  keys: readonly JsonWebKey[],
  expected: IdTokenExpectation,
): Result<VerifiedIdToken, string> => {
  const parts = token.split('.');
  if (parts.length !== 3) {
    return err('token is not a compact JWS');
  }
  const [headerPart, payloadPart, signaturePart] = parts as [string, string, string];
  const header = base64urlJson(headerPart);
  const payload = base64urlJson(payloadPart);
  if (header === undefined || payload === undefined) {
    return err('token parts are not JSON');
  }
  const algorithm = ALGORITHMS[String(header['alg'])];
  if (algorithm === undefined) {
    return err(`unsupported algorithm '${String(header['alg'])}'`);
  }
  const key = keys.find((candidate) => candidate.kid === header['kid']) ?? keys[0];
  if (key === undefined) {
    return err('no key matches the token');
  }
  let verified: boolean;
  try {
    const publicKey = createPublicKey({ key: key as never, format: 'jwk' });
    verified = cryptoVerify(
      algorithm.hash,
      Buffer.from(`${headerPart}.${payloadPart}`),
      algorithm.dsaEncoding === undefined
        ? publicKey
        : { key: publicKey, dsaEncoding: algorithm.dsaEncoding },
      Buffer.from(signaturePart, 'base64url'),
    );
  } catch {
    return err('the key refuses this token');
  }
  if (!verified) {
    return err('signature does not verify');
  }
  if (payload['iss'] !== expected.issuer) {
    return err('issuer mismatch');
  }
  const audience = payload['aud'];
  const audienceHolds = Array.isArray(audience)
    ? audience.includes(expected.audience)
    : audience === expected.audience;
  if (!audienceHolds) {
    return err('audience mismatch');
  }
  if (typeof payload['exp'] !== 'number' || payload['exp'] <= expected.nowSeconds) {
    return err('token is expired');
  }
  if (expected.nonce !== undefined) {
    const nonce = typeof payload['nonce'] === 'string' ? payload['nonce'] : '';
    const left = Buffer.from(nonce);
    const right = Buffer.from(expected.nonce);
    if (left.length !== right.length || !timingSafeEqual(left, right)) {
      return err('nonce mismatch');
    }
  }
  const subject = payload['sub'];
  if (typeof subject !== 'string' || subject === '') {
    return err('token carries no subject');
  }
  return ok({ subject, claims: payload });
};
