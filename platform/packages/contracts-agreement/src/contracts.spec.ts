import type { CorrelationId } from '@mentora/contracts';
import { commandEnvelopeOf, eventEnvelopeOf, queryEnvelopeOf } from '@mentora/contracts';
import { describe, expect, it } from 'vitest';

import type { RequestAgreement } from './commands/agreement-command-contracts.js';
import { AGREEMENT_COMMAND_TYPES } from './commands/agreement-command-contracts.js';
import type { AgreementRequested } from './events/agreement-event-contracts.js';
import { validAgreementId, validClientId } from './ids/identifiers.js';
import {
  AGREEMENT_COMMAND_SCHEMAS,
  AGREEMENT_EVENT_SCHEMAS,
  AGREEMENT_QUERY_SCHEMAS,
} from './schemas/agreement-schemas.js';
import {
  deserializeAgreementCommand,
  deserializeAgreementEvent,
  serializeAgreementCommand,
  serializeAgreementEvent,
} from './serializers/agreement-serializers.js';
import {
  validateAgreementCommand,
  validateAgreementEvent,
  validateAgreementQuery,
} from './validators/agreement-validators.js';
import {
  AGREEMENT_CONTRACT_GENERATIONS,
  isCompatibleGeneration,
} from './version/contract-generations.js';
import { AGREEMENT_EVENT_TYPES } from './wire/event-union.js';

const sampleRequested: AgreementRequested = {
  type: 'AgreementRequested',
  contractVersion: 1,
  agreementId: 'agr-1' as AgreementRequested['agreementId'],
  sequence: 1,
  occurredAtMs: 1_000_000,
  clientId: 'cli-1' as AgreementRequested['clientId'],
  expertId: 'exp-1' as AgreementRequested['expertId'],
  offerId: 'off-1' as AgreementRequested['offerId'],
  slot: { startMs: 2_000_000, endMs: 3_000_000 },
};

const sampleCommand: RequestAgreement = {
  type: 'RequestAgreement',
  contractVersion: 1,
  commandId: 'cmd-1' as RequestAgreement['commandId'],
  agreementId: 'agr-1' as RequestAgreement['agreementId'],
  clientId: 'cli-1' as RequestAgreement['clientId'],
  expertId: 'exp-1' as RequestAgreement['expertId'],
  offerId: 'off-1' as RequestAgreement['offerId'],
  slot: { startMs: 2_000_000, endMs: 3_000_000 },
  availabilityWindows: [{ startMs: 0, endMs: 9_000_000 }],
};

describe('coverage manifests (frozen enumerations — F2.5 §4/§5)', () => {
  it('every event type has a schema and a generation', () => {
    for (const type of AGREEMENT_EVENT_TYPES) {
      expect(AGREEMENT_EVENT_SCHEMAS[type], type).toBeDefined();
      expect(AGREEMENT_CONTRACT_GENERATIONS[type], type).toBeDefined();
    }
    expect(AGREEMENT_EVENT_TYPES).toHaveLength(8);
  });

  it('every command type has a schema and a generation', () => {
    for (const type of AGREEMENT_COMMAND_TYPES) {
      expect(AGREEMENT_COMMAND_SCHEMAS[type], type).toBeDefined();
      expect(AGREEMENT_CONTRACT_GENERATIONS[type], type).toBeDefined();
    }
    expect(AGREEMENT_COMMAND_TYPES).toHaveLength(8);
  });

  it('the ratified query has a schema and a generation', () => {
    expect(AGREEMENT_QUERY_SCHEMAS['AgreementStateQuery']).toBeDefined();
    expect(isCompatibleGeneration('AgreementStateQuery', 1)).toBe(true);
  });
});

describe('validators (contract structure only; tolerant readers — V-2)', () => {
  it('accepts a valid event and a valid command', () => {
    expect(validateAgreementEvent(sampleRequested).ok).toBe(true);
    expect(validateAgreementCommand(sampleCommand).ok).toBe(true);
  });

  it('ignores unknown extra fields (lecteur tolérant, V-2)', () => {
    const withExtras = { ...sampleRequested, futureField: 'ignored', another: 42 };
    expect(validateAgreementEvent(withExtras).ok).toBe(true);
  });

  it('refuses a missing required field with a coded violation', () => {
    const withoutSlot: Record<string, unknown> = { ...sampleRequested };
    delete withoutSlot['slot'];
    const result = validateAgreementEvent(withoutSlot);
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error[0]?.code).toBe('CONTRACT.FIELD_MISSING');
      expect(result.error[0]?.field).toBe('slot');
    }
  });

  it('refuses a mistyped field and a blank identifier', () => {
    const mistyped = { ...sampleRequested, sequence: 'one' };
    const blank = { ...sampleCommand, settlementReference: undefined, type: 'ConfirmAgreement' };
    const mistypedResult = validateAgreementEvent(mistyped);
    expect(mistypedResult.ok).toBe(false);
    if (!mistypedResult.ok) expect(mistypedResult.error[0]?.code).toBe('CONTRACT.FIELD_TYPE');
    const blankResult = validateAgreementCommand({ ...blank, settlementReference: '  ' });
    expect(blankResult.ok).toBe(false);
    if (!blankResult.ok) expect(blankResult.error[0]?.code).toBe('CONTRACT.FIELD_BLANK');
  });

  it('refuses an unknown contract and an incompatible generation', () => {
    const unknown = validateAgreementEvent({ ...sampleRequested, type: 'AgreementTeleported' });
    expect(unknown.ok).toBe(false);
    if (!unknown.ok) expect(unknown.error[0]?.code).toBe('CONTRACT.UNKNOWN_CONTRACT');
    const future = validateAgreementEvent({ ...sampleRequested, contractVersion: 99 });
    expect(future.ok).toBe(false);
    if (!future.ok) expect(future.error[0]?.code).toBe('CONTRACT.VERSION_INCOMPATIBLE');
  });

  it('validates the ratified query', () => {
    expect(
      validateAgreementQuery({
        type: 'AgreementStateQuery',
        contractVersion: 1,
        agreementId: 'agr-1',
      }).ok,
    ).toBe(true);
  });
});

describe('serializers (deterministic, versioned, backward compatible)', () => {
  it('roundtrips an event and a command', () => {
    const eventJson = serializeAgreementEvent(sampleRequested);
    const eventBack = deserializeAgreementEvent(eventJson);
    expect(eventBack.ok).toBe(true);
    if (eventBack.ok) expect(eventBack.value).toEqual(sampleRequested);

    const commandJson = serializeAgreementCommand(sampleCommand);
    const commandBack = deserializeAgreementCommand(commandJson);
    expect(commandBack.ok).toBe(true);
    if (commandBack.ok) expect(commandBack.value).toEqual(sampleCommand);
  });

  it('is deterministic: key order never varies with insertion order', () => {
    const shuffled = {
      slot: sampleRequested.slot,
      occurredAtMs: sampleRequested.occurredAtMs,
      type: sampleRequested.type,
      offerId: sampleRequested.offerId,
      clientId: sampleRequested.clientId,
      sequence: sampleRequested.sequence,
      expertId: sampleRequested.expertId,
      agreementId: sampleRequested.agreementId,
      contractVersion: sampleRequested.contractVersion,
    } as AgreementRequested;
    expect(serializeAgreementEvent(shuffled)).toBe(serializeAgreementEvent(sampleRequested));
  });

  it('malformed JSON is a coded violation, never a throw', () => {
    const result = deserializeAgreementEvent('{not json');
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.error[0]?.code).toBe('CONTRACT.MALFORMED_JSON');
  });
});

describe('envelopes (M-3: correlation/causation ride the envelope, never the fact)', () => {
  const correlationId = 'corr-1' as CorrelationId;

  it('wraps commands, events and queries with core envelopes', () => {
    const commandEnvelope = commandEnvelopeOf(sampleCommand, { correlationId });
    const eventEnvelope = eventEnvelopeOf(sampleRequested, { correlationId, attempt: 1 });
    const queryEnvelope = queryEnvelopeOf(
      { type: 'AgreementStateQuery' as const, contractVersion: 1 as const, agreementId: sampleRequested.agreementId },
      { correlationId },
    );
    expect(commandEnvelope.kind).toBe('command');
    expect(eventEnvelope.kind).toBe('event');
    expect(queryEnvelope.kind).toBe('query');
    expect(eventEnvelope.metadata.correlationId).toBe(correlationId);
  });

  it('the fact itself never carries correlation (M-3 held by construction)', () => {
    expect('correlationId' in sampleRequested).toBe(false);
    expect('causationId' in sampleRequested).toBe(false);
  });
});

describe('id contract validators', () => {
  it('accept non-blank, refuse blank with a coded violation', () => {
    expect(validAgreementId('agr-1').ok).toBe(true);
    const blank = validClientId('   ');
    expect(blank.ok).toBe(false);
    if (!blank.ok) expect(blank.error.code).toBe('CONTRACT.FIELD_BLANK');
  });
});
