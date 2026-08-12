import type { Id } from '@mentora/kernel';

import { AgreementIdentifierBlankException } from '../errors/agreement-exceptions.js';

/**
 * Opaque, stable identifiers (F3.1.99 §4: an Identifier is opaque, stable,
 * never recycled, never derived from mutable data, never meaningful). Foreign
 * truths are referenced by Identifier ONLY (F3.1: "il référence toute autre
 * vérité par Identifier seul, jamais par objet").
 *
 * ClientId / ExpertId derive from the ratified Actor Dictionary (F2.5 §7:
 * Client, Expert) + the `<Truth>Id` naming law; ExpertId is used verbatim by
 * R2 (F3.2-C: FundsLedger identity = ExpertId). OfferId is cited by
 * AgreementConditions (F3.2-A). CommandId is the ratified "identité d'acte"
 * (F4.1 §3: idempotence by act identity).
 */

export type AgreementId = Id<'AgreementId'>;
export type OfferId = Id<'OfferId'>;
export type ClientId = Id<'ClientId'>;
export type ExpertId = Id<'ExpertId'>;
export type CommandId = Id<'CommandId'>;

const brandId = <T extends string>(value: string, label: string): Id<T> => {
  if (value.trim().length === 0) {
    throw new AgreementIdentifierBlankException(`${label} must not be blank`);
  }
  return value as Id<T>;
};

export const agreementIdOf = (value: string): AgreementId => brandId(value, 'AgreementId');
export const offerIdOf = (value: string): OfferId => brandId(value, 'OfferId');
export const clientIdOf = (value: string): ClientId => brandId(value, 'ClientId');
export const expertIdOf = (value: string): ExpertId => brandId(value, 'ExpertId');
export const commandIdOf = (value: string): CommandId => brandId(value, 'CommandId');
