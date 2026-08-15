import type {
  CancelAgreement as CancelAgreementContract,
  RequestAgreement as RequestAgreementContract,
} from '@mentora/contracts-agreement';
import { AgreementIdentifierBlankException } from '@mentora/domain-agreement';
import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';


import {
  toCancelAgreement,
  toElapseAgreement,
  toRequestAgreement,
} from './agreement-command-factory.js';

const T = instantOf(5_000_000);

const wireRequest: RequestAgreementContract = {
  type: 'RequestAgreement',
  contractVersion: 1,
  commandId: 'cmd-1' as RequestAgreementContract['commandId'],
  agreementId: 'agr-1' as RequestAgreementContract['agreementId'],
  clientId: 'cli-1' as RequestAgreementContract['clientId'],
  expertId: 'exp-1' as RequestAgreementContract['expertId'],
  offerId: 'off-1' as RequestAgreementContract['offerId'],
  slot: { startMs: 2_000_000, endMs: 3_000_000 },
  availabilityWindows: [{ startMs: 0, endMs: 9_000_000 }],
};

describe('the wire → domain seam (injected instant, VO doors)', () => {
  it('maps RequestAgreement: ids pass through, slots become VOs, instant injected', () => {
    const result = toRequestAgreement(wireRequest, T);
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.value.agreementId).toBe('agr-1');
      expect(result.value.instant).toBe(T);
      expect(result.value.slot.start.epochMillis).toBe(2_000_000);
      expect(result.value.slot.end.epochMillis).toBe(3_000_000);
      expect(result.value.availabilityWindows).toHaveLength(1);
    }
  });

  it('inverted wire slot bounds are refused at the VO door (F3.1)', () => {
    const inverted = { ...wireRequest, slot: { startMs: 3_000_000, endMs: 2_000_000 } };
    const result = toRequestAgreement(inverted, T);
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error.reason).toBe('SlotBoundsInvalid');
    }
  });

  it('an invalid published window is refused too', () => {
    const badWindow = { ...wireRequest, availabilityWindows: [{ startMs: 5, endMs: 5 }] };
    expect(toRequestAgreement(badWindow, T).ok).toBe(false);
  });

  it('maps a wire party to a branded domain party', () => {
    const wireCancel: CancelAgreementContract = {
      type: 'CancelAgreement',
      contractVersion: 1,
      commandId: 'cmd-2' as CancelAgreementContract['commandId'],
      agreementId: 'agr-1' as CancelAgreementContract['agreementId'],
      cancelledBy: { role: 'Client', id: 'cli-1' },
      motive: 'change of plans',
    };
    const command = toCancelAgreement(wireCancel, T);
    expect(command.cancelledBy.role).toBe('Client');
    if (command.cancelledBy.role === 'Client') {
      expect(command.cancelledBy.clientId).toBe('cli-1');
    }
    expect(command.instant).toBe(T);
  });

  it('a blank id inside a wire party is a malformed call — Exception channel (A-7)', () => {
    const wireCancel: CancelAgreementContract = {
      type: 'CancelAgreement',
      contractVersion: 1,
      commandId: 'cmd-3' as CancelAgreementContract['commandId'],
      agreementId: 'agr-1' as CancelAgreementContract['agreementId'],
      cancelledBy: { role: 'Expert', id: '   ' },
      motive: 'x',
    };
    expect(() => toCancelAgreement(wireCancel, T)).toThrow(AgreementIdentifierBlankException);
  });

  it('time-tooling commands carry the injected instant only (A-6)', () => {
    const command = toElapseAgreement(
      {
        type: 'ElapseAgreement',
        contractVersion: 1,
        commandId: 'cmd-4' as CancelAgreementContract['commandId'],
        agreementId: 'agr-1' as CancelAgreementContract['agreementId'],
      },
      T,
    );
    expect(command.instant).toBe(T);
    expect(command.type).toBe('ElapseAgreement');
  });
});
