import { IdentityIdentifierBlankException } from '../errors/identity-exceptions.js';

/**
 * FactorKind — the NATURE of a proof factor (canon ch.04: VO of the
 * Credential). The canon ratifies the VO without enumerating its values: the
 * concrete catalog arrives WITH the mechanisms (password — Story #96;
 * federated providers — ADR-0004 once ratified). Deliberately a guarded
 * opaque value, NOT an invented enum: the dictionary owns vocabulary, and
 * this module refuses to complete the corpus (house law).
 */

declare const factorKindBrand: unique symbol;
export type FactorKind = string & { readonly [factorKindBrand]: true };

export const factorKindOf = (value: string): FactorKind => {
  if (value.trim().length === 0) {
    throw new IdentityIdentifierBlankException('FactorKind must not be blank');
  }
  return value.trim().toLowerCase() as FactorKind;
};
