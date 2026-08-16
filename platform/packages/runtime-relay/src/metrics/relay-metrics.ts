import type { MetricsRegistry } from '@mentora/runtime-metrics';
import type { Counter, Gauge, Histogram } from '@mentora/runtime-metrics';

/**
 * RelayMetrics — operations readings (O-1: observability reads everything,
 * owns nothing; O-3: no metric enters a Sequence). Metric names are words
 * of the operations vocabulary (F5.3 §10).
 */
export class RelayMetrics {
  readonly pendingBacklog: Gauge;
  readonly claimed: Counter;
  readonly published: Counter;
  readonly retried: Counter;
  readonly quarantined: Counter;
  readonly publishMillis: Histogram;
  readonly retryDelayMillis: Histogram;
  readonly batchMillis: Histogram;

  constructor(registry: MetricsRegistry) {
    this.pendingBacklog = registry.gauge('relay.backlog.pending');
    this.claimed = registry.counter('relay.claimed');
    this.published = registry.counter('relay.published');
    this.retried = registry.counter('relay.retried');
    this.quarantined = registry.counter('relay.quarantined');
    this.publishMillis = registry.histogram('relay.publish.millis');
    this.retryDelayMillis = registry.histogram('relay.retry.delay.millis');
    this.batchMillis = registry.histogram('relay.batch.millis');
  }
}
