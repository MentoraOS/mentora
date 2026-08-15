/**
 * THE SÉQUENCE DE LECTURE — the six frozen steps (F4.99 §1, born at the Grand
 * Audit): "réception → identité → R-C → lecture → réponse → journal".
 *
 * Closure law (F4.99 §1): "Toute exécution dans Mentora est l'une des TROIS
 * Séquences — Commande (10 pas), Réaction (6 pas), Lecture (6 pas). Il
 * n'existe aucun quatrième chemin d'exécution."
 *
 * Constitutional notes per step:
 *  1. Reception          — payload → typed Query of the dictionary; malformed
 *                          → Exception, end (published-language validation).
 *  2. IdentityInjection  — the authenticated ActorRef, injected, never
 *                          ambient (A-6). NO TimeInjection: the frozen six
 *                          have no time step — a read never captures an
 *                          instant (and never reads a clock ambiently).
 *  3. RightsCheck        — R-C: the DECLARED rights grid of this query
 *                          (catalogue F3.3 §5), applied on the injected
 *                          identity; "refuse motivé si le droit manque"
 *                          (F4.1 §5). A refusal is a VALUE.
 *  4. Reading            — the lecture: Read Model or source (F4.1 §5) via
 *                          the injected port. Never a mutation, never a
 *                          retention, never a publication.
 *  5. Response           — the mapping view → published response; the domain
 *                          never exits directly.
 *  6. Journal            — the execution is journaled under its
 *                          CorrelationId (A-10; Journal ≠ Log, F5.3).
 */

export const READ_STEPS = Object.freeze([
  'Reception',
  'IdentityInjection',
  'RightsCheck',
  'Reading',
  'Response',
  'Journal',
] as const);

export type ReadStep = (typeof READ_STEPS)[number];

/** Position of a step in the frozen order (0-based). */
export const readStepIndex = (step: ReadStep): number => READ_STEPS.indexOf(step);
