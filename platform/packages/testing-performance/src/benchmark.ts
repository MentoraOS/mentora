import { invariant } from '@mentora/kernel';

export interface BenchmarkOptions {
  /** Untimed warmup iterations (JIT settle). Default 10. */
  readonly warmupIterations?: number;
  /** Timed iterations. Default 100. */
  readonly iterations?: number;
}

export interface BenchmarkResult {
  readonly name: string;
  readonly iterations: number;
  readonly medianMillis: number;
  readonly p95Millis: number;
  readonly minMillis: number;
  readonly maxMillis: number;
  readonly meanMillis: number;
}

const percentile = (sorted: readonly number[], p: number): number => {
  const index = Math.min(sorted.length - 1, Math.ceil((p / 100) * sorted.length) - 1);
  return sorted[Math.max(0, index)] as number;
};

/**
 * Run `fn` repeatedly and report robust statistics. Median and p95 are the
 * numbers to look at; mean is reported but easily skewed by one GC pause.
 */
export const benchmark = (name: string, fn: () => void, options: BenchmarkOptions = {}): BenchmarkResult => {
  const warmup = options.warmupIterations ?? 10;
  const iterations = options.iterations ?? 100;
  invariant(iterations > 0, 'iterations must be > 0');

  for (let i = 0; i < warmup; i += 1) {
    fn();
  }

  const samples: number[] = [];
  for (let i = 0; i < iterations; i += 1) {
    const start = performance.now();
    fn();
    samples.push(performance.now() - start);
  }
  samples.sort((a, b) => a - b);

  const total = samples.reduce((acc, n) => acc + n, 0);
  return {
    name,
    iterations,
    medianMillis: percentile(samples, 50),
    p95Millis: percentile(samples, 95),
    minMillis: samples[0] as number,
    maxMillis: samples[samples.length - 1] as number,
    meanMillis: total / samples.length,
  };
};
