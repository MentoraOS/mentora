/**
 * @mentora/shared — public API.
 *
 * Pure utilities and cross-cutting port contracts. The single entrypoint; no
 * consumer reaches into `src/`.
 */

export * from './functional/functional.js';
export * from './collections/array.js';
export * from './collections/object.js';
export * from './text/string.js';
export * from './numeric/math.js';
export * from './datetime/duration.js';
export * from './validation/validation.js';
export * from './resilience/retry.js';
export * from './logging/logger.js';
export * from './config/config.js';
