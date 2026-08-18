import type { Instant } from '@mentora/kernel';

import type { FactorId } from '../ids/identifiers.js';
import type { FactorKind } from '../value-objects/factor-kind.js';
import type { ProofStrength } from '../value-objects/proof-strength.js';

/**
 * Factor — the Entity inside the Credential (canon ch.04: "Entities: Factor
 * — même acteur, aucune référence entrante").
 *
 * THE INVARIANT OF THE HOUSE, enforced by construction: a Factor carries the
 * NATURE and WEIGHT of a proof — NEVER its material. There is no field for a
 * hash, a token, a code or any secret, and there never will be one here:
 * "aucun secret dans l'unité, jamais — la matière des facteurs ne quitte pas
 * l'unité" means the material lives with the mechanism adapters under the
 * vault discipline (I-8), outside the domain.
 */
export interface Factor {
  readonly factorId: FactorId;
  readonly kind: FactorKind;
  readonly strength: ProofStrength;
  /** Exactly ONE principal factor per Credential — the R-A axis (person × principal factor). */
  readonly principal: boolean;
  readonly establishedAt: Instant;
}
