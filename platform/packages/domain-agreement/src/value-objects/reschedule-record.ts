import type { Instant } from '@mentora/kernel';

import type { AgreementParty } from './agreement-party.js';
import type { TimeSlot } from './time-slot.js';

/** RescheduleRecord — ratified VO (F3.2-A). */
export interface RescheduleRecord {
  readonly previousSlot: TimeSlot;
  readonly newSlot: TimeSlot;
  readonly requestedBy: AgreementParty;
  readonly instant: Instant;
}
