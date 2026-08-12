/**
 * Domain exceptions — the FOURTH refusal door only (F3.1: "l'Exception refuse
 * l'appel malformé"). A business refusal is NEVER an exception: it is a
 * Decision value (see decisions/agreement-refusal.ts). Naming law:
 * `<Truth><Reason>Exception` (F3.1 Naming Constitution).
 */

/** Base of every Agreement domain exception. Never generic, always coded. */
export abstract class AgreementDomainException extends Error {
  abstract readonly code: string;

  constructor(message: string) {
    super(message);
    this.name = new.target.name;
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

/** A blank/malformed identifier is a malformed call, not a business refusal. */
export class AgreementIdentifierBlankException extends AgreementDomainException {
  readonly code = 'AGREEMENT.IDENTIFIER_BLANK';
}

/** A snapshot that cannot be reconstituted is corrupt storage, not business. */
export class AgreementSnapshotCorruptException extends AgreementDomainException {
  readonly code = 'AGREEMENT.SNAPSHOT_CORRUPT';
}
