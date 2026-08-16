import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { SecretReference } from './secret-reference.js';

/**
 * SecretResolver — the vestibule surface: reference in, value out, ONCE, at
 * assembly ("le coffre garde — il ne décide jamais", F5.4 §3; "secret
 * manquant" kills the boot, F4.4 §6 — fail closed). The resolved value must
 * never be logged, never cached, never retained (F4.4 §9): the Root hands
 * it to the resource that needs it and forgets it. Real resolvers are vault
 * adapters; the in-memory one serves specs and local development.
 */

export interface SecretViolation {
  readonly code: 'SECRET.UNKNOWN';
  readonly reference: string;
}

export interface SecretResolver {
  resolve(reference: SecretReference): Promise<Result<string, SecretViolation>>;
}

export class InMemorySecretResolver implements SecretResolver {
  constructor(private readonly entries: Readonly<Record<string, string>>) {}

  resolve(reference: SecretReference): Promise<Result<string, SecretViolation>> {
    const value = this.entries[reference];
    return Promise.resolve(
      value === undefined ? err({ code: 'SECRET.UNKNOWN', reference }) : ok(value),
    );
  }
}
