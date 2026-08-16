import type { Clock } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';

import type { HistogramSummary, MetricLabels } from './metrics.js';
import { Counter, Gauge, Histogram, Timer } from './metrics.js';

/**
 * MetricsRegistry — the closed, readable set of instruments of ONE
 * executable. Same instrument identity (name + labels) → same instance;
 * the snapshot is DETERMINISTIC (sorted keys) so exports and specs are
 * stable. No global singleton: the Root builds the registry and injects it
 * where instrumentation lives (I-2) — never into a Séquence (O-3).
 */

export interface MetricsSnapshot {
  readonly counters: Readonly<Record<string, number>>;
  readonly gauges: Readonly<Record<string, number>>;
  readonly histograms: Readonly<Record<string, HistogramSummary>>;
}

/**
 * The delivery surface toward an operations well. Named SINK, deliberately
 * NOT "Exporter": « Export » is a reserved word (the person's data right,
 * F5.2 §12/P9.6) — a telemetry well is a mechanism, O-10.
 */
export interface MetricsSink {
  deliver(snapshot: MetricsSnapshot): void;
}

export class MemoryMetricsSink implements MetricsSink {
  readonly deliveries: MetricsSnapshot[] = [];

  deliver(snapshot: MetricsSnapshot): void {
    this.deliveries.push(snapshot);
  }
}

const keyOf = (name: string, labels: MetricLabels): string => {
  invariant(name.trim() !== '', 'a metric name is a word of the operations vocabulary');
  const parts = Object.keys(labels)
    .sort()
    .map((label) => `${label}=${labels[label] ?? ''}`);
  return parts.length === 0 ? name : `${name}{${parts.join(',')}}`;
};

export class MetricsRegistry {
  private readonly counters = new Map<string, Counter>();
  private readonly gauges = new Map<string, Gauge>();
  private readonly histograms = new Map<string, Histogram>();

  constructor(private readonly clock: Clock) {}

  counter(name: string, labels: MetricLabels = {}): Counter {
    return obtain(this.counters, keyOf(name, labels), () => new Counter());
  }

  gauge(name: string, labels: MetricLabels = {}): Gauge {
    return obtain(this.gauges, keyOf(name, labels), () => new Gauge());
  }

  histogram(name: string, labels: MetricLabels = {}): Histogram {
    return obtain(this.histograms, keyOf(name, labels), () => new Histogram());
  }

  timer(name: string, labels: MetricLabels = {}): Timer {
    return new Timer(this.histogram(name, labels), this.clock);
  }

  snapshot(): MetricsSnapshot {
    return {
      counters: collect(this.counters, (counter) => counter.value),
      gauges: collect(this.gauges, (gauge) => gauge.value),
      histograms: collect(this.histograms, (histogram) => histogram.summary()),
    };
  }
}

/** MetricsFactory — what the Root calls (F4.4 §2: the Root builds the machinery). */
export const createMetricsRegistry = (clock: Clock): MetricsRegistry => new MetricsRegistry(clock);

const obtain = <T>(store: Map<string, T>, key: string, make: () => T): T => {
  const existing = store.get(key);
  if (existing !== undefined) {
    return existing;
  }
  const made = make();
  store.set(key, made);
  return made;
};

const collect = <T, V>(store: Map<string, T>, read: (instrument: T) => V): Record<string, V> => {
  const out: Record<string, V> = {};
  for (const key of [...store.keys()].sort()) {
    const instrument = store.get(key);
    if (instrument !== undefined) {
      out[key] = read(instrument);
    }
  }
  return out;
};
