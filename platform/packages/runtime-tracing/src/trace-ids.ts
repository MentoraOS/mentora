import type { Brand } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';

/**
 * TraceId / SpanId — DIALECTS of the telemetry tooling (F5.3 §10, verbatim:
 * "`TraceId`/`SpanId` sont des dialectes"), never domain vocabulary and
 * never crossing into a truth. `SessionId` is RESERVED to I&A — its use in
 * telemetry is a forbidden collision (F5.3 §10). W3C shapes: 32 lowercase
 * hex (trace), 16 lowercase hex (span), never all-zero.
 */

export type TraceId = Brand<string, 'TraceId'>;
export type SpanId = Brand<string, 'SpanId'>;

const TRACE_SHAPE = /^[0-9a-f]{32}$/;
const SPAN_SHAPE = /^[0-9a-f]{16}$/;

export const traceIdOf = (value: string): TraceId => {
  invariant(TRACE_SHAPE.test(value) && !/^0+$/.test(value), 'a TraceId is 32 non-zero hex chars');
  return value as TraceId;
};

export const spanIdOf = (value: string): SpanId => {
  invariant(SPAN_SHAPE.test(value) && !/^0+$/.test(value), 'a SpanId is 16 non-zero hex chars');
  return value as SpanId;
};

/** Where fresh ids come from — injected, so specs stay deterministic. */
export interface TraceIdSource {
  newTraceId(): TraceId;
  newSpanId(): SpanId;
}

const randomHex = (bytes: number): string => {
  const buffer = new Uint8Array(bytes);
  globalThis.crypto.getRandomValues(buffer);
  const hex = [...buffer].map((byte) => byte.toString(16).padStart(2, '0')).join('');
  return /^0+$/.test(hex) ? `1${hex.slice(1)}` : hex;
};

export const cryptoTraceIdSource: TraceIdSource = {
  newTraceId: () => traceIdOf(randomHex(16)),
  newSpanId: () => spanIdOf(randomHex(8)),
};
