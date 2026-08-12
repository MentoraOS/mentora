import type { Instant, Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';
import { durationBetweenMillis } from '@mentora/shared';

import type { AgreementRefusal } from '../decisions/agreement-refusal.js';
import { agreementRefusal } from '../decisions/agreement-refusal.js';

/**
 * Frozen Policy (F2.5 §6, F3.3 §6: ReschedulePolicy — ratified single-stem
 * name). Parameters are product configuration, injected (F4.4 I-5).
 */
export interface ReschedulePolicyParams {
  readonly minimumNoticeMillis: number;
  readonly maximumReschedules: number;
}

export class ReschedulePolicy {
  constructor(private readonly params: ReschedulePolicyParams) {}

  decide(
    slotStart: Instant,
    at: Instant,
    reschedulesSoFar: number,
  ): Result<void, AgreementRefusal> {
    if (reschedulesSoFar >= this.params.maximumReschedules) {
      return err(
        agreementRefusal('RescheduleLimitReached', 'The published reschedule limit is reached'),
      );
    }
    const notice = durationBetweenMillis(at, slotStart);
    return notice >= this.params.minimumNoticeMillis
      ? ok(undefined)
      : err(
          agreementRefusal(
            'RescheduleWindowClosed',
            'The published reschedule rules refuse a change this close to the slot',
          ),
        );
  }
}
