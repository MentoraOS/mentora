import { serializeIdentityEvent } from '@mentora/contracts-identity';
import type { CredentialDomainEvent } from '@mentora/domain-identity';
import type { IdGenerator, RetentionContext } from '@mentora/kernel';

import { toWireFact } from '../fact-stream/credential-fact-mapper.js';
import type { Prisma } from '../generated/prisma/client.js';


/**
 * CredentialOutboxStore — WRITE ONLY (A-4's law: the RELAY executable reads
 * pending and carries at-least-once). One row per fact, born in the SAME
 * atomic retention (A-3/M-4). Envelope fields at write: a fresh MessageId
 * (a same fact re-carried keeps its EventIdentity, new MessageId — F4.99
 * §6); deliveryAttempts start at 0 and live HERE, never in a position (P-4).
 *
 * RFC-001 (Option A, RATIFIED): correlationId/causationId come from the
 * OPTIONAL RetentionContext — "corrélation portée quand elle existe"
 * (F5.3 §2). An absent context writes NULL, exactly the pre-RFC behavior.
 */
export class CredentialOutboxStore {
  constructor(private readonly messageIds: IdGenerator) {}

  async write(
    tx: Prisma.TransactionClient,
    facts: readonly CredentialDomainEvent[],
    context?: RetentionContext,
  ): Promise<void> {
    await tx.credentialOutbox.createMany({
      data: facts.map((fact) => {
        const wire = toWireFact(fact);
        return {
          messageId: this.messageIds.generate(),
          credentialId: wire.credentialId,
          sequence: wire.sequence,
          payload: serializeIdentityEvent(wire),
          occurredAtMs: BigInt(wire.occurredAtMs),
          ...(context?.correlationId !== undefined ? { correlationId: context.correlationId } : {}),
          ...(context?.causationId !== undefined ? { causationId: context.causationId } : {}),
        };
      }),
    });
  }
}
