import { IdentityIdentifierBlankException } from '../errors/identity-exceptions.js';

/**
 * ProofStrength — the judged WEIGHT of a proof (canon ch.04: VO of the
 * Credential). Like FactorKind, ratified as a concept without a value
 * catalog: the ProofRequirementPolicy (Session side, Story #34) is the judge
 * that consumes it; providers propose their strength via ADR-0004. Guarded
 * opaque value — never an invented enum.
 */

declare const proofStrengthBrand: unique symbol;
export type ProofStrength = string & { readonly [proofStrengthBrand]: true };

export const proofStrengthOf = (value: string): ProofStrength => {
  if (value.trim().length === 0) {
    throw new IdentityIdentifierBlankException('ProofStrength must not be blank');
  }
  return value.trim().toLowerCase() as ProofStrength;
};
