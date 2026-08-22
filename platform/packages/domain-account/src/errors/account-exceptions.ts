/**
 * Exceptions of the Account domain — the caller-defect door (F3.1, A-7): a
 * malformed call is the CALLER's bug and propagates raw; it is never a
 * Refusal, never retried.
 */

export class AccountDomainException extends Error {
  constructor(message: string) {
    super(message);
    this.name = new.target.name;
  }
}

/** A blank identifier or value is a malformed call, not a business outcome. */
export class AccountIdentifierBlankException extends AccountDomainException {}

/** A retained Account photograph that no longer maps to a lawful state (PERSIST.CORRUPTION). */
export class AccountSnapshotCorruptException extends AccountDomainException {}

/** A retained AvailabilityFrame photograph that no longer maps to a lawful state. */
export class AvailabilityFrameSnapshotCorruptException extends AccountDomainException {}
