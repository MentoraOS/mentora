import type { Brand, Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { AgreementContractViolation } from '../errors/agreement-error-contract.js';

/**
 * The PUBLIC identifiers of the Agreement language (F3.1.99 §4: opaque,
 * stable). Declared HERE (the published language owns its types — ADR-0003:
 * contracts-<context>); the domain package imports these types and adds its
 * own construction guards. CommandId (act identity) is transversal and lives
 * in @mentora/contracts — re-exported below, never redeclared.
 *
 * SIGNALED: OfferId / ClientId / ExpertId are cited here because the Agreement
 * language speaks them; their DEFINITIVE home (contracts of Professional
 * Identity / a shared actor-contracts package) is a Titre VII decision once
 * those packages exist — nothing invented, ownership flagged.
 */

export type AgreementId = Brand<string, 'AgreementId'>;
export type OfferId = Brand<string, 'OfferId'>;
export type ClientId = Brand<string, 'ClientId'>;
export type ExpertId = Brand<string, 'ExpertId'>;

export type { CommandId } from '@mentora/contracts';

const validId = <T extends string>(
  value: string,
  field: string,
): Result<Brand<string, T>, AgreementContractViolation> =>
  value.trim().length > 0
    ? ok(value as Brand<string, T>)
    : err({ code: 'CONTRACT.FIELD_BLANK', field, message: `${field} must not be blank` });

/** Contract-level validators (structure only — the domain adds its own doors). */
export const validAgreementId = (value: string): Result<AgreementId, AgreementContractViolation> =>
  validId<'AgreementId'>(value, 'agreementId');
export const validOfferId = (value: string): Result<OfferId, AgreementContractViolation> =>
  validId<'OfferId'>(value, 'offerId');
export const validClientId = (value: string): Result<ClientId, AgreementContractViolation> =>
  validId<'ClientId'>(value, 'clientId');
export const validExpertId = (value: string): Result<ExpertId, AgreementContractViolation> =>
  validId<'ExpertId'>(value, 'expertId');
