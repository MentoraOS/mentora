import type {
  CredentialEstablished,
  CredentialRevoked,
} from '../events/identity-event-contracts.js';

/**
 * The closed union of the Identity wire facts (precedent: contracts-agreement
 * wire/event-union). Lives OUTSIDE events/ — that directory is reserved to
 * the facts themselves (<Truth><PastParticiple>, MENTORA0003).
 */
export type IdentityEventContract = CredentialEstablished | CredentialRevoked;

export const IDENTITY_EVENT_TYPES = ['CredentialEstablished', 'CredentialRevoked'] as const;
