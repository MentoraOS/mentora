/**
 * RetentionContext — RFC-001 (Titre VII, Option A RATIFIED 2026-08-18): the
 * OPTIONAL second parameter of every registry port's `retain`. It carries
 * ENVELOPE values only — correlation, causation, trace — so the Outbox de
 * faits born in the same atomic act (A-3) can transport them end to end
 * ("corrélation portée quand elle existe", F5.3 §2; "aucune perte").
 *
 * NEVER domain truth: opaque identifiers, no business meaning, no secret
 * material. The facts themselves stay pure (A-9: the envelope carries the
 * correlation, never the fact). Additive migration: `retain(unit)` remains
 * valid — an absent context writes what today writes (NULL columns).
 */
export interface RetentionContext {
  readonly correlationId?: string;
  readonly causationId?: string;
  readonly traceparent?: string;
}
