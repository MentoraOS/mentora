import type { Brand } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';

/**
 * SecretReference — THE type discipline of F4.4 §9, verbatim: "Un secret n'a
 * qu'un lieu, et tous les autres lieux n'en connaissent que LE NOM. Chargés
 * par le Root par références … Le domaine ne les voit JAMAIS (il n'a même
 * pas de type pour les contenir). Jamais dans un log, jamais dans un Domain
 * Event, jamais mis en cache." (I-8). This brand IS the name — a reference
 * travels; the value exists only at the vestibule, transiently.
 */
export type SecretReference = Brand<string, 'SecretReference'>;

export const secretReferenceOf = (name: string): SecretReference => {
  invariant(name.trim() !== '', 'a secret reference is a non-blank NAME');
  return name as SecretReference;
};
