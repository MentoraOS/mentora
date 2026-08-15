import type { CorrelationId } from '@mentora/contracts';
import type { Instant, Option } from '@mentora/kernel';

/**
 * The READ VIEW of one reaction execution — what the Séquence carries and
 * nothing more: the propagated correlation (envelope, M-3), the fact and its
 * identity, the journey key, the ONE injected instant (A-6), the position
 * before the reaction, the emitted commands, the attempt. No ambient state:
 * a Process Manager is "sans mémoire" beyond its retained position (F4.2).
 */
export interface ReactionContext<TFact, TPosition, TCommand> {
  readonly correlationId: CorrelationId;
  readonly factType: string;
  readonly factIdentity: string | undefined;
  readonly journeyKey: string | undefined;
  readonly attempt: number;
  readonly instant: Instant | undefined;
  readonly fact: TFact | undefined;
  readonly position: Option<TPosition> | undefined;
  readonly commands: readonly TCommand[] | undefined;
}
