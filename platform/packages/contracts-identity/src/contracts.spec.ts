import { describe, expect, it } from 'vitest';

import type { CredentialEstablished } from './events/identity-event-contracts.js';
import { CREDENTIAL_REFUSAL_REASONS, SESSION_REFUSAL_REASONS } from './refusals.js';
import {
  deserializeIdentityEvent,
  serializeIdentityEvent,
  validateIdentityEvent,
} from './serialization/identity-event-serialization.js';

const sampleEstablished: CredentialEstablished = {
  type: 'CredentialEstablished',
  contractVersion: 1,
  credentialId: 'cred-1' as CredentialEstablished['credentialId'],
  sequence: 1,
  occurredAtMs: 1_000_000,
  personId: 'person-1' as CredentialEstablished['personId'],
  principalFactorId: 'factor-1' as CredentialEstablished['principalFactorId'],
  principalFactorKind: 'password',
};

describe('contracts-identity — the published language', () => {
  it('exposes the closed refusal-reason lists (R-A reason SETTLED: CredentialAlreadyExists, the ratified `<Truth>AlreadyExists` family)', () => {
    expect(CREDENTIAL_REFUSAL_REASONS).toEqual(['TransitionUnavailable', 'CredentialAlreadyExists']);
    expect(SESSION_REFUSAL_REASONS).toEqual(['TransitionUnavailable', 'ProofUnavailable']);
  });
});

describe('event serializers (deterministic, versioned)', () => {
  it('roundtrips an event through the wire', () => {
    const json = serializeIdentityEvent(sampleEstablished);
    const back = deserializeIdentityEvent(json);
    expect(back.ok).toBe(true);
    if (back.ok) expect(back.value).toEqual(sampleEstablished);
  });

  it('is deterministic: key order never varies with insertion order', () => {
    const shuffled = {
      principalFactorKind: sampleEstablished.principalFactorKind,
      occurredAtMs: sampleEstablished.occurredAtMs,
      type: sampleEstablished.type,
      personId: sampleEstablished.personId,
      sequence: sampleEstablished.sequence,
      principalFactorId: sampleEstablished.principalFactorId,
      contractVersion: sampleEstablished.contractVersion,
      credentialId: sampleEstablished.credentialId,
    } as CredentialEstablished;
    expect(serializeIdentityEvent(shuffled)).toBe(serializeIdentityEvent(sampleEstablished));
  });

  it('validates structurally and lists ALL violations', () => {
    const verdict = validateIdentityEvent({ type: 'CredentialEstablished', contractVersion: 2 });
    expect(verdict.ok).toBe(false);
    if (!verdict.ok) {
      expect(verdict.error.length).toBeGreaterThanOrEqual(4);
    }
    const unknown = validateIdentityEvent({ type: 'SessionOpened' });
    expect(unknown.ok).toBe(false);
    if (!unknown.ok) {
      // No Session fact exists in the language — by constitutional state.
      expect(unknown.error[0]?.code).toBe('CONTRACT.UNKNOWN_CONTRACT');
    }
  });

  it('malformed JSON is a violation, never a throw', () => {
    const verdict = deserializeIdentityEvent('{broken');
    expect(verdict.ok).toBe(false);
    if (!verdict.ok) expect(verdict.error[0]?.code).toBe('CONTRACT.MALFORMED_JSON');
  });
});
