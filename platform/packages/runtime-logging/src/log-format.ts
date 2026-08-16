import type { LogRecord } from './log-record.js';

/** Formats one record into one emitted line. */
export interface LogFormatter {
  format(record: LogRecord): string;
}

/**
 * Deterministic JSON line: fixed head (level, message, occurredAtMs), then
 * context and fields with SORTED keys — the same record always formats to
 * the same line (deterministic behavior is testable behavior).
 */
export const jsonLogFormatter: LogFormatter = {
  format: (record) => {
    const body: Record<string, unknown> = {
      level: record.level,
      message: record.message,
      occurredAtMs: record.occurredAtMs,
    };
    for (const key of Object.keys(record.context).sort()) {
      body[`ctx.${key}`] = record.context[key];
    }
    for (const key of Object.keys(record.fields).sort()) {
      body[key] = record.fields[key];
    }
    return JSON.stringify(body);
  },
};

/** Terse human line for local development. */
export const textLogFormatter: LogFormatter = {
  format: (record) =>
    `${String(record.occurredAtMs)} ${record.level.toUpperCase()} ${record.message}`,
};
