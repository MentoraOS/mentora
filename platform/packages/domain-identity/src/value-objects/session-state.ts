import type { Instant } from '@mentora/kernel';

/**
 * The frozen machine of the Session (canon ch.04): `Active → Ended | Revoked`
 * — TWO DISTINCT terminals: Ended is the person's own act ("déconnecter cet
 * appareil"), Revoked is suffered (the guardian's act, or the cascade of a
 * credential revocation). Both terminal (R-B).
 */

export type SessionState =
  | { readonly kind: 'Active'; readonly openedAt: Instant }
  | { readonly kind: 'Ended'; readonly endedAt: Instant }
  | { readonly kind: 'Revoked'; readonly revokedAt: Instant; readonly motive: string };

export const isTerminalSessionState = (state: SessionState): boolean => state.kind !== 'Active';
