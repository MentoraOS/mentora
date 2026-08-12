import type { Instant } from '@mentora/kernel';
import { instantOf } from '@mentora/kernel';

import type { Agreement } from '../aggregate/agreement.js';
import type {
  AcceptAgreement,
  CancelAgreement,
  ConfirmAgreement,
  ElapseAgreement,
  LapseAgreementRequest,
  RejectAgreement,
  RequestAgreement,
  RescheduleAgreement,
} from '../commands/agreement-commands.js';
import { AgreementFactory } from '../factories/agreement-factory.js';
import {
  agreementIdOf,
  clientIdOf,
  commandIdOf,
  expertIdOf,
  offerIdOf,
} from '../ids/identifiers.js';
import type { AgreementParty } from '../value-objects/agreement-party.js';
import type { TimeSlot } from '../value-objects/time-slot.js';

/**
 * Object Mother for tests — builds agreements by REPLAYING REAL ACTS through
 * the real Factory and real commands (never by poking state): the exemplar of
 * how every consumer must drive the unit. Deterministic fixed identities and
 * instants; no clock is ever read (F3.1.99 §5).
 */

export const AGREEMENT_ID = agreementIdOf('agr-0001');
export const CLIENT_ID = clientIdOf('cli-0001');
export const EXPERT_ID = expertIdOf('exp-0001');
export const OFFER_ID = offerIdOf('off-0001');

export const T0: Instant = instantOf(1_000_000);
export const HOUR = 3_600_000;

/** A slot of `durationMs` starting at `startMs`. */
export const slotAt = (startMs: number, durationMs = HOUR): TimeSlot => ({
  start: instantOf(startMs),
  end: instantOf(startMs + durationMs),
});

/** A one-hour slot 48h after T0, inside the broad published window below. */
export const DEFAULT_SLOT = slotAt(T0.epochMillis + 48 * HOUR);
export const PUBLISHED_WINDOWS: readonly TimeSlot[] = [slotAt(T0.epochMillis, 14 * 24 * HOUR)];

export const CLIENT_PARTY: AgreementParty = { role: 'Client', clientId: CLIENT_ID };
export const EXPERT_PARTY: AgreementParty = { role: 'Expert', expertId: EXPERT_ID };

let commandCounter = 0;
const nextCommandId = () => {
  commandCounter += 1;
  return commandIdOf(`cmd-${String(commandCounter).padStart(4, '0')}`);
};

export const requestCommand = (overrides?: Partial<RequestAgreement>): RequestAgreement => ({
  type: 'RequestAgreement',
  commandId: nextCommandId(),
  instant: T0,
  agreementId: AGREEMENT_ID,
  clientId: CLIENT_ID,
  expertId: EXPERT_ID,
  offerId: OFFER_ID,
  slot: DEFAULT_SLOT,
  availabilityWindows: PUBLISHED_WINDOWS,
  ...overrides,
});

export const acceptCommand = (at: Instant): AcceptAgreement => ({
  type: 'AcceptAgreement',
  commandId: nextCommandId(),
  instant: at,
  agreementId: AGREEMENT_ID,
  expertId: EXPERT_ID,
});

export const rejectCommand = (at: Instant): RejectAgreement => ({
  type: 'RejectAgreement',
  commandId: nextCommandId(),
  instant: at,
  agreementId: AGREEMENT_ID,
  expertId: EXPERT_ID,
});

export const confirmCommand = (
  at: Instant,
  settlementReference = 'stl-0001',
): ConfirmAgreement => ({
  type: 'ConfirmAgreement',
  commandId: nextCommandId(),
  instant: at,
  agreementId: AGREEMENT_ID,
  settlementReference,
});

export const rescheduleCommand = (at: Instant, newSlot: TimeSlot): RescheduleAgreement => ({
  type: 'RescheduleAgreement',
  commandId: nextCommandId(),
  instant: at,
  agreementId: AGREEMENT_ID,
  requestedBy: CLIENT_PARTY,
  newSlot,
});

export const cancelCommand = (at: Instant, motive = 'change of plans'): CancelAgreement => ({
  type: 'CancelAgreement',
  commandId: nextCommandId(),
  instant: at,
  agreementId: AGREEMENT_ID,
  cancelledBy: CLIENT_PARTY,
  motive,
});

export const lapseCommand = (at: Instant): LapseAgreementRequest => ({
  type: 'LapseAgreementRequest',
  commandId: nextCommandId(),
  instant: at,
  agreementId: AGREEMENT_ID,
});

export const elapseCommand = (at: Instant): ElapseAgreement => ({
  type: 'ElapseAgreement',
  commandId: nextCommandId(),
  instant: at,
  agreementId: AGREEMENT_ID,
});

const mustOk = <T, E>(result: { ok: true; value: T } | { ok: false; error: E }): T => {
  if (!result.ok) {
    throw new Error(`mother expected ok, got ${JSON.stringify(result.error)}`);
  }
  return result.value;
};

export const requestedAgreement = (): Agreement =>
  mustOk(new AgreementFactory().request(requestCommand()));

export const acceptedAgreement = (): Agreement =>
  mustOk(requestedAgreement().accept(acceptCommand(instantOf(T0.epochMillis + HOUR))));

export const confirmedAgreement = (): Agreement =>
  mustOk(acceptedAgreement().confirm(confirmCommand(instantOf(T0.epochMillis + 2 * HOUR))));
