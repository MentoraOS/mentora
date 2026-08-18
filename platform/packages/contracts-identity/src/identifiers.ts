/**
 * Identifiers of the Identity & Access published language (dictionary F2.5:
 * Credential, Factor — Session is the domain's own reserved word). Branded
 * types: single definition, every package speaks this seam. PersonId is the
 * OPAQUE reference the ACL of the Account hands over — the proof↔person link
 * itself lives in that ACL, never inside the Credential (canon ch.04).
 */

declare const credentialIdBrand: unique symbol;
declare const factorIdBrand: unique symbol;
declare const personIdBrand: unique symbol;
declare const sessionIdBrand: unique symbol;

export type CredentialId = string & { readonly [credentialIdBrand]: true };
export type FactorId = string & { readonly [factorIdBrand]: true };
export type PersonId = string & { readonly [personIdBrand]: true };
/** Session — mot réservé AU domaine I&A (dictionnaire F2.5) : légitime ici, nulle part ailleurs. */
export type SessionId = string & { readonly [sessionIdBrand]: true };

export type { CommandId } from '@mentora/contracts';
