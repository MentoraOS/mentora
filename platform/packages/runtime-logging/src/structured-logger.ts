import type { Clock } from '@mentora/kernel';
import type { LogFields, Logger, LogLevel } from '@mentora/shared';

import type { LogFormatter } from './log-format.js';
import { LOG_LEVEL_ORDER } from './log-record.js';
import type { LogSink } from './log-sink.js';

/**
 * StructuredLogger — the runtime implementation of the SHARED Logger
 * contract (owned by shared since 0B — this package implements, never
 * redefines). The Clock is INJECTED (A-6 — even the technical layer never
 * reads a clock ambiently); the threshold is technical configuration (I-5).
 */
export interface StructuredLoggerOptions {
  readonly clock: Clock;
  readonly sink: LogSink;
  readonly formatter: LogFormatter;
  readonly threshold?: LogLevel;
  readonly context?: LogFields;
}

export class StructuredLogger implements Logger {
  private readonly clock: Clock;
  private readonly sink: LogSink;
  private readonly formatter: LogFormatter;
  private readonly threshold: LogLevel;
  private readonly context: LogFields;

  constructor(options: StructuredLoggerOptions) {
    this.clock = options.clock;
    this.sink = options.sink;
    this.formatter = options.formatter;
    this.threshold = options.threshold ?? 'info';
    this.context = options.context ?? {};
  }

  debug(message: string, fields?: LogFields): void {
    this.emit('debug', message, fields);
  }

  info(message: string, fields?: LogFields): void {
    this.emit('info', message, fields);
  }

  warn(message: string, fields?: LogFields): void {
    this.emit('warn', message, fields);
  }

  error(message: string, fields?: LogFields): void {
    this.emit('error', message, fields);
  }

  child(bindings: LogFields): Logger {
    return new StructuredLogger({
      clock: this.clock,
      sink: this.sink,
      formatter: this.formatter,
      threshold: this.threshold,
      context: { ...this.context, ...bindings },
    });
  }

  private emit(level: LogLevel, message: string, fields?: LogFields): void {
    if (LOG_LEVEL_ORDER[level] < LOG_LEVEL_ORDER[this.threshold]) {
      return;
    }
    this.sink.write(
      this.formatter.format({
        level,
        message,
        context: this.context,
        fields: fields ?? {},
        occurredAtMs: this.clock.now().epochMillis,
      }),
    );
  }
}
