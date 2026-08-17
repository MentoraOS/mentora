import type { RelayEnvelope, RelayPublisherPort } from '@mentora/runtime-relay';
import type { Logger } from '@mentora/shared';

/**
 * EmptyRoutingPublisher — the Bus door of THIS deployment stage, honest by
 * construction: the routing table is a PROJECTION OF DECLARED SUBSCRIPTIONS
 * (M-5) and today that projection is EMPTY — no consumer exists (the 1C-5
 * and 1C-6 STOPs stand; no other domain is built). The fan-out of a fact to
 * ZERO declared subscribers IS the complete, successful delivery (F4.3 §4:
 * "un fait va à tous ses abonnés déclarés" — all zero of them). Each
 * carried envelope is witnessed in the technical Log (identifiers only).
 * A real broker adapter replaces this the day the FIRST subscription is
 * declared — the relay will not change (the port is the law).
 */
export class EmptyRoutingPublisher implements RelayPublisherPort {
  constructor(private readonly logger: Logger) {}

  publish(envelope: RelayEnvelope): Promise<void> {
    this.logger.info('fact carried to routing — zero declared subscribers today (M-5)', {
      messageId: envelope.messageId,
      subjectKey: envelope.subjectKey,
      sequence: envelope.sequence,
      ...(envelope.correlationId !== undefined ? { correlationId: envelope.correlationId } : {}),
    });
    return Promise.resolve();
  }
}
