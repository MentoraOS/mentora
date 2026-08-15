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

// The Séquence de Lecture (F4.99 §1: six frozen steps, born at the Grand
// Audit) and the Query Dispatch (F4.1 §6) — the READ engine, generic like the
// command pipeline: each context injects its ReadDefinition. Additive module
// (Lot 1C-4); nothing of the Séquence de Commande above was touched.
export * from './read/read-steps.js';
export * from './read/read-definition.js';
export * from './read/read-outcome.js';
export * from './read/read-journal.port.js';
export * from './read/read-executor.js';
export * from './read/query-dispatch.js';

// The Séquence de Réaction (F4.99 §1: six frozen steps, born at the Grand
// Audit) and the ReactionDispatch (M-5: routing = a projection of declared
// subscriptions) — the third and last execution path ("aucun quatrième
// chemin"). Additive module (Lot 1C-5); nothing frozen above was touched.
export * from './reaction/reaction-steps.js';
export * from './reaction/reaction-definition.js';
export * from './reaction/reaction-outcome.js';
export * from './reaction/reaction-journal.port.js';
export * from './reaction/reaction-errors.js';
export * from './reaction/reaction-context.js';
export * from './reaction/reaction-executor.js';
export * from './reaction/reaction-builder.js';
export * from './reaction/reaction-dispatch.js';

// Test doubles.
export * from './testing/recording-journal.js';
export * from './testing/recording-read-journal.js';
export * from './testing/recording-reaction-journal.js';
