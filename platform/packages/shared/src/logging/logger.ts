/**
 * The `Logger` **port**. Logging is an operational concern (F5.3: the Log is the
 * technical emission, perdable and bounded). This is the contract; concrete
 * loggers (pino, OpenTelemetry) are adapters. A `noopLogger` is provided for
 * tests and defaults.
 */

export type LogLevel = 'debug' | 'info' | 'warn' | 'error';

/** Structured fields attached to a log line. Never a secret, never a payload (P7). */
export type LogFields = Readonly<Record<string, unknown>>;

export interface Logger {
  debug(message: string, fields?: LogFields): void;
  info(message: string, fields?: LogFields): void;
  warn(message: string, fields?: LogFields): void;
  error(message: string, fields?: LogFields): void;
  /** A child logger with additional bound fields (e.g. a correlation id). */
  child(bindings: LogFields): Logger;
}

/** A logger that discards everything. Safe default; useful in tests. */
export const noopLogger: Logger = {
  debug: () => undefined,
  info: () => undefined,
  warn: () => undefined,
  error: () => undefined,
  child: () => noopLogger,
};
