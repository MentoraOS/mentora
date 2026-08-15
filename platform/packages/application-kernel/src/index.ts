/**
 * @mentora/application-kernel — public API.
 *
 * THE official Séquence de Commande pipeline of Mentora (F4.1): the ten
 * frozen steps as a generic, domain-agnostic harness. The pipeline does not
 * belong to any domain — each bounded context INJECTS its SequenceDefinition;
 * Agreement is only the first user (then Consultation, Settlement, Account…).
 */

// The frozen ten steps (A-2; F4.1.99 order) — the canonical definition.
export * from './step/sequence-steps.js';

// The stage classes (one per step, single responsibility).
export * from './step/stages.js';

// What a context injects (the plug).
export * from './interfaces/sequence-definition.js';

// The read view of one execution.
export * from './context/sequence-context.js';

// Outcomes & the three channels (A-7) as values.
export * from './result/sequence-outcome.js';

// The Exception channel (pas 1).
export * from './errors/sequence-errors.js';

// The Journal (A-10; Journal ≠ Log, F5.3).
export * from './journal/sequence-journal.port.js';

// The executor of the frozen order and the builder that composes it.
export * from './executor/sequence-executor.js';
export * from './builder/sequence-builder.js';

// Test doubles.
export * from './testing/recording-journal.js';
