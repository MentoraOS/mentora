import type { Instant, Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';
import { durationBetweenMillis } from '@mentora/shared';

import type { AgreementRefusal } from '../decisions/agreement-refusal.js';
import { agreementRefusal } from '../decisions/agreement-refusal.js';

/**
 * Frozen Policy (F2.5 §6, F3.3 §6: AgreementCancellationPolicy). "Toute
 * Annulation … subit les règles publiées" (F2.6). Published in advance; its
 * parameters are PRODUCT CONFIGURATION (F3.1: Policy Objects; F4.4 I-5),
 * injected at the composition root — no default is hardcoded here.
 */
export interface AgreementCancellationPolicyParams {
  /** Minimum notice before the slot start for a cancellation to be admitted. */
  readonly minimumNoticeMillis: number;
}

export class AgreementCancellationPolicy {
  constructor(private readonly params: AgreementCancellationPolicyParams) {}

  decide(slotStart: Instant, at: Instant): Result<void, AgreementRefusal> {
    const notice = durationBetweenMillis(at, slotStart);
    return notice >= this.params.minimumNoticeMillis
      ? ok(undefined)
      : err(
          agreementRefusal(
            'CancellationWindowClosed',
            'The published cancellation rules refuse a cancellation this close to the slot',
          ),
        );
  }
}
