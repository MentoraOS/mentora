import type { AgreementAccepted } from '../events/agreement-accepted.js';
import type { AgreementCancelled } from '../events/agreement-cancelled.js';
import type { AgreementConfirmed } from '../events/agreement-confirmed.js';
import type { AgreementElapsed } from '../events/agreement-elapsed.js';
import type { AgreementRejected } from '../events/agreement-rejected.js';
import type { AgreementRequestLapsed } from '../events/agreement-request-lapsed.js';
import type { AgreementRequested } from '../events/agreement-requested.js';
import type { AgreementRescheduled } from '../events/agreement-rescheduled.js';

/**
 * The closed union of the eight frozen Agreement facts (F2.5 §4 — the Event
 * Dictionary owns the enumeration; nothing may be added outside Titre VII).
 * "Fait → DomainEvent" (F2.5 §8 Type Dictionary).
 */
export type AgreementDomainEvent =
  | AgreementRequested
  | AgreementAccepted
  | AgreementRejected
  | AgreementRequestLapsed
  | AgreementConfirmed
  | AgreementRescheduled
  | AgreementCancelled
  | AgreementElapsed;
