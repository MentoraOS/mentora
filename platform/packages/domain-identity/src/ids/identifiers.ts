import type { CommandId, CredentialId, FactorId, PersonId, SessionId } from '@mentora/contracts-identity';

import { IdentityIdentifierBlankException } from '../errors/identity-exceptions.js';

/**
 * Identifiers of the Identity & Access domain. The TYPES are owned by the
 * published language (@mentora/contracts-identity — single definition); the
 * domain adds its construction GUARDS (a blank id is a malformed call — the
 * Exception door, F3.1). PersonId stays an OPAQUE reference: the proof↔person
 * link lives in the ACL of the Account, never here (canon ch.04).
 */

export type { CredentialId, FactorId, PersonId, SessionId, CommandId } from '@mentora/contracts-identity';

const guarded = (value: string, label: string): string => {
  if (value.trim().length === 0) {
    throw new IdentityIdentifierBlankException(`${label} must not be blank`);
  }
  return value;
};

export const credentialIdOf = (value: string): CredentialId =>
  guarded(value, 'CredentialId') as CredentialId;
export const factorIdOf = (value: string): FactorId => guarded(value, 'FactorId') as FactorId;
export const personIdOf = (value: string): PersonId => guarded(value, 'PersonId') as PersonId;
export const commandIdOf = (value: string): CommandId => guarded(value, 'CommandId') as CommandId;

export const sessionIdOf = (value: string): SessionId => guarded(value, 'SessionId') as SessionId;
