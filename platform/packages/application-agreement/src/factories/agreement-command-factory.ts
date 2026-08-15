
import type {
  AcceptAgreement as AcceptAgreementContract,
  AgreementPartyContract,
  AgreementSlotContract,
  CancelAgreement as CancelAgreementContract,
  ConfirmAgreement as ConfirmAgreementContract,
  ElapseAgreement as ElapseAgreementContract,
  LapseAgreementRequest as LapseAgreementRequestContract,
  RejectAgreement as RejectAgreementContract,
  RequestAgreement as RequestAgreementContract,
  RescheduleAgreement as RescheduleAgreementContract,
} from '@mentora/contracts-agreement';
import type {
  AcceptAgreement,
  AgreementParty,
  AgreementRefusal,
  CancelAgreement,
  ConfirmAgreement,
  ElapseAgreement,
  LapseAgreementRequest,
  RejectAgreement,
  RequestAgreement,
  RescheduleAgreement,
  TimeSlot,
} from '@mentora/domain-agreement';
import { clientIdOf, expertIdOf, timeSlotOf } from '@mentora/domain-agreement';
import { instantOf, ok } from '@mentora/kernel';
import type { Instant, Result } from '@mentora/kernel';

/**
 * The wire → domain seam (the mapping Phase 1B deferred to the application
 * layer). Each function takes the PUBLISHED command and the INJECTED instant
 * (pas 2-3, A-6: one instant per execution — the wire never carries time) and
 * builds the domain command the unit understands.
 *
 * Discipline:
 * - identifiers pass through UNCHANGED (same branded types — the single
 *   definition lives in the published language since Phase 1B);
 * - epoch-ms slots become TimeSlot VOs through the VO door (timeSlotOf —
 *   invalid bounds are a motivated Refusal, F3.1);
 * - a blank id inside a wire party is a MALFORMED CALL: the domain's guard
 *   throws (the Exception channel, A-7) — never silently accepted.
 */

const slotFromWire = (slot: AgreementSlotContract): Result<TimeSlot, AgreementRefusal> =>
  timeSlotOf(instantOf(slot.startMs), instantOf(slot.endMs));

const partyFromWire = (party: AgreementPartyContract): AgreementParty =>
  party.role === 'Client'
    ? { role: 'Client', clientId: clientIdOf(party.id) }
    : { role: 'Expert', expertId: expertIdOf(party.id) };

export const toRequestAgreement = (
  wire: RequestAgreementContract,
  instant: Instant,
): Result<RequestAgreement, AgreementRefusal> => {
  const slot = slotFromWire(wire.slot);
  if (!slot.ok) {
    return slot;
  }
  const windows: TimeSlot[] = [];
  for (const window of wire.availabilityWindows) {
    const mapped = slotFromWire(window);
    if (!mapped.ok) {
      return mapped;
    }
    windows.push(mapped.value);
  }
  return ok({
    type: 'RequestAgreement',
    commandId: wire.commandId,
    instant,
    agreementId: wire.agreementId,
    clientId: wire.clientId,
    expertId: wire.expertId,
    offerId: wire.offerId,
    slot: slot.value,
    availabilityWindows: windows,
  });
};

export const toAcceptAgreement = (
  wire: AcceptAgreementContract,
  instant: Instant,
): AcceptAgreement => ({
  type: 'AcceptAgreement',
  commandId: wire.commandId,
  instant,
  agreementId: wire.agreementId,
  expertId: wire.expertId,
});

export const toRejectAgreement = (
  wire: RejectAgreementContract,
  instant: Instant,
): RejectAgreement => ({
  type: 'RejectAgreement',
  commandId: wire.commandId,
  instant,
  agreementId: wire.agreementId,
  expertId: wire.expertId,
});

export const toConfirmAgreement = (
  wire: ConfirmAgreementContract,
  instant: Instant,
): ConfirmAgreement => ({
  type: 'ConfirmAgreement',
  commandId: wire.commandId,
  instant,
  agreementId: wire.agreementId,
  settlementReference: wire.settlementReference,
});

export const toRescheduleAgreement = (
  wire: RescheduleAgreementContract,
  instant: Instant,
): Result<RescheduleAgreement, AgreementRefusal> => {
  const newSlot = slotFromWire(wire.newSlot);
  if (!newSlot.ok) {
    return newSlot;
  }
  return ok({
    type: 'RescheduleAgreement',
    commandId: wire.commandId,
    instant,
    agreementId: wire.agreementId,
    requestedBy: partyFromWire(wire.requestedBy),
    newSlot: newSlot.value,
  });
};

export const toCancelAgreement = (
  wire: CancelAgreementContract,
  instant: Instant,
): CancelAgreement => ({
  type: 'CancelAgreement',
  commandId: wire.commandId,
  instant,
  agreementId: wire.agreementId,
  cancelledBy: partyFromWire(wire.cancelledBy),
  motive: wire.motive,
});

export const toLapseAgreementRequest = (
  wire: LapseAgreementRequestContract,
  instant: Instant,
): LapseAgreementRequest => ({
  type: 'LapseAgreementRequest',
  commandId: wire.commandId,
  instant,
  agreementId: wire.agreementId,
});

export const toElapseAgreement = (
  wire: ElapseAgreementContract,
  instant: Instant,
): ElapseAgreement => ({
  type: 'ElapseAgreement',
  commandId: wire.commandId,
  instant,
  agreementId: wire.agreementId,
});
