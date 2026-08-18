/**
 * Exceptions of the Identity & Access domain — the caller-defect door (F3.1,
 * A-7): a malformed call is the CALLER's bug and propagates raw; it is never
 * a Refusal, never retried.
 */

export class IdentityDomainException extends Error {
  constructor(message: string) {
    super(message);
    this.name = new.target.name;
  }
}

/** A blank identifier is a malformed call, not a business outcome. */
export class IdentityIdentifierBlankException extends IdentityDomainException {}

/** A retained photograph that no longer maps to a lawful state (PERSIST.CORRUPTION). */
export class CredentialSnapshotCorruptException extends IdentityDomainException {}

/** A retained session photograph that no longer maps to a lawful state. */
export class SessionSnapshotCorruptException extends IdentityDomainException {}
