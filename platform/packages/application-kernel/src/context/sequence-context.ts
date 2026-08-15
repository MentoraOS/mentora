import type { ActorRef, CommandId, CorrelationId } from '@mentora/contracts';
import type { Instant } from '@mentora/kernel';

/**
 * SequenceContext — what one execution transports, and NOTHING more: the
 * correlation, the injected actor/instant/act-identity (A-6: injected, never
 * ambient), the received wire command, the validated domain command, the
 * unit, and the retry metadata. No business logic lives here — the context is
 * a typed record threaded through the stages by the executor.
 */
export interface SequenceContext<TWire, TCommand, TUnit> {
  readonly correlationId: CorrelationId;
  readonly commandType: string;
  /** 1-based attempt; retries re-enter at Loading (pas 4). */
  readonly attempt: number;
  readonly actor: ActorRef | undefined;
  readonly instant: Instant | undefined;
  readonly commandId: CommandId | undefined;
  readonly wire: TWire | undefined;
  readonly command: TCommand | undefined;
  readonly unit: TUnit | undefined;
}
