import type { AgreementId, ClientId, CommandId, ExpertId, OfferId } from '@mentora/contracts-agreement';

import { AgreementIdentifierBlankException } from '../errors/agreement-exceptions.js';

/**
 * Identifiers of the Agreement domain. The TYPES are owned by the published
 * language (@mentora/contracts-agreement — the seam every package speaks;
 * single definition, no duplication) and re-exported here; the domain adds its
 * own construction GUARDS (a blank id is a malformed call — the Exception
 * door, F3.1). CommandId (act identity, F4.1 §3) comes from the technical
 * core through the same seam.
 */

export type { AgreementId, OfferId, ClientId, ExpertId, CommandId } from '@mentora/contracts-agreement';

const guarded = (value: string, label: string): string => {
  if (value.trim().length === 0) {
    throw new AgreementIdentifierBlankException(`${label} must not be blank`);
  }
  return value;
};

export const agreementIdOf = (value: string): AgreementId =>
  guarded(value, 'AgreementId') as AgreementId;
export const offerIdOf = (value: string): OfferId => guarded(value, 'OfferId') as OfferId;
export const clientIdOf = (value: string): ClientId => guarded(value, 'ClientId') as ClientId;
export const expertIdOf = (value: string): ExpertId => guarded(value, 'ExpertId') as ExpertId;
export const commandIdOf = (value: string): CommandId => guarded(value, 'CommandId') as CommandId;
