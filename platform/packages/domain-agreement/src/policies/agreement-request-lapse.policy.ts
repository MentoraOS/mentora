import type { Instant } from '@mentora/kernel';
import { instantOf } from '@mentora/kernel';

/**
 * Frozen Policy (F2.5 §6, F2.5.2: AgreementRequestLapsePolicy — la Caducité
 * frappe la DEMANDE, jamais l'Accord ferme). "Le silence a une échéance : la
 * Caducité" (F2.6 [T]). This policy is consumed by the time tooling
 * (Échéancier, F4.2 P-6): it computes WHEN a Demande lapses; the
 * LapseAgreementRequest command then arrives with the instant AS DATA.
 */
export interface AgreementRequestLapsePolicyParams {
  /** How long a Demande may stay unanswered before its Caducité. */
  readonly requestTimeToLiveMillis: number;
}

export class AgreementRequestLapsePolicy {
  constructor(private readonly params: AgreementRequestLapsePolicyParams) {}

  lapsesAt(requestedAt: Instant): Instant {
    return instantOf(requestedAt.epochMillis + this.params.requestTimeToLiveMillis);
  }

  isLapsed(requestedAt: Instant, at: Instant): boolean {
    return at.epochMillis >= this.lapsesAt(requestedAt).epochMillis;
  }
}
