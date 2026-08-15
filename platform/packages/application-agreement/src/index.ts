/**
 * @mentora/application-agreement — public API.
 *
 * The application layer of the Agreement domain: the Séquence de Commande
 * (F4.1) orchestration harness. The domain decides; the application
 * orchestrates; the adapters execute. Lot 1C-1 ships the ARCHITECTURE (frozen
 * steps, ports, error channels, reception, the wire→domain seam); the stages
 * and handlers arrive in later sub-lots.
 */

// The frozen ten steps (A-2; F4.1.99 order).
export * from './pipeline/sequence-steps.js';

// Ports owned by the application (F4.4 I-4).
export * from './ports/sequence-journal.port.js';

// The three channels (A-7): Refusal is the domain's value; Exception + Failure here.
export * from './errors/application-errors.js';

// Pas 1 — Reception (delegates to the published language).
export * from './validators/reception.js';

// The wire → domain seam (injected instant, VO doors).
export * from './factories/agreement-command-factory.js';
