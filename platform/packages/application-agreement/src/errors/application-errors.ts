/**
 * The application layer's error discipline — A-7, verbatim: "le refus est une
 * valeur transportée ; l'Exception un défaut d'appelant ; la Failure un
 * réessai — trois canaux, jamais mélangés."
 *
 * - REFUSAL: never declared here — it is the domain's Decision value
 *   (AgreementRefusal), transported untouched.
 * - EXCEPTION: a malformed call (pas 1: "malformé → Exception, fin").
 * - FAILURE: a technical incapacity, retryable, no business meaning
 *   (F3.1.14) — a VALUE, so retries stay mechanical.
 */

import type { AgreementContractViolation } from '@mentora/contracts-agreement';

/** Base of every application exception. Coded, never generic. */
export abstract class AgreementApplicationException extends Error {
  abstract readonly code: string;

  constructor(message: string) {
    super(message);
    this.name = new.target.name;
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

/** Pas 1: the payload does not form a Command of the dictionary — end. */
export class AgreementReceptionException extends AgreementApplicationException {
  readonly code = 'APPLICATION.RECEPTION';

  constructor(readonly violations: readonly AgreementContractViolation[]) {
    super(
      `Payload is not a valid Agreement command: ${violations
        .map((violation) => `${violation.field} (${violation.code})`)
        .join(', ')}`,
    );
  }
}

/** The third channel: a technical incapacity, retryable, carried as a value. */
export interface AgreementApplicationFailure {
  readonly kind: 'Failure';
  readonly code: string;
  readonly message: string;
  readonly retryable: boolean;
}

export const applicationFailure = (
  code: string,
  message: string,
  retryable = true,
): AgreementApplicationFailure => ({ kind: 'Failure', code, message, retryable });
