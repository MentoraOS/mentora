/**
 * @mentora/kernel — public API.
 *
 * The single entrypoint of the kernel. Everything a consumer may use is
 * re-exported here; nothing under `src/` is imported directly (F3.1: referenced
 * by identity, never reached into). This barrel IS the package's contract.
 */

// Functional core (values + types).
export * from './core/result.js';
export * from './core/option.js';
export * from './core/either.js';

// Diagnostics (values + types).
export * from './diagnostics/errors.js';
export * from './diagnostics/guard.js';

// Ports (values + types).
export * from './ports/id.js';
export * from './ports/clock.js';
export * from './ports/retention-context.js';

// Type-only utilities.
export type { Brand } from './types/brand.js';
export type {
  Primitive,
  UnknownRecord,
  Prettify,
  NonEmptyArray,
  DeepReadonly,
} from './types/utility-types.js';
