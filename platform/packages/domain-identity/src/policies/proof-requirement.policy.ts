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
  /**
   * MFA (Story #111/#113): the PRODUCT-declared composition table — which
   * SETS of verified strengths compose, and into what. No canon strength
   * algebra exists, so none is invented: composition is explicit product
   * configuration, judged HERE ("la ProofRequirementPolicy décide, pas
   * l'adapter" — ADR-0004), order-insensitive.
   */
  readonly compositions?: readonly { readonly of: readonly string[]; readonly yields: string }[];
}

const combinationKey = (strengths: readonly string[]): string =>
  strengths.map((value) => value.toLowerCase()).sort().join('+');

export class ProofRequirementPolicy {
  private readonly accepted: ReadonlySet<string>;
  private readonly composed: ReadonlyMap<string, string>;

  constructor(configuration: ProofRequirementPolicyParams) {
    this.accepted = new Set(configuration.acceptedStrengths.map((value) => value.toLowerCase()));
    this.composed = new Map(
      (configuration.compositions ?? []).map((entry) => [
        combinationKey(entry.of),
        entry.yields.toLowerCase(),
      ]),
    );
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

  /**
   * The judged strength of a SET of verified factors (MFA, Story #113):
   * one factor presents its own strength; several compose ONLY through the
   * declared product table — an undeclared combination refuses (fail
   * closed), it never guesses an ordering.
   */
  compose(verified: readonly ProofStrength[]): Result<ProofStrength, SessionRefusal> {
    if (verified.length === 1) {
      return ok(verified[0] as ProofStrength);
    }
    if (verified.length === 0) {
      return err(sessionRefusal('ProofUnavailable', 'No verified proof was presented'));
    }
    const yields = this.composed.get(combinationKey(verified));
    if (yields === undefined) {
      return err(
        sessionRefusal(
          'ProofUnavailable',
          'This combination of proofs composes into nothing the product has declared',
        ),
      );
    }
    return ok(yields as ProofStrength);
  }
}
