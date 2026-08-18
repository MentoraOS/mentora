import type { CredentialEstablished, CredentialRevoked } from '../events/credential-events.js';

/**
 * The closed union of the Credential's facts (precedent: agreement-domain-event).
 * Lives in aggregate/ — the events/ directory is reserved to the facts
 * themselves (<Truth><PastParticiple>, MENTORA0003).
 */
export type CredentialDomainEvent = CredentialEstablished | CredentialRevoked;
