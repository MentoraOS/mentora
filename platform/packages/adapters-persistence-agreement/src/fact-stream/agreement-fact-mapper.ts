import type { AgreementEventContract } from '@mentora/contracts-agreement';
import { serializeAgreementEvent } from '@mentora/contracts-agreement';
import type { AgreementDomainEvent, AgreementParty } from '@mentora/domain-agreement';
import { fnv1aChecksum } from '@mentora/runtime-serialization';

/**
 * The fact-mapper — domain fact → PUBLISHED wire fact (the language the
 * relay will carry to the routing; 1B contracts). The wire serialization
 * belongs to the OWNER's deterministic serializers (V-1) — this mapper
 * CALLS them, never redefines them. Facts carry identities, natures,
 * instants, authors, provenances — never a matter (F3.3 §3).
 */

const partyToWire = (party: AgreementParty): { role: 'Client' | 'Expert'; id: string } =>
  party.role === 'Client'
    ? { role: 'Client', id: party.clientId }
    : { role: 'Expert', id: party.expertId };

export const toWireFact = (fact: AgreementDomainEvent): AgreementEventContract => {
  const base = {
    contractVersion: 1 as const,
    agreementId: fact.agreementId,
    sequence: fact.sequence,
    occurredAtMs: fact.instant.epochMillis,
  };
  switch (fact.type) {
    case 'AgreementRequested':
      return {
        ...base,
        type: 'AgreementRequested',
        clientId: fact.clientId,
        expertId: fact.expertId,
        offerId: fact.offerId,
        slot: { startMs: fact.slot.start.epochMillis, endMs: fact.slot.end.epochMillis },
      };
    case 'AgreementAccepted':
      return { ...base, type: 'AgreementAccepted', expertId: fact.expertId };
    case 'AgreementRejected':
      return { ...base, type: 'AgreementRejected', expertId: fact.expertId };
    case 'AgreementRequestLapsed':
      return { ...base, type: 'AgreementRequestLapsed' };
    case 'AgreementConfirmed':
      return {
        ...base,
        type: 'AgreementConfirmed',
        settlementReference: fact.settlementReference,
      };
    case 'AgreementRescheduled':
      return {
        ...base,
        type: 'AgreementRescheduled',
        previousSlot: {
          startMs: fact.record.previousSlot.start.epochMillis,
          endMs: fact.record.previousSlot.end.epochMillis,
        },
        newSlot: {
          startMs: fact.record.newSlot.start.epochMillis,
          endMs: fact.record.newSlot.end.epochMillis,
        },
        requestedBy: partyToWire(fact.record.requestedBy),
      };
    case 'AgreementCancelled':
      return {
        ...base,
        type: 'AgreementCancelled',
        cancelledBy: partyToWire(fact.record.cancelledBy),
        motive: fact.record.motive,
      };
    case 'AgreementElapsed':
      return { ...base, type: 'AgreementElapsed' };
  }
};

export interface AgreementFactRow {
  readonly agreementId: string;
  readonly sequence: number;
  readonly type: string;
  readonly payload: string;
  readonly contractVersion: number;
  readonly occurredAtMs: bigint;
  readonly checksum: string;
}

export const toFactRow = (fact: AgreementDomainEvent): AgreementFactRow => {
  const wire = toWireFact(fact);
  const payload = serializeAgreementEvent(wire);
  return {
    agreementId: wire.agreementId,
    sequence: wire.sequence,
    type: wire.type,
    payload,
    contractVersion: wire.contractVersion,
    occurredAtMs: BigInt(wire.occurredAtMs),
    checksum: fnv1aChecksum.checksum(payload),
  };
};
