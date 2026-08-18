import type { Instant } from '@mentora/kernel';

/**
 * The frozen machine of the Credential (canon ch.04): `Active → Revoked`,
 * Revoked TERMINAL — re-entering is a NEW Credential (R-B). Two states, one
 * transition, zero ambiguity.
 */

export type CredentialState =
  | { readonly kind: 'Active'; readonly establishedAt: Instant }
  | { readonly kind: 'Revoked'; readonly revokedAt: Instant; readonly motive: string };

export const isTerminalCredentialState = (state: CredentialState): boolean =>
  state.kind === 'Revoked';
