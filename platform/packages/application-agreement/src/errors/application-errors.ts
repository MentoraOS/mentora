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
 *
 * Since Lot 1C-2 the three channels are DEFINED by the generic pipeline
 * (`@mentora/application-kernel`); this module keeps the 1C-1 public names as
 * Agreement-typed specializations of the single canonical definitions.
 */

import { SequenceExecutionException, SequenceReceptionException, sequenceFailure } from '@mentora/application-kernel';
import type { SequenceFailure } from '@mentora/application-kernel';
import type { AgreementContractViolation } from '@mentora/contracts-agreement';

/** Base of every application exception. Coded, never generic. */
export abstract class AgreementApplicationException extends SequenceExecutionException {}

/** Pas 1: the payload does not form a Command of the dictionary — end. */
export class AgreementReceptionException extends SequenceReceptionException {
  override readonly code: string = 'APPLICATION.RECEPTION';

  constructor(override readonly violations: readonly AgreementContractViolation[]) {
    super(violations);
  }
}

/** The third channel: a technical incapacity, retryable, carried as a value. */
export type AgreementApplicationFailure = SequenceFailure;

export const applicationFailure = (
  code: string,
  message: string,
  retryable = true,
): AgreementApplicationFailure => sequenceFailure(code, message, retryable);
