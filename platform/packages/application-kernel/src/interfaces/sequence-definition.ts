import type { ActorRef, CommandId } from '@mentora/contracts';
import type { Instant, Option, Result } from '@mentora/kernel';

import type {
  SequenceRefusalLike,
  SequenceViolation,
} from '../result/sequence-outcome.js';

/**
 * SequenceDefinition — what a bounded context INJECTS into the generic
 * pipeline. The pipeline does not belong to the domain; the domain is
 * plugged into the pipeline (this interface is the plug).
 *
 * Each member maps to a frozen step and carries its law:
 * - receive        (pas 1)  — delegates to the context's published-language
 *                             validators; violations end the execution.
 * - actIdentityOf  (pas 1)  — the ratified act identity (F4.1 §3) read from
 *                             the wire command, for journal/idempotence.
 * - load           (pas 4)  — the registry, BY IDENTIFIER ONLY (R-A); none
 *                             for birth commands (the Factory births at act).
 * - validate       (pas 5)  — the synchronous source validities (loi 15) AND
 *                             the wire→domain seam: yields the typed domain
 *                             command carrying the validated data + the
 *                             injected instant. Refusals are Decision values.
 * - act            (pas 6)  — the command on the unit (or the Factory birth
 *                             when none was loaded); the unit decides.
 * - retain         (pas 8)  — the atomic registry retention (state + facts in
 *                             the Outbox, one act, talks to no one — A-3);
 *                             the declared R-A key may refuse STRUCTURALLY
 *                             (a motivated Decision, e.g. TimeSlotUnavailable);
 *                             a thrown error is a technical Failure, retryable
 *                             (S-3: an optimistic conflict is a Failure, never
 *                             a Decision).
 */
export interface SequenceDefinition<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike> {
  commandTypeOf(wire: TWire): string;
  actIdentityOf(wire: TWire): CommandId;
  receive(payload: unknown): Result<TWire, readonly SequenceViolation[]>;
  load(wire: TWire): Promise<Option<TUnit>>;
  validate(wire: TWire, instant: Instant, actor: ActorRef): Promise<Result<TCommand, TRefusal>>;
  act(unit: Option<TUnit>, command: TCommand): Result<TUnit, TRefusal>;
  retain(unit: TUnit): Promise<Result<void, TRefusal>>;
}
