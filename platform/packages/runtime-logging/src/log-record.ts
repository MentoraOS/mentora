import type { LogFields, LogLevel } from '@mentora/shared';

/**
 * The structured Log record — F5.3 §2: "le Log — le nom officiel de
 * l'émission TECHNIQUE (Runtime, adapters, moteurs) — perdable et borné."
 * Common emission laws (F5.3 §2, verbatim): "aucune matière, aucun secret
 * (P7), corrélation portée quand elle existe, horodatage de la couche
 * émettrice. Les « événements techniques » sont des Logs structurés, jamais
 * des Domain Events." The Log is FOREVER distinct from the applicative
 * Journal (probant, F4.1) — this package never touches a Journal.
 *
 * Levels are an ENGINEERING convention (the canon defines severity only for
 * Alerts) — reused from the shared Logger contract (0B), not legislated.
 */
export interface LogRecord {
  readonly level: LogLevel;
  readonly message: string;
  /** Bound context (executable, component, correlation WHEN it exists). */
  readonly context: LogFields;
  /** Call-site fields — identifiers and codes, never a matter, never a secret. */
  readonly fields: LogFields;
  /** Timestamp of the emitting layer (F5.3 §2). */
  readonly occurredAtMs: number;
}

export const LOG_LEVEL_ORDER: Readonly<Record<LogLevel, number>> = {
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
};
