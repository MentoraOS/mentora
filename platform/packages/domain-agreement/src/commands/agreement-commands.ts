import type { Instant } from '@mentora/kernel';

import type { AgreementId, ClientId, CommandId, ExpertId, OfferId } from '../ids/identifiers.js';
import type { AgreementParty } from '../value-objects/agreement-party.js';
import type { TimeSlot } from '../value-objects/time-slot.js';

/**
 * The eight frozen Commands of the Agreement (F2.5 §5, F3.2-A). Every command:
 * - carries its ACT IDENTITY (commandId — F4.1 §3: replay is deduplicated by
 *   act identity; a deliberate retry is a NEW act);
 * - carries the INJECTED instant (F4.1 A-6: one instant per execution, the
 *   domain only ever judges instants it is given);
 * - carries its cross-domain preconditions AS DATA, validated at the sources
 *   by the Application layer (loi 15) — e.g. the published AvailabilityFrame
 *   windows for RequestAgreement, the translated settlement report reference
 *   for ConfirmAgreement.
 * Every command is refusable (P4) and yields a motivated Decision.
 */

interface AgreementCommandBase {
  readonly commandId: CommandId;
  readonly instant: Instant;
}

/** Client → a Demande targeting a Créneau of the published Cadre (F2.6 [S]). */
export interface RequestAgreement extends AgreementCommandBase {
  readonly type: 'RequestAgreement';
  readonly agreementId: AgreementId;
  readonly clientId: ClientId;
  readonly expertId: ExpertId;
  readonly offerId: OfferId;
  readonly slot: TimeSlot;
  /** The published AvailabilityFrame windows, PROVIDED as data (loi 15). */
  readonly availabilityWindows: readonly TimeSlot[];
}

/** Expert accepts the Demande. */
export interface AcceptAgreement extends AgreementCommandBase {
  readonly type: 'AcceptAgreement';
  readonly agreementId: AgreementId;
  readonly expertId: ExpertId;
}

/** Expert rejects the Demande (Rejected — reserved to Engagement, VD-0046). */
export interface RejectAgreement extends AgreementCommandBase {
  readonly type: 'RejectAgreement';
  readonly agreementId: AgreementId;
  readonly expertId: ExpertId;
}

/**
 * Commissioner of execution confirms, carrying the translated settlement
 * report reference; refusable with ConfirmationConditionsMissing (F3.2-A).
 */
export interface ConfirmAgreement extends AgreementCommandBase {
  readonly type: 'ConfirmAgreement';
  readonly agreementId: AgreementId;
  readonly settlementReference: string;
}

/** A party reschedules a Confirmed agreement, under the published Policy. */
export interface RescheduleAgreement extends AgreementCommandBase {
  readonly type: 'RescheduleAgreement';
  readonly agreementId: AgreementId;
  readonly requestedBy: AgreementParty;
  readonly newSlot: TimeSlot;
}

/** A party cancels a Confirmed agreement; the author is always carried (F2.6). */
export interface CancelAgreement extends AgreementCommandBase {
  readonly type: 'CancelAgreement';
  readonly agreementId: AgreementId;
  readonly cancelledBy: AgreementParty;
  readonly motive: string;
}

/** Time tooling: the Demande's silence has reached its Caducité (instant provided). */
export interface LapseAgreementRequest extends AgreementCommandBase {
  readonly type: 'LapseAgreementRequest';
  readonly agreementId: AgreementId;
}

/** Time tooling: the Confirmed agreement reaches its Échéance (instant provided). */
export interface ElapseAgreement extends AgreementCommandBase {
  readonly type: 'ElapseAgreement';
  readonly agreementId: AgreementId;
}

/** The closed union of the eight frozen commands (F3.3 §4 — catalogue owns it). */
export type AgreementCommand =
  | RequestAgreement
  | AcceptAgreement
  | RejectAgreement
  | ConfirmAgreement
  | RescheduleAgreement
  | CancelAgreement
  | LapseAgreementRequest
  | ElapseAgreement;
