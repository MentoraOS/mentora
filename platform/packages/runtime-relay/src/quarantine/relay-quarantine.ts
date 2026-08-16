import type { Logger } from '@mentora/shared';

import type { RelaySourcePort } from '../claim/relay-source-port.js';
import type { RelayEnvelope } from '../dispatch/relay-envelope.js';

/**
 * RelayQuarantine — beyond the bounded budget: "parqué, journalisé, et
 * signale l'exploitation — RIEN NE MEURT SANS TÉMOIN ; un poison message ne
 * bloque jamais la file des autres" (F4.3 §8/M-8). Nothing disappears: the
 * row is parked, never deleted; its exit is a replay tooling act (named
 * target, refusable) or a governed bounded-retention purge.
 *
 * The Signal d'exploitation's full materialization (Alert pipeline, F5.3)
 * awaits the observability tooling — TODAY the witness is threefold: the
 * error Log (identifiers only, no matter — O-2), the quarantine metric, and
 * the health snapshot. SIGNALED.
 */
export class RelayQuarantine {
  constructor(
    private readonly source: RelaySourcePort,
    private readonly logger: Logger,
  ) {}

  async park(envelope: RelayEnvelope, reason: string): Promise<void> {
    await this.source.quarantine(envelope.messageId, reason);
    this.logger.error('relay envelope quarantined — operations must look', {
      messageId: envelope.messageId,
      subjectKey: envelope.subjectKey,
      sequence: envelope.sequence,
      deliveryAttempts: envelope.deliveryAttempts,
      reason,
      ...(envelope.correlationId !== undefined ? { correlationId: envelope.correlationId } : {}),
    });
  }
}
