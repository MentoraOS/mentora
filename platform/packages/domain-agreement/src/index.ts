/**
 * @mentora/domain-agreement — public API.
 *
 * The Agreement domain (Engagement bounded context, F3.2-A Domaine 3): the
 * golden path of Mentora. Pure business truth — no framework, no I/O, no
 * adapter (F4.4 I-7). The single public entrypoint; internals are private.
 */

// Identity (opaque, stable — F3.1.99 §4).
export * from './ids/identifiers.js';

// Value Objects (the ratified four + state + party).
export * from './value-objects/time-slot.js';
export * from './value-objects/agreement-conditions.js';
export * from './value-objects/agreement-party.js';
export * from './value-objects/cancellation-record.js';
export * from './value-objects/reschedule-record.js';
export * from './value-objects/agreement-state.js';

// Decisions & exceptions (the refusal doors, F3.1).
export * from './decisions/agreement-refusal.js';
export * from './errors/agreement-exceptions.js';

// The eight frozen facts + union.
export type { AgreementFactBase } from './aggregate/agreement-fact-base.js';
export type { AgreementRequested } from './events/agreement-requested.js';
export type { AgreementAccepted } from './events/agreement-accepted.js';
export type { AgreementRejected } from './events/agreement-rejected.js';
export type { AgreementRequestLapsed } from './events/agreement-request-lapsed.js';
export type { AgreementConfirmed } from './events/agreement-confirmed.js';
export type { AgreementRescheduled } from './events/agreement-rescheduled.js';
export type { AgreementCancelled } from './events/agreement-cancelled.js';
export type { AgreementElapsed } from './events/agreement-elapsed.js';
export type { AgreementDomainEvent } from './aggregate/agreement-domain-event.js';

// The eight frozen commands + union.
export type {
  RequestAgreement,
  AcceptAgreement,
  RejectAgreement,
  ConfirmAgreement,
  RescheduleAgreement,
  CancelAgreement,
  LapseAgreementRequest,
  ElapseAgreement,
  AgreementCommand,
} from './commands/agreement-commands.js';

// Specifications (the three frozen questions).
export * from './specifications/slot-within-frame.specification.js';
export * from './specifications/overlapping-slot.specification.js';
export * from './specifications/confirmable-agreement.specification.js';

// Policies (the four frozen published rules; parameters = product config).
export * from './policies/agreement-cancellation.policy.js';
export * from './policies/reschedule.policy.js';
export * from './policies/agreement-request-lapse.policy.js';
export * from './policies/confirmation.policy.js';

// The unit, its birth door, its registry port, its private photograph.
export { Agreement } from './aggregate/agreement.js';
export { AgreementFactory } from './factories/agreement-factory.js';
export type { AgreementRepository } from './ports/agreement-repository.js';
export type {
  AgreementSnapshot,
  AgreementSnapshotState,
  AgreementSnapshotSlot,
  AgreementSnapshotParty,
  AgreementSnapshotReschedule,
} from './snapshots/agreement-snapshot.js';
