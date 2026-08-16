/**
 * @mentora/runtime-logging — runtime implementations of the shared Logger
 * contract. F5.3: the Log is the TECHNICAL emission — perdable et borné,
 * "aucune matière, aucun secret" — forever distinct from the applicative
 * Journal (probant). This package never writes a Journal.
 */

export * from './log-record.js';
export * from './log-format.js';
export * from './log-sink.js';
export * from './structured-logger.js';
export * from './logger-factory.js';
