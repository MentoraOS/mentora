import type { CommandId } from '@mentora/contracts';
import type { Agreement } from '@mentora/domain-agreement';
import {
  AgreementCancellationPolicy,
  AgreementFactory,
  ReschedulePolicy,
  agreementIdOf,
  clientIdOf,
  expertIdOf,
  offerIdOf,
  timeSlotOf,
} from '@mentora/domain-agreement';
import { instantOf } from '@mentora/kernel';

/**
 * AgreementPersistenceMother — units built through REAL domain acts (the
 * house pattern since 1A: the Mother replays acts, never fabricates state).
 * Deterministic instants; policies with generous product parameters.
 */

const HOUR = 3_600_000;
export const MOTHER_T0 = instantOf(1_700_000_000_000);

export interface MotherOptions {
  readonly id?: string;
  readonly expertId?: string;
  readonly clientId?: string;
  readonly slotStartMs?: number;
}

const defaults = (options: MotherOptions) => ({
  id: options.id ?? 'agr-1',
  expertId: options.expertId ?? 'exp-1',
  clientId: options.clientId ?? 'cli-1',
  slotStartMs: options.slotStartMs ?? MOTHER_T0.epochMillis + 10 * HOUR,
});

const unwrap = <T>(result: { ok: boolean; value?: T; error?: unknown }): T => {
  if (!result.ok || result.value === undefined) {
    throw new Error(`the Mother replays valid acts only: ${JSON.stringify(result.error)}`);
  }
  return result.value;
};

export class AgreementPersistenceMother {
  readonly reschedulePolicy = new ReschedulePolicy({
    minimumNoticeMillis: HOUR,
    maximumReschedules: 5,
  });
  readonly cancellationPolicy = new AgreementCancellationPolicy({ minimumNoticeMillis: HOUR });

  requested(options: MotherOptions = {}): Agreement {
    const d = defaults(options);
    const slot = unwrap(timeSlotOf(instantOf(d.slotStartMs), instantOf(d.slotStartMs + HOUR)));
    return unwrap(
      new AgreementFactory().request({
        type: 'RequestAgreement',
        commandId: `cmd-req-${d.id}` as CommandId,
        instant: MOTHER_T0,
        agreementId: agreementIdOf(d.id),
        clientId: clientIdOf(d.clientId),
        expertId: expertIdOf(d.expertId),
        offerId: offerIdOf('off-1'),
        slot,
        availabilityWindows: [
          unwrap(
            timeSlotOf(MOTHER_T0, instantOf(MOTHER_T0.epochMillis + 1_000 * HOUR)),
          ),
        ],
      }),
    );
  }

  accepted(options: MotherOptions = {}): Agreement {
    const d = defaults(options);
    return unwrap(
      this.requested(options).accept({
        type: 'AcceptAgreement',
        commandId: `cmd-acc-${d.id}` as CommandId,
        instant: instantOf(MOTHER_T0.epochMillis + HOUR),
        agreementId: agreementIdOf(d.id),
        expertId: expertIdOf(d.expertId),
      }),
    );
  }

  /** CONTINUATION: accept an already-retained unit (stale-version scenarios). */
  acceptOf(unit: Agreement, options: MotherOptions = {}): Agreement {
    const d = defaults(options);
    return unwrap(
      unit.accept({
        type: 'AcceptAgreement',
        commandId: `cmd-acc2-${d.id}` as CommandId,
        instant: instantOf(MOTHER_T0.epochMillis + HOUR),
        agreementId: agreementIdOf(d.id),
        expertId: expertIdOf(d.expertId),
      }),
    );
  }

  confirmed(options: MotherOptions = {}): Agreement {
    const d = defaults(options);
    return unwrap(
      this.accepted(options).confirm({
        type: 'ConfirmAgreement',
        commandId: `cmd-conf-${d.id}` as CommandId,
        instant: instantOf(MOTHER_T0.epochMillis + 2 * HOUR),
        agreementId: agreementIdOf(d.id),
        settlementReference: 'settlement-1',
      }),
    );
  }
}
