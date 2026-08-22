import { AccountIdentifierBlankException } from '../errors/account-exceptions.js';

/**
 * VerificationState — the platform's verification of the holder (canon
 * F3.2-B: Account "NON : Titulaire + plateforme (vérification)"). RECORDED
 * CANON GAP (RFC-003 P6, ratified): no command of the catalogue changes it —
 * it keeps its registration value until a Titre VII names that command.
 * Guarded opaque value, never an invented enum.
 */

declare const verificationStateBrand: unique symbol;
export type VerificationState = string & { readonly [verificationStateBrand]: true };

export const verificationStateOf = (value: string): VerificationState => {
  if (value.trim().length === 0) {
    throw new AccountIdentifierBlankException('VerificationState must not be blank');
  }
  return value.trim().toLowerCase() as VerificationState;
};
