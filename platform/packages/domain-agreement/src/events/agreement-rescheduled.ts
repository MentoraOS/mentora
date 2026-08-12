import type { AgreementFactBase } from '../aggregate/agreement-fact-base.js';
import type { RescheduleRecord } from '../value-objects/reschedule-record.js';

/** Frozen fact (F2.5 §4). Reschedule keeps the Agreement Confirmed (F3.3 §8). */
export interface AgreementRescheduled extends AgreementFactBase {
  readonly type: 'AgreementRescheduled';
  readonly record: RescheduleRecord;
}
