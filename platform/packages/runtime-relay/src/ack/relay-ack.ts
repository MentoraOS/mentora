import type { RelaySourcePort } from '../claim/relay-source-port.js';
import type { RelayEnvelope } from '../dispatch/relay-envelope.js';

/**
 * RelayAck — pending → published, NEVER a deletion: the row is transport
 * history; the eternal provenance stays the owner's fact stream (O-4). A
 * re-delivered occurrence keeps its fact identity under a new MessageId —
 * consumers deduplicate (A-5).
 */
export class RelayAck {
  constructor(private readonly source: RelaySourcePort) {}

  acknowledge(envelope: RelayEnvelope): Promise<void> {
    return this.source.markPublished(envelope.messageId);
  }
}
