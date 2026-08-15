import type { ActorRef } from '@mentora/contracts';
import type { Option, Result } from '@mentora/kernel';

import type { SequenceRefusalLike, SequenceViolation } from '../result/sequence-outcome.js';

/**
 * What a context INJECTS into the Séquence de Lecture — the read twin of
 * SequenceDefinition (1C-2). The pipeline does not belong to any domain: the
 * definition is the plug; the six frozen steps stay generic.
 *
 * The definition brings NO business logic: reception delegates to the
 * published language; the rights grid is DECLARED (catalogue F3.3 §5) and
 * applied on the injected identity (F4.1 §5); the reading is a port call;
 * the response is a pure mapping — a read never decides.
 */
export interface ReadDefinition<
  TQuery,
  TView,
  TResponse,
  TRefusal extends SequenceRefusalLike,
> {
  /** The dictionary name of the query this reader carries (one per reader). */
  queryTypeOf(wire: TQuery): string;

  /** Pas 1 — payload → typed Query of the dictionary; malformed → violations. */
  receive(payload: unknown): Result<TQuery, readonly SequenceViolation[]>;

  /**
   * Pas 3 — R-C: the DECLARED rights grid of this query, applied on the
   * injected identity: "identifie l'ayant droit depuis l'identité injectée,
   * refuse motivé si le droit manque" (F4.1 §5). The grid's mechanism lives
   * below its port (I-12); the sequence only applies the declared entry.
   */
  entitled(query: TQuery, actor: ActorRef): Promise<Result<void, TRefusal>>;

  /** Pas 4 — the lecture: Read Model or source (F4.1 §5), via the port. */
  read(query: TQuery): Promise<Option<TView>>;

  /** Nothing readable under this query: the motivated refusal (never silence, F2.6). */
  absent(query: TQuery): TRefusal;

  /** Pas 5 — the PURE mapping view → published response; the domain never exits directly. */
  respond(view: TView): TResponse;
}
