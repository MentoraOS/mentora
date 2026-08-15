/**
 * THE SÉQUENCE DE RÉACTION — the six frozen steps (F4.99 §1, born at the
 * Grand Audit), "pour toute consommation de fait (Process Manager ou
 * handler)", verbatim:
 *
 * "1. Réception du fait (Inbox — déduplication par identité de fait) →
 *  2. Injections (corrélation propagée, instant si requis) →
 *  3. Réaction (fonction pure : position/mapping → commandes) →
 *  4. Rétention atomique (marque d'Inbox + position + commandes émises,
 *     une écriture) →
 *  5. Relais (dispatch des commandes, at-least-once) →
 *  6. Journal."
 *
 * Closure law (F4.99 §1): three Sequences — Commande (10), Réaction (6),
 * Lecture (6) — "il n'existe aucun quatrième chemin d'exécution".
 *
 * Constitutional notes per step:
 *  1. FactReception    — payload → typed published fact; malformed →
 *                        Exception, end. The per-consumer INBOX deduplicates
 *                        by FACT IDENTITY (M-4): an already-seen fact is a
 *                        duplicate, absorbed — at-least-once is the law,
 *                        exactly-once an interdicted myth (F2.6 loi 15).
 *  2. Injections       — the propagated CorrelationId (it rides the
 *                        envelope, M-3) and ONE instant if required (A-6:
 *                        injected, never ambient; one per execution).
 *  3. Reaction         — a PURE function: (position, fact) → new position +
 *                        emitted commands. The PM never decides, never
 *                        publishes a fact (P-3: "il commande par le
 *                        Dispatch, et les propriétaires constatent").
 *  4. AtomicRetention  — Inbox mark + position + emitted commands, ONE
 *                        write: the OUTBOX DE COMMANDES (F4.99 §2 — never
 *                        the bare word, never the fact outbox).
 *  5. Relay            — the command-outbox RELAY reads what was retained
 *                        and dispatches at-least-once; in process this step
 *                        is STRUCTURAL (same law as Publication, A-4: the
 *                        relay owns it — a phantom dispatch is impossible
 *                        by construction).
 *  6. Journal          — the execution is journaled under its
 *                        CorrelationId (A-10; Journal ≠ Log, F5.3).
 */

export const REACTION_STEPS = Object.freeze([
  'FactReception',
  'Injections',
  'Reaction',
  'AtomicRetention',
  'Relay',
  'Journal',
] as const);

export type ReactionStep = (typeof REACTION_STEPS)[number];

/** Position of a step in the frozen order (0-based). */
export const reactionStepIndex = (step: ReactionStep): number => REACTION_STEPS.indexOf(step);
