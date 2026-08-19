import type { CommandDispatch, QueryDispatch } from '@mentora/application-kernel';
import type { ActorRef, CorrelationId } from '@mentora/contracts';
import type { IdGenerator } from '@mentora/kernel';

import type { HttpReply } from './http-mapping.js';
import {
  commandOutcomeReply,
  notFoundReply,
  readOutcomeReply,
  unauthenticatedReply,
} from './http-mapping.js';
import type { SessionGate } from './session-gate.js';

/**
 * GatewayRouter — the ENTERING adapter of this executable (I-12: its unique
 * mouth is the Dispatch — no domain port is ever touched here; the graph
 * stays acyclic by construction). Three surfaces, three closed tables:
 *
 *   POST /entry/open-session  — the UNAUTHENTICATED vestibule act: the act
 *     of entry itself (a session cannot be required to open a session).
 *     The ONLY command admitted here is OpenSession — a closed list. The
 *     actor injected is the CLAIMED proof reference (the wire's
 *     credentialId, opaque): the act itself is the verification — the
 *     policy judges the presented proof, the registry holds the chain.
 *
 *   POST /commands — the AUTHENTICATED command surface: the SessionGate
 *     verifies the chain of proof and injects the PERSON's ActorRef
 *     (M-9: session-bounded; business rights stay at the dispatch and
 *     the owners). Commands admitted: the closed table the composition
 *     declared. EstablishCredential/RevokeCredential and the session
 *     verbs are NOT admitted here — their emitters await the RFC-002
 *     instruction (emitter rights) and the Account ACL (Sprint 4);
 *     an un-admitted command is 404, a closed door, never a Refusal.
 *
 *   POST /queries — the AUTHENTICATED read surface: same gate, then the
 *     QueryDispatch; R-C rights grids are judged by the READERS (R-C at
 *     the owner), never here.
 *
 * Correlation (RFC-001/M-3): the entering adapter accepts the caller's
 * x-mentora-correlation or MINTS one; it rides the SequenceInput, the
 * journals, the retention (pas 8) and the Outbox de faits — and is echoed
 * back in the response header ("aucune perte", F5.3 §2).
 */

export interface GatewayRequest {
  readonly method: string;
  readonly url: string;
  readonly headers: Readonly<Record<string, string | string[] | undefined>>;
  readonly body: string;
}

export interface GatewayReply extends HttpReply {
  readonly correlationId: string;
}

const single = (value: string | string[] | undefined): string | undefined =>
  Array.isArray(value) ? value[0] : value;

export class GatewayRouter {
  constructor(
    private readonly gate: SessionGate,
    private readonly commands: CommandDispatch,
    private readonly queries: QueryDispatch,
    private readonly identityCommands: CommandDispatch,
    private readonly correlationIds: IdGenerator,
    /** The closed list of commands the AUTHENTICATED surface admits. */
    private readonly admittedCommands: ReadonlySet<string>,
  ) {}

  /** undefined = not a gateway surface (the caller keeps its 404). */
  async handle(request: GatewayRequest): Promise<GatewayReply | undefined> {
    if (request.method !== 'POST') {
      return undefined;
    }
    const correlationId =
      single(request.headers['x-mentora-correlation']) ?? this.correlationIds.generate();
    const reply = await this.route(request, correlationId as CorrelationId);
    return reply === undefined ? undefined : { ...reply, correlationId };
  }

  private async route(
    request: GatewayRequest,
    correlationId: CorrelationId,
  ): Promise<HttpReply | undefined> {
    const payload = parse(request.body);
    switch (request.url) {
      case '/entry/open-session': {
        if (!isType(payload, 'OpenSession')) {
          return notFoundReply(); // the entry admits ONE act — a closed door.
        }
        const claimed = claimedCredential(payload);
        return commandOutcomeReply(
          await this.identityCommands.dispatch({
            payload,
            actor: claimed as ActorRef,
            correlationId,
          }),
        );
      }
      case '/commands': {
        const verdict = await this.gate.verify(single(request.headers['x-mentora-session']));
        if (verdict.kind === 'unauthenticated') {
          return unauthenticatedReply(verdict.detail);
        }
        if (!isAdmitted(payload, this.admittedCommands)) {
          return notFoundReply(); // outside the closed table — a closed door.
        }
        return commandOutcomeReply(
          await this.commands.dispatch({ payload, actor: verdict.actor, correlationId }),
        );
      }
      case '/queries': {
        const verdict = await this.gate.verify(single(request.headers['x-mentora-session']));
        if (verdict.kind === 'unauthenticated') {
          return unauthenticatedReply(verdict.detail);
        }
        return readOutcomeReply(
          await this.queries.dispatch({ payload, actor: verdict.actor, correlationId }),
        );
      }
      default:
        return undefined;
    }
  }
}

const parse = (body: string): unknown => {
  try {
    return JSON.parse(body) as unknown;
  } catch {
    return body; // the dispatch's reception voices the violation lawfully.
  }
};

const isType = (payload: unknown, type: string): boolean =>
  typeof payload === 'object' &&
  payload !== null &&
  (payload as Record<string, unknown>)['type'] === type;

const isAdmitted = (payload: unknown, admitted: ReadonlySet<string>): boolean => {
  if (typeof payload !== 'object' || payload === null) {
    return true; // let reception voice the malformed-payload violation.
  }
  const type = (payload as Record<string, unknown>)['type'];
  return typeof type !== 'string' || admitted.has(type);
};

const claimedCredential = (payload: unknown): string =>
  typeof payload === 'object' &&
  payload !== null &&
  typeof (payload as Record<string, unknown>)['credentialId'] === 'string'
    ? ((payload as Record<string, unknown>)['credentialId'] as string)
    : 'entrant-unproven';
