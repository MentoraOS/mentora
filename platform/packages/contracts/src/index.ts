/**
 * @mentora/contracts — public API.
 *
 * Technical cross-cutting contracts: DI tokens, technical DTOs, transverse types.
 * Interfaces and tokens only — no implementation.
 */

// Tokens (values + types).
export * from './tokens/token.js';
export * from './tokens/platform-tokens.js';

// Technical DTOs (type-only).
export type * from './dto/pagination.js';

// Transverse types (type-only).
export type * from './types/cross-cutting.js';
export type * from './types/act-identity.js';

// Transport envelopes (M-3: correlation/causation ride the envelope, never the fact).
export * from './messages/envelopes.js';
