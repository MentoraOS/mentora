import type { ClientId, ExpertId, OfferId } from '../ids/identifiers.js';
import type {
  AgreementFactContractBase,
  AgreementPartyContract,
  AgreementSlotContract,
} from '../wire/fragments.js';

/**
 * The eight PUBLISHED facts of the Agreement (F2.5 §4 — the frozen Event
 * Dictionary; the owner owns the contract and its generations, V-1).
 *
 * WIRE discipline:
 * - primitive-serializable payloads (instants as epoch milliseconds);
 * - occurredAtMs = the instant of the act (a fact carries its instant,
 *   F3.1.5); Correlation/Causation NEVER appear here — they ride the transport
 *   envelope (M-3: "le fait ignore son transport, à jamais");
 * - contractVersion = the fact's generation (V-2: evolution is ADDITIVE;
 *   consumers are tolerant readers; a rename/removal is a NEW contract, V-3);
 * - fact identity = (agreementId, sequence) — idempotent consumption (loi 14);
 * - no private content, ever (P7).
 *
 * This file contains ONLY facts (MENTORA0003); the union and shared fragments
 * live in ../wire/.
 */

export interface AgreementRequested extends AgreementFactContractBase {
  readonly type: 'AgreementRequested';
  readonly clientId: ClientId;
  readonly expertId: ExpertId;
  readonly offerId: OfferId;
  readonly slot: AgreementSlotContract;
}

export interface AgreementAccepted extends AgreementFactContractBase {
  readonly type: 'AgreementAccepted';
  readonly expertId: ExpertId;
}

export interface AgreementRejected extends AgreementFactContractBase {
  readonly type: 'AgreementRejected';
  readonly expertId: ExpertId;
}

export interface AgreementRequestLapsed extends AgreementFactContractBase {
  readonly type: 'AgreementRequestLapsed';
}

export interface AgreementConfirmed extends AgreementFactContractBase {
  readonly type: 'AgreementConfirmed';
  readonly settlementReference: string;
}

export interface AgreementRescheduled extends AgreementFactContractBase {
  readonly type: 'AgreementRescheduled';
  readonly previousSlot: AgreementSlotContract;
  readonly newSlot: AgreementSlotContract;
  readonly requestedBy: AgreementPartyContract;
}

export interface AgreementCancelled extends AgreementFactContractBase {
  readonly type: 'AgreementCancelled';
  readonly cancelledBy: AgreementPartyContract;
  readonly motive: string;
}

export interface AgreementElapsed extends AgreementFactContractBase {
  readonly type: 'AgreementElapsed';
}
