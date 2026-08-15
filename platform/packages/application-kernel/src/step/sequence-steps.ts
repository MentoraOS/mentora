/**
 * THE SÉQUENCE DE COMMANDE — the ten frozen steps, in the ratified order
 * (F4.1 §2, corrected by F4.1.99: LOADING PRECEDES THE VALIDITIES).
 * "La Séquence est fermée : dix pas, cet ordre, aucun autre" (A-2).
 *
 * THE canonical definition for the whole platform: every application-<context>
 * package executes THESE steps through this kernel — Agreement is only the
 * first user. The array is frozen at runtime: the order is not changeable.
 *
 *  1. Reception          — payload → typed Command of the dictionary;
 *                          malformed → Exception, end.
 *  2. IdentityInjection  — the authenticated ActorRef, injected (A-6).
 *  3. TimeInjection      — ONE instant captured for the whole execution
 *                          (steps 2-3 form the injection block — mutually
 *                          independent, conventional order, F4.1.99).
 *  4. Loading            — the registry, by Identifier, nothing else (R-A);
 *                          BEFORE the validities (F4.1.99).
 *  5. SourceValidities   — the R-C reads, synchronous, at the sources
 *                          (loi 15); their results become DATA for the domain.
 *  6. Act                — the Command on the unit; the unit renders its
 *                          Decision and gives birth to its facts inside.
 *  7. RefusalReturn      — a refusal returns immediately: no retention, no
 *                          fact, correlated journal (a refusal is a SUCCESSFUL
 *                          execution of the contract).
 *  8. AtomicRetention    — state + facts in the Outbox in ONE atomic registry
 *                          act; retention TALKS TO NO ONE (A-3).
 *  9. Publication        — owned by the OUTBOX RELAY (A-4): the service never
 *                          publishes inline; in-process this step is
 *                          structural (documented, journaled, no I/O).
 * 10. ResponseAndJournal — the Decision returns; the execution is journaled
 *                          under its CorrelationId (A-10).
 *
 * No AuthorizationStage (authorization = dispatch R-C/A-8 + the owners' NON,
 * T-9) and no ProjectionStage (projections consume PUBLISHED facts — parallel
 * readers, F4.99) exist. R2 wins.
 */

export const SEQUENCE_STEPS = Object.freeze([
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
] as const);

export type SequenceStep = (typeof SEQUENCE_STEPS)[number];

/** Position of a step in the frozen order (0-based). */
export const sequenceStepIndex = (step: SequenceStep): number => SEQUENCE_STEPS.indexOf(step);
