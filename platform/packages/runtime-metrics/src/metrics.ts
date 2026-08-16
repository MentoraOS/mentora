import type { Clock, Instant } from '@mentora/kernel';

/**
 * Technical metrics — F5.3 §3, verbatim: "Toutes les métriques sont des
 * lectures d'exploitation … dérivées des journaux et des faits, jamais
 * consultées par une Séquence (structurellement : AUCUN PORT DE MÉTRIQUE
 * N'EXISTE DANS LA SÉQUENCE — I-1)." These instruments therefore live in
 * adapters, relays and the Runtime — never inside a ring. A metric name is
 * a word of the OPERATIONS vocabulary (Catalogue des noms de métriques,
 * F5.3 §10). Business metrics come free from the Reasons (F4.1 §9) — they
 * are derived from journals, never instrumented in domain code.
 */

export type MetricLabels = Readonly<Record<string, string>>;

export class Counter {
  private total = 0;

  increment(by = 1): void {
    this.total += by;
  }

  get value(): number {
    return this.total;
  }
}

export class Gauge {
  private current = 0;

  set(value: number): void {
    this.current = value;
  }

  get value(): number {
    return this.current;
  }
}

export interface HistogramSummary {
  readonly count: number;
  readonly sum: number;
  readonly min: number;
  readonly max: number;
}

export class Histogram {
  private count = 0;
  private sum = 0;
  private min = Number.POSITIVE_INFINITY;
  private max = Number.NEGATIVE_INFINITY;

  observe(value: number): void {
    this.count += 1;
    this.sum += value;
    this.min = Math.min(this.min, value);
    this.max = Math.max(this.max, value);
  }

  summary(): HistogramSummary {
    return this.count === 0
      ? { count: 0, sum: 0, min: 0, max: 0 }
      : { count: this.count, sum: this.sum, min: this.min, max: this.max };
  }
}

/** Duration instrument over an INJECTED clock (A-6) — deterministic in specs. */
export class Timer {
  constructor(
    private readonly histogram: Histogram,
    private readonly clock: Clock,
  ) {}

  /** Captures the start instant; the returned stop() observes the elapsed millis. */
  start(): () => void {
    const startedAt: Instant = this.clock.now();
    return () => {
      this.histogram.observe(this.clock.now().epochMillis - startedAt.epochMillis);
    };
  }
}
