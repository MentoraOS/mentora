import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';
import type { SecretReference, SecretResolver } from '@mentora/runtime-security';

import type { JsonWebKey } from './id-token.js';
import { verifyIdToken } from './id-token.js';
import { challengeOf } from './pkce.js';

/**
 * OidcProviderAdapter — ONE mechanism, three configurations (ADR-0004 §1):
 * the generic OIDC Authorization Code + PKCE adapter over the raw
 * protocol. fetch is an injected seam so specs run against SIMULATED
 * providers (never the real ones in CI — ADR-0004 conséquences); the
 * client secret stays at the vault, resolved BY REFERENCE at the exchange
 * and forgotten (I-8). Provider types die in this file (I-7): what exits
 * is a FederatedAssertion — provider name + opaque subject, nothing else
 * (S-9: no profile, no email, no token retained).
 */

export type FetchLike = (url: string, init?: {
  readonly method?: string;
  readonly headers?: Readonly<Record<string, string>>;
  readonly body?: string;
}) => Promise<{
  readonly ok: boolean;
  readonly status: number;
  json(): Promise<unknown>;
}>;

export interface OidcProviderConfig {
  readonly provider: string;
  readonly issuer: string;
  readonly authorizationEndpoint: string;
  readonly tokenEndpoint: string;
  readonly jwksUri: string;
  readonly clientId: string;
  readonly clientSecretRef: SecretReference;
  readonly redirectUri: string;
  readonly scopes: readonly string[];
}

/** What survives the adapter: the provider's name and the OPAQUE subject. */
export interface FederatedAssertion {
  readonly provider: string;
  readonly subject: string;
}

export class OidcProviderAdapter {
  constructor(
    private readonly config: OidcProviderConfig,
    private readonly secrets: SecretResolver,
    private readonly fetchFn: FetchLike,
    private readonly nowSeconds: () => number,
  ) {}

  /** The user-agent's departure door — state and PKCE minted by the caller per attempt. */
  authorizationUrl(state: string, pkceVerifier: string, nonce: string): string {
    const url = new URL(this.config.authorizationEndpoint);
    url.searchParams.set('response_type', 'code');
    url.searchParams.set('client_id', this.config.clientId);
    url.searchParams.set('redirect_uri', this.config.redirectUri);
    url.searchParams.set('scope', this.config.scopes.join(' '));
    url.searchParams.set('state', state);
    url.searchParams.set('nonce', nonce);
    url.searchParams.set('code_challenge', challengeOf(pkceVerifier));
    url.searchParams.set('code_challenge_method', 'S256');
    return url.toString();
  }

  /** Callback → assertion: exchange, verify, strip. Every rejection is a flat motivated value. */
  async assert(
    code: string,
    pkceVerifier: string,
    nonce: string,
  ): Promise<Result<FederatedAssertion, string>> {
    const secret = await this.secrets.resolve(this.config.clientSecretRef);
    if (!secret.ok) {
      return err(`client secret unresolved: ${secret.error.reference}`);
    }
    const exchanged = await this.fetchFn(this.config.tokenEndpoint, {
      method: 'POST',
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        redirect_uri: this.config.redirectUri,
        client_id: this.config.clientId,
        client_secret: secret.value,
        code_verifier: pkceVerifier,
      }).toString(),
    });
    if (!exchanged.ok) {
      return err(`token exchange refused (${String(exchanged.status)})`);
    }
    const body = (await exchanged.json()) as Record<string, unknown>;
    const idToken = body['id_token'];
    if (typeof idToken !== 'string') {
      return err('no id_token in the exchange');
    }
    const jwksResponse = await this.fetchFn(this.config.jwksUri);
    if (!jwksResponse.ok) {
      return err('JWKS unavailable');
    }
    const jwks = (await jwksResponse.json()) as { keys?: readonly JsonWebKey[] };
    const verified = verifyIdToken(idToken, jwks.keys ?? [], {
      issuer: this.config.issuer,
      audience: this.config.clientId,
      nowSeconds: this.nowSeconds(),
      nonce,
    });
    if (!verified.ok) {
      return err(verified.error);
    }
    return ok({ provider: this.config.provider, subject: verified.value.subject });
  }
}
