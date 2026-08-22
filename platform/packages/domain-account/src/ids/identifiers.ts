import type {
  CommandId,
  DeviceId,
  PersonId,
  SubscriptionId,
  SupportRequestId,
} from '@mentora/contracts-account';

import { AccountIdentifierBlankException } from '../errors/account-exceptions.js';

/**
 * Identifiers of the Account domain. The TYPES are owned by the published
 * language (@mentora/contracts-account — single definition); the domain adds
 * its construction GUARDS (a blank id is a malformed call — the Exception
 * door, F3.1). The Account's identity IS the PersonId (RFC-003 P1).
 */

export type {
  CommandId,
  DeviceId,
  PersonId,
  SubscriptionId,
  SupportRequestId,
} from '@mentora/contracts-account';

const guarded = (value: string, label: string): string => {
  if (value.trim().length === 0) {
    throw new AccountIdentifierBlankException(`${label} must not be blank`);
  }
  return value;
};

export const personIdOf = (value: string): PersonId => guarded(value, 'PersonId') as PersonId;
export const deviceIdOf = (value: string): DeviceId => guarded(value, 'DeviceId') as DeviceId;
export const commandIdOf = (value: string): CommandId => guarded(value, 'CommandId') as CommandId;
export const subscriptionIdOf = (value: string): SubscriptionId =>
  guarded(value, 'SubscriptionId') as SubscriptionId;
export const supportRequestIdOf = (value: string): SupportRequestId =>
  guarded(value, 'SupportRequestId') as SupportRequestId;
