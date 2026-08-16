import type { Clock } from '@mentora/kernel';
import type { Tracer } from '@mentora/runtime-tracing';
import type { Logger } from '@mentora/shared';

import { RelayAck } from '../ack/relay-ack.js';
import { ClaimEngine } from '../claim/claim-engine.js';
import type { RelaySourcePort } from '../claim/relay-source-port.js';
import type { RelayMetrics } from '../metrics/relay-metrics.js';
import type { RelayPublisherPort } from '../publisher/relay-publisher-port.js';
import { RelayQuarantine } from '../quarantine/relay-quarantine.js';
import type { RelayRetryEngine } from '../retry/relay-retry-engine.js';
import { PendingScanner } from '../scanner/pending-scanner.js';
import { RelayTracing } from '../tracing/relay-tracing.js';

import type { RelayEnvelope } from './relay-envelope.js';


/**
 * RelayDispatch — the whole road of ONE batch, envelopes only (A-4: the
 * publication READS the retention; the relay carries at-least-once, M-4):
 *
 *   claim (lease-optimization) → publish (abstract port) →
 *     ok    → ACK (pending → published, never deleted)
 *     throw → attempts within budget → recordAttempt(next = now + backoff)
 *           → budget spent            → Quarantaine + witness (M-8)
 *
 * Envelopes travel UNTOUCHED (no loss of correlation/causation/trace); a
 * batch handles its envelopes in claimed order (per-subject order preserved
 * by the source's eligibility contract); one envelope's failure never stops
 * the batch's other subjects.
 */

export interface RelayDispatchOptions {
  readonly batchSize: number;
  readonly claimDurationMillis: number;
}

export interface RelayBatchOutcome {
  readonly claimed: number;
  readonly published: number;
  readonly retried: number;
  readonly quarantined: number;
}

export class RelayDispatch {
  private readonly scanner: PendingScanner;
  private readonly ack: RelayAck;
  private readonly quarantineBay: RelayQuarantine;
  private readonly tracing: RelayTracing;

  constructor(
    private readonly source: RelaySourcePort,
    private readonly publisher: RelayPublisherPort,
    private readonly retries: RelayRetryEngine,
    private readonly clock: Clock,
    private readonly metrics: RelayMetrics,
    logger: Logger,
    options: RelayDispatchOptions,
    tracer?: Tracer,
  ) {
    this.scanner = new PendingScanner(
      new ClaimEngine(source, options.claimDurationMillis),
      options.batchSize,
    );
    this.ack = new RelayAck(source);
    this.quarantineBay = new RelayQuarantine(source, logger);
    this.tracing = new RelayTracing(tracer);
  }

  /** One relay pass: claim a page, carry each envelope to its lawful end. */
  async runOnce(): Promise<RelayBatchOutcome> {
    const batchStartedAt = this.clock.now().epochMillis;
    const envelopes = await this.scanner.nextBatch(batchStartedAt);
    this.metrics.claimed.increment(envelopes.length);

    let published = 0;
    let retried = 0;
    let quarantined = 0;
    for (const envelope of envelopes) {
      const outcome = await this.carry(envelope);
      if (outcome === 'published') {
        published += 1;
      } else if (outcome === 'retried') {
        retried += 1;
      } else {
        quarantined += 1;
      }
    }

    const backlog = await this.source.backlog(this.clock.now().epochMillis);
    this.metrics.pendingBacklog.set(backlog.pending);
    this.metrics.batchMillis.observe(this.clock.now().epochMillis - batchStartedAt);
    return { claimed: envelopes.length, published, retried, quarantined };
  }

  private async carry(envelope: RelayEnvelope): Promise<'published' | 'retried' | 'quarantined'> {
    const span = this.tracing.publishSpan(envelope);
    const startedAt = this.clock.now().epochMillis;
    try {
      await this.publisher.publish(envelope);
      this.metrics.publishMillis.observe(this.clock.now().epochMillis - startedAt);
      await this.ack.acknowledge(envelope);
      this.metrics.published.increment();
      return 'published';
    } catch (error) {
      const attemptsNow = envelope.deliveryAttempts + 1;
      if (this.retries.exhausted(attemptsNow)) {
        await this.quarantineBay.park(
          envelope,
          error instanceof Error ? error.message : String(error),
        );
        this.metrics.quarantined.increment();
        return 'quarantined';
      }
      const delay = this.retries.delayForMillis(attemptsNow);
      this.metrics.retryDelayMillis.observe(delay);
      await this.source.recordAttempt(
        envelope.messageId,
        this.clock.now().epochMillis + delay,
      );
      this.metrics.retried.increment();
      return 'retried';
    } finally {
      span?.end();
    }
  }
}
