import type { Instant } from '@mentora/kernel';

/**
 * The frozen machine of the Account (catalogue §8 n°5): `Active → Closed`,
 * terminal. "Fermé ⇒ plus rien ne change" (canon) ; R-B: coming back is a
 * NEW registered person — no reopening verb exists, by construction.
 */
export type AccountState =
  | { readonly kind: 'Active'; readonly registeredAt: Instant }
  | { readonly kind: 'Closed'; readonly closedAt: Instant; readonly motive: string };
