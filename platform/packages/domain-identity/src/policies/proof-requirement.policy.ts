import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { SessionRefusal } from '../decisions/session-refusal.js';
import { sessionRefusal } from '../decisions/session-refusal.js';
import type { ProofStrength } from '../value-objects/proof-strength.js';

/**
 * ProofRequirementPolicy — the RATIFIED policy of the Session (canon ch.04,
 * policies catalog): what proof suffices to open a session. PRODUCT
 * configuration (governed, journaled changes — F4.4): the accepted
 * strengths are an explicit ALLOWLIST — no invented ordering between
 * opaque strengths; membership is the judgment.
 */
/** The PRODUCT parameters (I-5) — published so the Root injects them (precedent: ReschedulePolicyParams). */
export interface ProofRequirementPolicyParams {
  readonly acceptedStrengths: readonly string[];
}

export class ProofRequirementPolicy {
  private readonly accepted: ReadonlySet<string>;

  constructor(configuration: ProofRequirementPolicyParams) {
    this.accepted = new Set(configuration.acceptedStrengths.map((value) => value.toLowerCase()));
  }

  judge(presented: ProofStrength): Result<void, SessionRefusal> {
    if (this.accepted.has(presented)) {
      return ok(undefined);
    }
    return err(
      sessionRefusal(
        'ProofUnavailable',
        `The presented proof strength '${presented}' does not satisfy the requirement`,
      ),
    );
  }
}
