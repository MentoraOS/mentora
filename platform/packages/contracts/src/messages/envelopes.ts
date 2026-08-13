import type { Brand } from '@mentora/kernel';

import type { CorrelationId } from '../types/cross-cutting.js';

/**
 * The TRANSPORT ENVELOPES — the code form of F4.3 M-3: "l'enveloppe et le fait
 * sont deux couches — corrélation, causalité, tentatives et clés opaques à
 * l'enveloppe ; le fait ignore son transport, à jamais." Correlation/causation
 * NEVER contaminate a published fact or command; they ride here.
 *
 * Transversal by law (M-3 governs every domain), therefore owned by the
 * technical core — a per-domain envelope would be a forbidden duplicate.
 */

/** The fact/command that caused this message (the causal thread — F4.3). */
export type CausationId = Brand<string, 'CausationId'>;

export interface EnvelopeMetadata {
  readonly correlationId: CorrelationId;
  /** Present when this message was caused by another (reactions, processes). */
  readonly causationId?: CausationId;
  /** Delivery attempt count (at-least-once; consumption stays idempotent, M-4). */
  readonly attempt?: number;
}

export interface CommandEnvelope<TCommand> {
  readonly kind: 'command';
  readonly metadata: EnvelopeMetadata;
  readonly message: TCommand;
}

export interface EventEnvelope<TEvent> {
  readonly kind: 'event';
  readonly metadata: EnvelopeMetadata;
  readonly message: TEvent;
}

export interface QueryEnvelope<TQuery> {
  readonly kind: 'query';
  readonly metadata: EnvelopeMetadata;
  readonly message: TQuery;
}

export const commandEnvelopeOf = <TCommand>(
  message: TCommand,
  metadata: EnvelopeMetadata,
): CommandEnvelope<TCommand> => ({ kind: 'command', metadata, message });

export const eventEnvelopeOf = <TEvent>(
  message: TEvent,
  metadata: EnvelopeMetadata,
): EventEnvelope<TEvent> => ({ kind: 'event', metadata, message });

export const queryEnvelopeOf = <TQuery>(
  message: TQuery,
  metadata: EnvelopeMetadata,
): QueryEnvelope<TQuery> => ({ kind: 'query', metadata, message });
