import { instantOf } from '@mentora/kernel';
import { FakeClock } from '@mentora/testing-clock';
import { describe, expect, it } from 'vitest';

import { jsonLogFormatter, textLogFormatter } from './log-format.js';
import { MemoryLogSink } from './log-sink.js';
import { createLoggerFactory, createMemoryLogger } from './logger-factory.js';
import { StructuredLogger } from './structured-logger.js';

const T0 = instantOf(5_000);

describe('StructuredLogger (implements the shared Logger contract)', () => {
  it('emits deterministic JSON lines with the injected clock (A-6)', () => {
    const { logger, sink } = createMemoryLogger(FakeClock.at(T0), 'debug');
    logger.info('boot advanced', { state: 'Validation' });
    expect(sink.lines).toEqual([
      '{"level":"info","message":"boot advanced","occurredAtMs":5000,"state":"Validation"}',
    ]);
  });

  it('filters below the technical threshold (I-5)', () => {
    const { logger, sink } = createMemoryLogger(FakeClock.at(T0), 'warn');
    logger.debug('noise');
    logger.info('noise');
    logger.warn('kept');
    logger.error('kept');
    expect(sink.lines).toHaveLength(2);
  });

  it('child bindings merge into the context with sorted, prefixed keys', () => {
    const sink = new MemoryLogSink();
    const logger = new StructuredLogger({
      clock: FakeClock.at(T0),
      sink,
      formatter: jsonLogFormatter,
      threshold: 'debug',
    });
    logger.child({ component: 'relay' }).child({ correlationId: 'corr-1' }).info('carried');
    expect(sink.lines[0]).toBe(
      '{"level":"info","message":"carried","occurredAtMs":5000,"ctx.component":"relay","ctx.correlationId":"corr-1"}',
    );
  });

  it('the same record always formats to the same line — key order is sorted', () => {
    const { logger, sink } = createMemoryLogger(FakeClock.at(T0), 'debug');
    logger.info('probe', { zeta: 1, alpha: 2 });
    logger.info('probe', { alpha: 2, zeta: 1 });
    expect(sink.lines[0]).toBe(sink.lines[1]);
  });
});

describe('formatters', () => {
  it('the text formatter stays terse', () => {
    expect(
      textLogFormatter.format({
        level: 'error',
        message: 'well unreachable',
        context: {},
        fields: {},
        occurredAtMs: 7,
      }),
    ).toBe('7 ERROR well unreachable');
  });
});

describe('createLoggerFactory', () => {
  it('hands each component a named child over the ONE sink', () => {
    const sink = new MemoryLogSink();
    const factory = createLoggerFactory({
      clock: FakeClock.at(T0),
      sink,
      threshold: 'debug',
    });
    factory.loggerFor('relay').info('a');
    factory.loggerFor('scheduler').info('b');
    expect(sink.lines[0]).toContain('"ctx.component":"relay"');
    expect(sink.lines[1]).toContain('"ctx.component":"scheduler"');
  });
});

describe('defaults', () => {
  it('threshold defaults to info and context to empty', () => {
    const sink = new MemoryLogSink();
    const logger = new StructuredLogger({ clock: FakeClock.at(T0), sink, formatter: jsonLogFormatter });
    logger.debug('dropped');
    logger.info('kept');
    expect(sink.lines).toEqual(['{"level":"info","message":"kept","occurredAtMs":5000}']);
  });

  it('createMemoryLogger without threshold filters debug by default', () => {
    const { logger, sink } = createMemoryLogger(FakeClock.at(T0));
    logger.debug('dropped');
    logger.warn('kept');
    expect(sink.lines).toHaveLength(1);
  });
});
