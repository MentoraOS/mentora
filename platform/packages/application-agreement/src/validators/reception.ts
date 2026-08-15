
import type {
  AgreementCommandContract,
  AgreementContractViolation,
  AgreementStateQuery,
} from '@mentora/contracts-agreement';
import {
  validateAgreementCommand,
  validateAgreementQuery,
} from '@mentora/contracts-agreement';
import type { Result } from '@mentora/kernel';

/**
 * Pas 1 — Reception (F4.1 §2): "le payload devient une Command typée du
 * dictionnaire ; malformé → Exception, fin." The application ADDS NOTHING to
 * the published language's validation — it delegates to the contracts package
 * (the single definition of the wire, no duplication). The stage of lot 1C-2
 * converts a violation list into the Exception channel
 * (AgreementReceptionException).
 */

export const receiveAgreementCommand = (
  payload: unknown,
): Result<AgreementCommandContract, readonly AgreementContractViolation[]> =>
  validateAgreementCommand(payload);

export const receiveAgreementQuery = (
  payload: unknown,
): Result<AgreementStateQuery, readonly AgreementContractViolation[]> =>
  validateAgreementQuery(payload);
