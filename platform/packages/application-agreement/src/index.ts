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

// The eight SequenceDefinitions — what Agreement injects into the Golden Pipeline.
export * from './definitions/agreement-sequence-definition.js';
export * from './definitions/request-agreement.definition.js';
export * from './definitions/accept-agreement.definition.js';
export * from './definitions/reject-agreement.definition.js';
export * from './definitions/confirm-agreement.definition.js';
export * from './definitions/reschedule-agreement.definition.js';
export * from './definitions/cancel-agreement.definition.js';
export * from './definitions/lapse-agreement-request.definition.js';
export * from './definitions/elapse-agreement.definition.js';

// The Query side (1C-4) — the Séquence de Lecture instantiated for the ONE
// ratified Agreement read (F3.3 §5), plus its dispatch entries and ports.
export * from './query/ports/agreement-state-read.port.js';
export * from './query/errors/agreement-read-refusal.js';
export * from './query/validators/agreement-query-reception.js';
export * from './query/definitions/agreement-state-query.definition.js';
export * from './query/services/agreement-state-query.application-service.js';
export * from './query/dispatch/agreement-query-dispatch.js';
export * from './query/testing/agreement-read-doubles.js';

// The Composition of the Agreement context (1C-7) — Pure DI, the whole
// graph built explicitly; the executable's Root calls composeAgreement with
// its real ports and validated configuration (F4.4 §2, unique per executable).
export * from './composition/agreement-composition.js';

// The eight Application Services (F4.1 §8: `<UseCase>ApplicationService`) —
// guardians of execution, one Command each (A-1), zero business logic.
export * from './services/agreement-sequence.application-service.js';
export * from './services/request-agreement.application-service.js';
export * from './services/accept-agreement.application-service.js';
export * from './services/reject-agreement.application-service.js';
export * from './services/confirm-agreement.application-service.js';
export * from './services/reschedule-agreement.application-service.js';
export * from './services/cancel-agreement.application-service.js';
export * from './services/lapse-agreement-request.application-service.js';
export * from './services/elapse-agreement.application-service.js';
