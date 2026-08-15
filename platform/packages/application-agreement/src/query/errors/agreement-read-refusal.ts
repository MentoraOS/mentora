/**
 * The Refusal channel of the Agreement Lecture (A-7: a motivated VALUE,
 * never thrown; F4.1 §5: "refuse motivé si le droit manque"). The other two
 * channels are the shared primitives: violations (Exception, pas 1) and
 * SequenceFailure (technical) from @mentora/application-kernel.
 *
 * SIGNALED (1B precedent — the Reason family of F2.5.2 §20 is not enumerated
 * in the materialized corpus): the two reasons below follow the ratified
 * patterns and await Titre VII:
 * - 'RightMissing'          — R-C verbatim: "si le droit manque";
 * - 'AgreementUnavailable'  — the ratified `-Unavailable` refusal family
 *   (F3.2-A): nothing readable under this Identifier — motivated, never
 *   silence (F2.6).
 */

export type AgreementReadRefusalReason = 'RightMissing' | 'AgreementUnavailable';

export interface AgreementReadRefusal {
  readonly reason: AgreementReadRefusalReason;
  readonly message: string;
}

export const agreementReadRefusal = (
  reason: AgreementReadRefusalReason,
  message: string,
): AgreementReadRefusal => ({ reason, message });
