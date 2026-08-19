import {
  createSign,
  generateKeyPairSync,
  verify as cryptoVerify,
} from 'node:crypto';

import { InMemorySecretResolver, secretReferenceOf } from '@mentora/runtime-security';
import { describe, expect, it } from 'vitest';

import { AppleClientSecretSigner } from './apple/apple-client-secret.js';
import { GitHubIdentityAdapter } from './github/github-identity-adapter.js';
import { verifyIdToken } from './oidc/id-token.js';
import type { FetchLike } from './oidc/oidc-provider.js';
import { OidcProviderAdapter } from './oidc/oidc-provider.js';
import { challengeOf, mintPkce } from './oidc/pkce.js';
import {
  FEDERATED_STRENGTHS,
  federatedFactorId,
  OIDC_ENDPOINTS,
} from './registry/federated-providers.js';

/**
 * The federation mechanism against SIMULATED providers (ADR-0004: never
 * the real ones in CI). An RSA keypair minted per run signs the simulated
 * id_tokens; the fetch seam plays the provider's three surfaces. No
 * network, no SDK, no clock read inside the adapters (now injected).
 */

const NOW = 1_700_000_000;

const { privateKey, publicKey } = generateKeyPairSync('rsa', { modulusLength: 2048 });
const jwk = { ...publicKey.export({ format: 'jwk' }), kid: 'sim-key-1', kty: 'RSA' };

const signedIdToken = (claims: Record<string, unknown>): string => {
  const header = Buffer.from(JSON.stringify({ alg: 'RS256', kid: 'sim-key-1' })).toString(
    'base64url',
  );
  const payload = Buffer.from(JSON.stringify(claims)).toString('base64url');
  const signer = createSign('RSA-SHA256');
  signer.update(`${header}.${payload}`);
  return `${header}.${payload}.${signer.sign(privateKey).toString('base64url')}`;
};

const googleClaims = (overrides: Record<string, unknown> = {}): Record<string, unknown> => ({
  iss: 'https://accounts.google.com',
  aud: 'client-sim',
  sub: 'subject-42',
  exp: NOW + 300,
  nonce: 'nonce-1',
  ...overrides,
});

const simulatedProvider = (idToken: string): { fetch: FetchLike; exchanges: string[] } => {
  const exchanges: string[] = [];
  const fetch: FetchLike = (url, init) => {
    if (url === OIDC_ENDPOINTS.google.tokenEndpoint) {
      exchanges.push(init?.body ?? '');
      return Promise.resolve({
        ok: true,
        status: 200,
        json: () => Promise.resolve({ id_token: idToken }),
      });
    }
    if (url === OIDC_ENDPOINTS.google.jwksUri) {
      return Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve({ keys: [jwk] }) });
    }
    return Promise.resolve({ ok: false, status: 404, json: () => Promise.resolve({}) });
  };
  return { fetch, exchanges };
};

const googleAdapter = (fetch: FetchLike): OidcProviderAdapter =>
  new OidcProviderAdapter(
    {
      provider: 'google',
      ...OIDC_ENDPOINTS.google,
      clientId: 'client-sim',
      clientSecretRef: secretReferenceOf('federation/google/client-secret'),
      redirectUri: 'https://mentora.example/entry/federated/google',
      scopes: ['openid'],
    },
    new InMemorySecretResolver({ 'federation/google/client-secret': 'sim-secret' }),
    fetch,
    () => NOW,
  );

describe('PKCE (S256 only)', () => {
  it('mints verifier + challenge; the challenge is the S256 of the verifier; fresh per attempt', () => {
    const first = mintPkce();
    const second = mintPkce();
    expect(first.method).toBe('S256');
    expect(first.challenge).toBe(challengeOf(first.verifier));
    expect(first.verifier).not.toBe(second.verifier);
  });
});

describe('the generic OIDC adapter — one mechanism (Google configuration)', () => {
  it('builds the departure URL with PKCE challenge, state and nonce', () => {
    const url = new URL(googleAdapter(simulatedProvider('').fetch).authorizationUrl('state-1', 'verifier-1', 'nonce-1'));
    expect(url.origin + url.pathname).toBe(OIDC_ENDPOINTS.google.authorizationEndpoint);
    expect(url.searchParams.get('code_challenge')).toBe(challengeOf('verifier-1'));
    expect(url.searchParams.get('code_challenge_method')).toBe('S256');
    expect(url.searchParams.get('state')).toBe('state-1');
    expect(url.searchParams.get('nonce')).toBe('nonce-1');
  });

  it('callback → assertion: exchanges WITH the verifier and the vaulted secret, verifies, STRIPS to {provider, subject}', async () => {
    const simulated = simulatedProvider(signedIdToken(googleClaims({ email: 'p@example.com' })));
    const asserted = await googleAdapter(simulated.fetch).assert('code-1', 'verifier-1', 'nonce-1');
    expect(asserted.ok && asserted.value).toEqual({ provider: 'google', subject: 'subject-42' });
    expect(simulated.exchanges[0]).toContain('code_verifier=verifier-1');
    expect(simulated.exchanges[0]).toContain('client_secret=sim-secret');
    // S-9: nothing but the opaque subject survives — the email died in the adapter.
    expect(JSON.stringify(asserted)).not.toContain('example.com');
  });

  it('refuses flat: wrong issuer, wrong audience, expired, wrong nonce, broken signature', async () => {
    const cases: readonly [string, string][] = [
      [signedIdToken(googleClaims({ iss: 'https://evil.example' })), 'issuer mismatch'],
      [signedIdToken(googleClaims({ aud: 'someone-else' })), 'audience mismatch'],
      [signedIdToken(googleClaims({ exp: NOW - 1 })), 'token is expired'],
      [signedIdToken(googleClaims({ nonce: 'stolen' })), 'nonce mismatch'],
      [`${signedIdToken(googleClaims())}x`, 'signature does not verify'],
    ];
    for (const [token, reason] of cases) {
      const asserted = await googleAdapter(simulatedProvider(token).fetch).assert('c', 'v', 'nonce-1');
      expect(!asserted.ok && asserted.error).toBe(reason);
    }
  });

  it('an unresolved vault reference kills the exchange BEFORE any network act', async () => {
    const adapter = new OidcProviderAdapter(
      {
        provider: 'google',
        ...OIDC_ENDPOINTS.google,
        clientId: 'client-sim',
        clientSecretRef: secretReferenceOf('federation/google/client-secret'),
        redirectUri: 'https://mentora.example/cb',
        scopes: ['openid'],
      },
      new InMemorySecretResolver({}),
      () => Promise.reject(new Error('network must not be touched')),
      () => NOW,
    );
    const asserted = await adapter.assert('c', 'v', 'n');
    expect(!asserted.ok && asserted.error).toContain('client secret unresolved');
  });
});

describe('the GitHub identity sub-adapter — the one isolated difference', () => {
  const githubFetch =
    (user: Record<string, unknown>): FetchLike =>
    (url, init) => {
      if (url === 'https://github.example/token') {
        return Promise.resolve({
          ok: true,
          status: 200,
          json: () => Promise.resolve({ access_token: 'gh-token' }),
        });
      }
      if (url === 'https://github.example/user') {
        expect(init?.headers?.['authorization']).toBe('Bearer gh-token');
        return Promise.resolve({ ok: true, status: 200, json: () => Promise.resolve(user) });
      }
      return Promise.resolve({ ok: false, status: 404, json: () => Promise.resolve({}) });
    };

  const adapter = (fetch: FetchLike): GitHubIdentityAdapter =>
    new GitHubIdentityAdapter(
      {
        authorizationEndpoint: 'https://github.example/authorize',
        tokenEndpoint: 'https://github.example/token',
        userEndpoint: 'https://github.example/user',
        clientId: 'gh-client',
        clientSecretRef: secretReferenceOf('federation/github/client-secret'),
        redirectUri: 'https://mentora.example/cb',
      },
      new InMemorySecretResolver({ 'federation/github/client-secret': 'gh-secret' }),
      fetch,
    );

  it('exchanges then reads the user surface — only the opaque id survives (S-9)', async () => {
    const asserted = await adapter(githubFetch({ id: 583_231, login: 'octocat' })).assert('code');
    expect(asserted.ok && asserted.value).toEqual({ provider: 'github', subject: '583231' });
    expect(JSON.stringify(asserted)).not.toContain('octocat');
  });

  it('a user surface without an id refuses flat', async () => {
    const asserted = await adapter(githubFetch({ login: 'octocat' })).assert('code');
    expect(!asserted.ok && asserted.error).toBe('user surface carries no id');
  });
});

describe('the Apple client-secret signer — a minted ES256 JWT, never a stored string', () => {
  const appleKeys = generateKeyPairSync('ec', { namedCurve: 'P-256' });
  const signer = new AppleClientSecretSigner(
    {
      teamId: 'TEAM123',
      clientId: 'com.mentora.app',
      keyId: 'KEY456',
      privateKeyRef: secretReferenceOf('federation/apple/signing-key'),
      lifetimeSeconds: 600,
    },
    new InMemorySecretResolver({
      'federation/apple/signing-key': appleKeys.privateKey
        .export({ format: 'pem', type: 'pkcs8' })
        .toString(),
    }),
    () => NOW,
  );

  it('mints a JWT Apple would accept: ES256, kid, iss/sub/aud/exp — and it VERIFIES against the public key', async () => {
    const minted = await signer.mint();
    expect(minted.ok).toBe(true);
    if (!minted.ok) return;
    const [header, claims, signature] = minted.value.split('.') as [string, string, string];
    expect(JSON.parse(Buffer.from(header, 'base64url').toString())).toEqual({
      alg: 'ES256',
      kid: 'KEY456',
      typ: 'JWT',
    });
    const parsed = JSON.parse(Buffer.from(claims, 'base64url').toString()) as Record<string, unknown>;
    expect(parsed['iss']).toBe('TEAM123');
    expect(parsed['sub']).toBe('com.mentora.app');
    expect(parsed['aud']).toBe('https://appleid.apple.com');
    expect(parsed['exp']).toBe(NOW + 600);
    expect(
      cryptoVerify(
        'sha256',
        Buffer.from(`${header}.${claims}`),
        { key: appleKeys.publicKey, dsaEncoding: 'ieee-p1363' },
        Buffer.from(signature, 'base64url'),
      ),
    ).toBe(true);
  });

  it('an unresolved key reference refuses flat — nothing signs', async () => {
    const unresolved = new AppleClientSecretSigner(
      {
        teamId: 'T',
        clientId: 'c',
        keyId: 'k',
        privateKeyRef: secretReferenceOf('federation/apple/signing-key'),
        lifetimeSeconds: 60,
      },
      new InMemorySecretResolver({}),
      () => NOW,
    );
    const minted = await unresolved.mint();
    expect(!minted.ok && minted.error).toContain('signing key unresolved');
  });
});

describe('the declared registry (ADR-0004 §2)', () => {
  it('strengths per provider are the RATIFIED ones; the factor name is a reference', () => {
    expect(FEDERATED_STRENGTHS).toEqual({ google: 'elevated', apple: 'elevated', github: 'standard' });
    expect(federatedFactorId('google', 'subject-42')).toBe('google:subject-42');
  });

  it('the ES256 road of verifyIdToken also stands (Apple id_tokens)', () => {
    const keys = generateKeyPairSync('ec', { namedCurve: 'P-256' });
    const header = Buffer.from(JSON.stringify({ alg: 'ES256', kid: 'apple-1' })).toString('base64url');
    const payload = Buffer.from(
      JSON.stringify({ iss: 'https://appleid.apple.com', aud: 'com.mentora.app', sub: 's-9', exp: NOW + 60 }),
    ).toString('base64url');
    const signature = createSign('SHA256');
    signature.update(`${header}.${payload}`);
    const jws = `${header}.${payload}.${signature
      .sign({ key: keys.privateKey, dsaEncoding: 'ieee-p1363' })
      .toString('base64url')}`;
    const verified = verifyIdToken(
      jws,
      [{ ...keys.publicKey.export({ format: 'jwk' }), kid: 'apple-1', kty: 'EC' }],
      { issuer: 'https://appleid.apple.com', audience: 'com.mentora.app', nowSeconds: NOW },
    );
    expect(verified.ok && verified.value.subject).toBe('s-9');
  });
});
