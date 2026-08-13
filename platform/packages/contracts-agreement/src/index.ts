/**
 * @mentora/contracts-agreement — public API.
 *
 * The PUBLISHED LANGUAGE of the Agreement domain (Engagement bounded context):
 * every other package speaks to Agreement exclusively through these contracts.
 * Types + contract validation only — no business logic, no implementation.
 * Transversal abstractions (envelopes, CommandId, CorrelationId, Page…) are
 * REUSED from @mentora/contracts, never redeclared.
 */

// Identity (types + contract validators). CommandId re-exported from the core.
export * from './ids/identifiers.js';

// Public error contracts (coded shapes — never a JavaScript Error).
export type {
  AgreementRefusalReason,
  AgreementRefusalContract,
  AgreementContractViolation,
  AgreementContractViolationCode,
} from './errors/agreement-error-contract.js';

// Shared wire fragments + the closed event union.
export * from './wire/fragments.js';
export * from './wire/event-union.js';

// The eight published facts.
export type * from './events/agreement-event-contracts.js';

// The eight published commands.
export * from './commands/agreement-command-contracts.js';

// The ratified read + its response.
export type { AgreementStateQuery } from './queries/agreement-state.query.js';
export type { AgreementStateResponse } from './responses/agreement-state.response.js';

// Agreement-typed envelope instantiations (core envelopes reused).
export type {
  AgreementCommandEnvelope,
  AgreementEventEnvelope,
  AgreementQueryEnvelope,
} from './messages/agreement-envelopes.js';

// Schemas (data-driven, framework-free) + engine.
export * from './schemas/contract-schema.js';
export * from './schemas/agreement-schemas.js';

// Validators (structure + generation; tolerant readers, V-2).
export * from './validators/agreement-validators.js';

// Serializers (deterministic, versioned, backward compatible).
export * from './serializers/agreement-serializers.js';

// Generation manifest (V-1: the owner owns the generations).
export * from './version/contract-generations.js';
