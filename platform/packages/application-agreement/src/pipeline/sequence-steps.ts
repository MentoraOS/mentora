/**
 * THE SÉQUENCE DE COMMANDE — the ten frozen steps, in the ratified order
 * (F4.1 §2, order corrected by F4.1.99: LOADING PRECEDES THE VALIDITIES).
 * "La Séquence est fermée : dix pas, cet ordre, aucun autre" (A-2).
 *
 * This constant IS the architecture of the pipeline: the stages of lot 1C-2
 * implement these steps and no others.
 *
 * Constitutional notes per step:
 *  1. Reception          — payload → typed Command of the dictionary;
 *                          malformed → Exception, end (see validators/).
 *  2. IdentityInjection  — the authenticated ActorRef, injected, never
 *  3. TimeInjection        ambient (A-6); steps 2-3 form the injection BLOCK
 *                          (mutually independent — conventional order,
 *                          F4.1.99).
 *  4. Loading            — the registry, by Identifier, nothing else (R-A);
 *                          BEFORE the validities (F4.1.99: data dependency).
 *  5. SourceValidities   — the R-C queries, synchronous, at the sources
 *                          (loi 15); results become DATA handed to the domain.
 *  6. Act                — the Command on the unit; the unit renders its
 *                          Decision and gives birth to its facts INSIDE.
 *  7. RefusalReturn      — a refusal returns immediately: no retention, no
 *                          fact, correlated journal. A refusal is a SUCCESSFUL
 *                          execution of the contract.
 *  8. AtomicRetention    — the Unit of Work: state + facts in the Outbox in
 *                          ONE atomic registry act; retention TALKS TO NO ONE
 *                          (A-3).
 *  9. Publication        — owned by the OUTBOX RELAY, after retention (A-4):
 *                          the application service NEVER publishes inline —
 *                          phantom publication is impossible by construction.
 * 10. ResponseAndJournal — the Decision returns to the caller; the execution
 *                          is journaled under its CorrelationId (A-10).
 *
 * SIGNALED (mandate ↔ R2): there is NO "ProjectionStage" and no
 * "AuthorizationStage" among the ten steps — projections are updated by
 * consumers of PUBLISHED facts (parallel readers, F4.99), never a step of the
 * act; authorization lives in the dispatch (R-C, A-8) and in the owners' NON
 * (T-9), not as a pipeline stage. R2 wins (règle constitutionnelle).
 */

export const SEQUENCE_STEPS = [
  'Reception',
  'IdentityInjection',
  'TimeInjection',
  'Loading',
  'SourceValidities',
  'Act',
  'RefusalReturn',
  'AtomicRetention',
  'Publication',
  'ResponseAndJournal',
] as const;

export type SequenceStep = (typeof SEQUENCE_STEPS)[number];

/** Position of a step in the frozen order (0-based). */
export const sequenceStepIndex = (step: SequenceStep): number => SEQUENCE_STEPS.indexOf(step);
