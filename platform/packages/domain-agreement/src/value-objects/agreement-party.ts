import type { ClientId, ExpertId } from '../ids/identifiers.js';

/**
 * The two refusing actors of the Agreement (F3.2-A: "deux acteurs refusants
 * (Client, Expert) sur la MÊME vérité — licite pour une racine").
 */
export type AgreementParty =
  | { readonly role: 'Client'; readonly clientId: ClientId }
  | { readonly role: 'Expert'; readonly expertId: ExpertId };
