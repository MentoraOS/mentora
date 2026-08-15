import type { Brand } from '@mentora/kernel';

/**
 * ActorRef — the INJECTED reference to the authenticated actor (F4.1 A-6:
 * identity is injected at pas 2, never ambient; F5.4: for persons, the actor
 * is the ActorRef established by the session proof through the I&A ACL).
 * Transversal: every domain's Sequence receives one — owned by the technical
 * core so no domain redeclares it.
 *
 * SIGNALED: today an opaque branded reference; the refined shape
 * (person/machine discrimination — F5.4 two vestibules) is a Titre VII
 * decision when the I&A contracts exist. Nothing invented beyond the ratified
 * word.
 */
export type ActorRef = Brand<string, 'ActorRef'>;
