import type { ServerBootFailure } from '../bootstrap/server-bootstrap.js';

/**
 * The boot report — F4.4 §7's discipline made readable: EVERY violation or
 * proof failure, listed, then death once. Never only the first error.
 */
export const renderBootReport = (failure: ServerBootFailure): string => {
  if (failure.kind === 'configuration') {
    return [
      'BOOT REFUSED — configuration invalid (F4.4 §6: "mourir immédiatement"):',
      ...failure.violations.map(
        (violation) => `  - [${violation.code}] ${violation.key}: ${violation.message}`,
      ),
    ].join('\n');
  }
  return [
    'BOOT REFUSED — a proof is missing (R-5: "une seule preuve manquante et il meurt"):',
    ...failure.failures.map((message) => `  - ${message}`),
  ].join('\n');
};
