import { describe, expect, it } from 'vitest';

import { AgreementReceptionException } from '../errors/application-errors.js';

import { receiveAgreementCommand, receiveAgreementQuery } from './reception.js';

const validWire = {
  type: 'AcceptAgreement',
  contractVersion: 1,
  commandId: 'cmd-1',
  agreementId: 'agr-1',
  expertId: 'exp-1',
};

describe('pas 1 — Reception (payload → typed Command of the dictionary)', () => {
  it('accepts a valid wire command', () => {
    const result = receiveAgreementCommand(validWire);
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.value.type).toBe('AcceptAgreement');
    }
  });

  it('malformed → violations, convertible to the Exception channel (A-7)', () => {
    const result = receiveAgreementCommand({ type: 'AcceptAgreement' });
    expect(result.ok).toBe(false);
    if (!result.ok) {
      const exception = new AgreementReceptionException(result.error);
      expect(exception.code).toBe('APPLICATION.RECEPTION');
      expect(exception.violations.length).toBeGreaterThan(0);
      expect(exception.message).toContain('CONTRACT.FIELD_MISSING');
    }
  });

  it('remains a tolerant reader (V-2): unknown fields pass', () => {
    expect(receiveAgreementCommand({ ...validWire, futureField: true }).ok).toBe(true);
  });

  it('receives the ratified query', () => {
    const result = receiveAgreementQuery({
      type: 'AgreementStateQuery',
      contractVersion: 1,
      agreementId: 'agr-1',
    });
    expect(result.ok).toBe(true);
  });
});
