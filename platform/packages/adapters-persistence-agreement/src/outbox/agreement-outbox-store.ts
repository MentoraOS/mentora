import { serializeAgreementEvent } from '@mentora/contracts-agreement';
import type { AgreementDomainEvent } from '@mentora/domain-agreement';
import type { IdGenerator, RetentionContext } from '@mentora/kernel';
import type { Prisma } from '@prisma/client';

import { toWireFact } from '../fact-stream/agreement-fact-mapper.js';


/**
 * AgreementOutboxStore — WRITE ONLY (the mandate's law and A-4's: the RELAY
 * executable reads pending and carries at-least-once; it does not exist yet
 * — the rows accumulate, assumed and documented). One row per fact, born in
 * the SAME atomic retention (A-3/M-4). Envelope fields at write: a fresh
 * MessageId (a same fact re-carried keeps its EventIdentity, new MessageId —
 * F4.99 §6); deliveryAttempts start at 0 and live HERE, never in a position
 * (P-4). correlationId/causationId come from the OPTIONAL RetentionContext
 * (RFC-001 Option A, RATIFIED 2026-08-18) — the signaled gap is CLOSED:
 * "corrélation portée quand elle existe" (F5.3 §2); an absent context
 * writes NULL, exactly the pre-RFC behavior.
 */
export class AgreementOutboxStore {
  constructor(private readonly messageIds: IdGenerator) {}

  async write(
    tx: Prisma.TransactionClient,
    facts: readonly AgreementDomainEvent[],
    context?: RetentionContext,
  ): Promise<void> {
    await tx.agreementOutbox.createMany({
      data: facts.map((fact) => {
        const wire = toWireFact(fact);
        return {
          messageId: this.messageIds.generate(),
          agreementId: wire.agreementId,
          sequence: wire.sequence,
          payload: serializeAgreementEvent(wire),
          occurredAtMs: BigInt(wire.occurredAtMs),
          ...(context?.correlationId !== undefined ? { correlationId: context.correlationId } : {}),
          ...(context?.causationId !== undefined ? { causationId: context.causationId } : {}),
        };
      }),
    });
  }
}
