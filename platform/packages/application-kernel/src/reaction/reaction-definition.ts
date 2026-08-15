import type { Instant, Option, Result } from '@mentora/kernel';

import type { SequenceViolation } from '../result/sequence-outcome.js';

/**
 * What a journey INJECTS into the Séquence de Réaction — the reaction twin
 * of SequenceDefinition (1C-2) and ReadDefinition (1C-4). The pipeline
 * belongs to no domain and to no journey: the definition is the plug.
 *
 * The definition carries the journey's seams and its PURE reaction:
 * - reception delegates to the PUBLISHED language of the fact's owner
 *   (facts circulate as published contracts — F4.3);
 * - the Inbox and the position live behind the journey's own store seams
 *   (per-consumer Inbox — M-4; the position is the PM's ONLY memory,
 *   F4.2: "mémoire de position", passes the pardon test);
 * - the reaction is a PURE, DETERMINISTIC function (F4.2: the reaction is
 *   atomic and deterministic): (position, fact, instant) → new position +
 *   emitted commands. It never decides (decisions live in Aggregates),
 *   never publishes a fact (P-3), never talks to another journey (P-10).
 */

/** What the pure reaction yields: the new position and the commands to emit. */
export interface ReactionResult<TPosition, TCommand> {
  readonly position: TPosition;
  readonly commands: readonly TCommand[];
}

export interface ReactionDefinition<TFact, TPosition, TCommand> {
  /** The dictionary name of the published fact (for routing and the journal). */
  factTypeOf(fact: TFact): string;

  /** The FACT IDENTITY the Inbox deduplicates by (M-4) — an opaque key. */
  factIdentityOf(fact: TFact): string;

  /** The journey key this fact belongs to (one position per journey unit). */
  journeyKeyOf(fact: TFact): string;

  /** Pas 1 — payload → typed published fact; malformed → violations. */
  receive(payload: unknown): Result<TFact, readonly SequenceViolation[]>;

  /** Pas 1 — the per-consumer Inbox: has this fact identity been retained? */
  seen(factIdentity: string): Promise<boolean>;

  /** Before pas 3 — the journey position, by key, nothing else. */
  positionOf(journeyKey: string): Promise<Option<TPosition>>;

  /**
   * Pas 3 — the PURE reaction: position + fact (+ the ONE injected instant)
   * → new position + emitted commands. Deterministic; no I/O; no decision.
   */
  react(position: Option<TPosition>, fact: TFact, instant: Instant): ReactionResult<TPosition, TCommand>;

  /**
   * Pas 4 — the atomic retention: Inbox mark + position + emitted commands
   * in ONE write (the Outbox de commandes, F4.99 §2). Talks to no one.
   */
  retain(
    factIdentity: string,
    journeyKey: string,
    result: ReactionResult<TPosition, TCommand>,
  ): Promise<void>;
}
