import { createPrivateKey, sign as cryptoSign } from 'node:crypto';

import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';
import type { SecretReference, SecretResolver } from '@mentora/runtime-security';

/**
 * AppleClientSecretSigner — Apple's demand (ADR-0004 §5, delivered LAST
 * for this exact reason): the "client secret" is not a stored string but
 * an ES256-signed JWT minted from a vaulted EC private key, short-lived
 * and rotated by re-minting. The key never leaves the resolver's hand
 * (I-8); what exits is the signed assertion string.
 */

export interface AppleSignerConfig {
  readonly teamId: string;
  readonly clientId: string;
  readonly keyId: string;
  readonly privateKeyRef: SecretReference;
  /** Seconds of validity per minted secret (Apple caps at 6 months; keep short). */
  readonly lifetimeSeconds: number;
}

const base64urlJson = (value: Record<string, unknown>): string =>
  Buffer.from(JSON.stringify(value)).toString('base64url');

export class AppleClientSecretSigner {
  constructor(
    private readonly config: AppleSignerConfig,
    private readonly secrets: SecretResolver,
    private readonly nowSeconds: () => number,
  ) {}

  async mint(): Promise<Result<string, string>> {
    const pem = await this.secrets.resolve(this.config.privateKeyRef);
    if (!pem.ok) {
      return err(`signing key unresolved: ${pem.error.reference}`);
    }
    const now = this.nowSeconds();
    const header = base64urlJson({ alg: 'ES256', kid: this.config.keyId, typ: 'JWT' });
    const claims = base64urlJson({
      iss: this.config.teamId,
      iat: now,
      exp: now + this.config.lifetimeSeconds,
      aud: 'https://appleid.apple.com',
      sub: this.config.clientId,
    });
    try {
      const key = createPrivateKey(pem.value);
      const signature = cryptoSign(
        'sha256',
        Buffer.from(`${header}.${claims}`),
        { key, dsaEncoding: 'ieee-p1363' },
      ).toString('base64url');
      return ok(`${header}.${claims}.${signature}`);
    } catch {
      return err('the vaulted key refuses to sign');
    }
  }
}
