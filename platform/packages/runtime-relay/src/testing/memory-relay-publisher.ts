import type { RelayEnvelope } from '../dispatch/relay-envelope.js';
import type { RelayPublisherPort } from '../publisher/relay-publisher-port.js';

/**
 * MemoryRelayPublisher — the abstract port's spec double: records every
 * delivered envelope VERBATIM (the no-loss assertion reads them back) and
 * injects failures per messageId (finite or permanent).
 */
export class MemoryRelayPublisher implements RelayPublisherPort {
  readonly delivered: RelayEnvelope[] = [];
  private readonly failures = new Map<string, number>();

  /** Fail the next `times` deliveries of this message (Infinity = poison). */
  failNext(messageId: string, times: number): void {
    this.failures.set(messageId, times);
  }

  publish(envelope: RelayEnvelope): Promise<void> {
    const remaining = this.failures.get(envelope.messageId) ?? 0;
    if (remaining > 0) {
      this.failures.set(envelope.messageId, remaining - 1);
      return Promise.reject(new Error(`bus unreachable for ${envelope.messageId}`));
    }
    this.delivered.push(envelope);
    return Promise.resolve();
  }
}
