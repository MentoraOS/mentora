import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';
import type { SecretReference, SecretResolver } from '@mentora/runtime-security';

import type { FederatedAssertion, FetchLike } from '../oidc/oidc-provider.js';

/**
 * GitHubIdentityAdapter — the ONE isolated difference (ADR-0004 §1):
 * GitHub is OAuth2 without OIDC, so identity comes from its user surface
 * instead of an id_token. The difference DIES in this file: what exits is
 * the same FederatedAssertion as the OIDC road. Only the opaque numeric
 * id is kept (S-9) — login, profile, email are read past and forgotten.
 */

export interface GitHubProviderConfig {
  readonly authorizationEndpoint: string;
  readonly tokenEndpoint: string;
  readonly userEndpoint: string;
  readonly clientId: string;
  readonly clientSecretRef: SecretReference;
  readonly redirectUri: string;
}

export class GitHubIdentityAdapter {
  constructor(
    private readonly config: GitHubProviderConfig,
    private readonly secrets: SecretResolver,
    private readonly fetchFn: FetchLike,
  ) {}

  authorizationUrl(state: string): string {
    const url = new URL(this.config.authorizationEndpoint);
    url.searchParams.set('client_id', this.config.clientId);
    url.searchParams.set('redirect_uri', this.config.redirectUri);
    url.searchParams.set('scope', 'read:user');
    url.searchParams.set('state', state);
    return url.toString();
  }

  async assert(code: string): Promise<Result<FederatedAssertion, string>> {
    const secret = await this.secrets.resolve(this.config.clientSecretRef);
    if (!secret.ok) {
      return err(`client secret unresolved: ${secret.error.reference}`);
    }
    const exchanged = await this.fetchFn(this.config.tokenEndpoint, {
      method: 'POST',
      headers: { accept: 'application/json', 'content-type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        client_id: this.config.clientId,
        client_secret: secret.value,
        code,
        redirect_uri: this.config.redirectUri,
      }).toString(),
    });
    if (!exchanged.ok) {
      return err(`token exchange refused (${String(exchanged.status)})`);
    }
    const body = (await exchanged.json()) as Record<string, unknown>;
    const accessToken = body['access_token'];
    if (typeof accessToken !== 'string') {
      return err('no access_token in the exchange');
    }
    const surface = await this.fetchFn(this.config.userEndpoint, {
      headers: { authorization: `Bearer ${accessToken}`, accept: 'application/vnd.github+json' },
    });
    if (!surface.ok) {
      return err(`user surface refused (${String(surface.status)})`);
    }
    const identity = (await surface.json()) as Record<string, unknown>;
    const id = identity['id'];
    if (typeof id !== 'number') {
      return err('user surface carries no id');
    }
    return ok({ provider: 'github', subject: String(id) });
  }
}
