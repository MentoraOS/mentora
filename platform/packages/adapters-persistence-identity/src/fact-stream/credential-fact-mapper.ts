import type { IdentityEventContract } from '@mentora/contracts-identity';
import { serializeIdentityEvent } from '@mentora/contracts-identity';
import type { CredentialDomainEvent } from '@mentora/domain-identity';
import { fnv1aChecksum } from '@mentora/runtime-serialization';

/**
 * The fact-mapper — domain fact → PUBLISHED wire fact (the language the
 * relay will carry; V-1: the owner's deterministic serializers are CALLED,
 * never redefined). Facts carry identities, natures, instants, provenances
 * — never a matter, never a strength judgment (canon ch.04).
 */

export const toWireFact = (fact: CredentialDomainEvent): IdentityEventContract => {
  const base = {
    contractVersion: 1 as const,
    credentialId: fact.credentialId,
    sequence: fact.sequence,
    occurredAtMs: fact.instant.epochMillis,
  };
  switch (fact.type) {
    case 'CredentialEstablished':
      return {
        ...base,
        type: 'CredentialEstablished',
        personId: fact.personId,
        principalFactorId: fact.principalFactorId,
        principalFactorKind: fact.principalFactorKind,
      };
    case 'CredentialRevoked':
      return { ...base, type: 'CredentialRevoked', motive: fact.motive };
  }
};

export interface CredentialFactRow {
  readonly credentialId: string;
  readonly sequence: number;
  readonly type: string;
  readonly payload: string;
  readonly contractVersion: number;
  readonly occurredAtMs: bigint;
  readonly checksum: string;
}

export const toFactRow = (fact: CredentialDomainEvent): CredentialFactRow => {
  const wire = toWireFact(fact);
  const payload = serializeIdentityEvent(wire);
  return {
    credentialId: wire.credentialId,
    sequence: wire.sequence,
    type: wire.type,
    payload,
    contractVersion: wire.contractVersion,
    occurredAtMs: BigInt(wire.occurredAtMs),
    checksum: fnv1aChecksum.checksum(payload),
  };
};
