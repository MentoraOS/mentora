import type { Clock } from '@mentora/kernel';
import type { Logger, LogLevel } from '@mentora/shared';

import { jsonLogFormatter } from './log-format.js';
import type { LogFormatter } from './log-format.js';
import { MemoryLogSink } from './log-sink.js';
import type { LogSink } from './log-sink.js';
import { StructuredLogger } from './structured-logger.js';

/**
 * LoggerFactory — one well, one formatter, one threshold for the whole
 * executable; each component receives a named child (I-2: one receives,
 * one never searches).
 */
export interface LoggerFactory {
  loggerFor(component: string): Logger;
}

export interface LoggerFactoryOptions {
  readonly clock: Clock;
  readonly sink: LogSink;
  readonly formatter?: LogFormatter;
  readonly threshold?: LogLevel;
}

export const createLoggerFactory = (options: LoggerFactoryOptions): LoggerFactory => {
  const root = new StructuredLogger({
    clock: options.clock,
    sink: options.sink,
    formatter: options.formatter ?? jsonLogFormatter,
    ...(options.threshold !== undefined ? { threshold: options.threshold } : {}),
  });
  return {
    loggerFor: (component) => root.child({ component }),
  };
};

/** A memory-backed logger for specs and boot buffers — lines readable. */
export const createMemoryLogger = (
  clock: Clock,
  threshold?: LogLevel,
): { readonly logger: Logger; readonly sink: MemoryLogSink } => {
  const sink = new MemoryLogSink();
  const logger = new StructuredLogger({
    clock,
    sink,
    formatter: jsonLogFormatter,
    ...(threshold !== undefined ? { threshold } : {}),
  });
  return { logger, sink };
};
