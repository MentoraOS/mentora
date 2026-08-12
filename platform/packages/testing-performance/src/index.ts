/**
 * @mentora/testing-performance — a small, honest performance harness.
 *
 * Micro-benchmarks lie easily; this harness keeps them honest with warmup,
 * repetition, and robust statistics (median/p95, not mean-of-noise). For
 * *assertions* in CI, prefer generous budgets (`expectUnderMillis`) — a
 * perf test that fails on a busy runner is worse than none.
 */

export { measure, measureAsync } from './timer.js';
export type { Measurement } from './timer.js';
export { benchmark } from './benchmark.js';
export type { BenchmarkOptions, BenchmarkResult } from './benchmark.js';
export { expectUnderMillis, heapUsedBytes, withHeapDelta } from './assertions.js';
export type { HeapDelta } from './assertions.js';
