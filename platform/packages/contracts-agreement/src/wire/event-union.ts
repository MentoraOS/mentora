import type {
  AgreementAccepted,
  AgreementCancelled,
  AgreementConfirmed,
  AgreementElapsed,
  AgreementRejected,
  AgreementRequestLapsed,
  AgreementRequested,
  AgreementRescheduled,
} from '../events/agreement-event-contracts.js';

/** The closed union of the published facts (frozen — Titre VII to change). */
export type AgreementEventContract =
  | AgreementRequested
  | AgreementAccepted
  | AgreementRejected
  | AgreementRequestLapsed
  | AgreementConfirmed
  | AgreementRescheduled
  | AgreementCancelled
  | AgreementElapsed;

export const AGREEMENT_EVENT_TYPES = [
  'AgreementRequested',
  'AgreementAccepted',
  'AgreementRejected',
  'AgreementRequestLapsed',
  'AgreementConfirmed',
  'AgreementRescheduled',
  'AgreementCancelled',
  'AgreementElapsed',
] as const;

export type AgreementEventType = (typeof AGREEMENT_EVENT_TYPES)[number];
