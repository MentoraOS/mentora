import type { CommandId } from '@mentora/contracts';

import type { AgreementId, ClientId, ExpertId, OfferId } from '../ids/identifiers.js';
import type { AgreementPartyContract, AgreementSlotContract } from '../wire/fragments.js';

/**
 * The eight PUBLISHED commands of the Agreement (F2.5 §5). Every command is
 * refusable (P4) and carries its ACT IDENTITY (CommandId — reused from the
 * technical core, F4.1 §3).
 *
 * DELIBERATE ABSENCE (A-6, signaled): no instant and no ambient identity on
 * the wire — the Application layer injects the instant (one per execution)
 * and the authenticated ActorRef at pas 2-3; a client-supplied time would be
 * ambient time, which the Constitution forbids. Cross-domain preconditions
 * (the published AvailabilityFrame windows, the translated settlement
 * reference) arrive AS DATA (loi 15), fetched at the sources by the caller.
 */

interface AgreementCommandBase {
  readonly contractVersion: 1;
  readonly commandId: CommandId;
  readonly agreementId: AgreementId;
}

export interface RequestAgreement extends AgreementCommandBase {
  readonly type: 'RequestAgreement';
  readonly clientId: ClientId;
  readonly expertId: ExpertId;
  readonly offerId: OfferId;
  readonly slot: AgreementSlotContract;
  readonly availabilityWindows: readonly AgreementSlotContract[];
}

export interface AcceptAgreement extends AgreementCommandBase {
  readonly type: 'AcceptAgreement';
  readonly expertId: ExpertId;
}

export interface RejectAgreement extends AgreementCommandBase {
  readonly type: 'RejectAgreement';
  readonly expertId: ExpertId;
}

export interface ConfirmAgreement extends AgreementCommandBase {
  readonly type: 'ConfirmAgreement';
  readonly settlementReference: string;
}

export interface RescheduleAgreement extends AgreementCommandBase {
  readonly type: 'RescheduleAgreement';
  readonly requestedBy: AgreementPartyContract;
  readonly newSlot: AgreementSlotContract;
}

export interface CancelAgreement extends AgreementCommandBase {
  readonly type: 'CancelAgreement';
  readonly cancelledBy: AgreementPartyContract;
  readonly motive: string;
}

export interface LapseAgreementRequest extends AgreementCommandBase {
  readonly type: 'LapseAgreementRequest';
}

export interface ElapseAgreement extends AgreementCommandBase {
  readonly type: 'ElapseAgreement';
}

/** The closed union of the published commands (frozen — Titre VII to change). */
export type AgreementCommandContract =
  | RequestAgreement
  | AcceptAgreement
  | RejectAgreement
  | ConfirmAgreement
  | RescheduleAgreement
  | CancelAgreement
  | LapseAgreementRequest
  | ElapseAgreement;

export const AGREEMENT_COMMAND_TYPES = [
  'RequestAgreement',
  'AcceptAgreement',
  'RejectAgreement',
  'ConfirmAgreement',
  'RescheduleAgreement',
  'CancelAgreement',
  'LapseAgreementRequest',
  'ElapseAgreement',
] as const;

export type AgreementCommandType = (typeof AGREEMENT_COMMAND_TYPES)[number];
