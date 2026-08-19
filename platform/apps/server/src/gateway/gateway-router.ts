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
import type { PresentedProof, ProofVerifier } from './proof-verifier.js';
import type { SessionGate } from './session-gate.js';

/**
 * GatewayRouter — the ENTERING adapter of this executable (I-12: its unique
 * mouth is the Dispatch — no domain port is ever touched here; the graph
 * stays acyclic by construction). Three surfaces, three closed tables:
 *
 *   POST /entry/open-session  — the UNAUTHENTICATED vestibule act: the act
 *     of entry itself (a session cannot be required to open a session).
 *     Since Story #96 the entry takes PRESENTED MATERIAL, not a declared
 *     strength: {commandId, sessionId, credentialId, proofs:[{factorId,
 *     material}]}. The ProofVerifier demonstrates the material at the
 *     vault and the RATIFIED policy composes the verified strengths; the
 *     gateway MINTS the wire's presentedStrength from that judgment — a
 *     caller-declared strength is refused as the caller's defect (the
 *     trust-the-client seam of the Sprint 3 interim is DEAD). Material
 *     dies here (I-8); a failed proof is 401, one flat voice.
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
    private readonly proofs: ProofVerifier,
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
        const entry = entryPayload(payload);
        if (entry === undefined) {
          return notFoundReply(); // the entry admits ONE act shape — a closed door.
        }
        const verdict = await this.proofs.verify(entry.credentialId, entry.proofs);
        if (verdict.kind === 'rejected') {
          return unauthenticatedReply('proof rejected'); // one flat voice (Story #99).
        }
        // The gateway MINTS the wire — the verified judgment, never a claim.
        const wire = {
          type: 'OpenSession',
          contractVersion: 1,
          commandId: entry.commandId,
          sessionId: entry.sessionId,
          credentialId: entry.credentialId,
          presentedStrength: verdict.strength,
        };
        return commandOutcomeReply(
          await this.identityCommands.dispatch({
            payload: wire,
            actor: entry.credentialId as ActorRef,
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

/**
 * The entry's OWN shape (mechanism, ours): material in, strength NEVER in.
 * A payload carrying presentedStrength (or any unexpected claim) is not
 * this shape — the door stays closed. `type` is tolerated when it says
 * OpenSession (a well-meaning caller), required to say nothing else.
 */
interface EntryPayload {
  readonly commandId: string;
  readonly sessionId: string;
  readonly credentialId: string;
  readonly proofs: readonly PresentedProof[];
}

const entryPayload = (payload: unknown): EntryPayload | undefined => {
  if (typeof payload !== 'object' || payload === null) {
    return undefined;
  }
  const record = payload as Record<string, unknown>;
  if (record['type'] !== undefined && record['type'] !== 'OpenSession') {
    return undefined;
  }
  if (record['presentedStrength'] !== undefined) {
    return undefined; // the declared-strength seam is DEAD (Story #99).
  }
  const { commandId, sessionId, credentialId, proofs } = record;
  if (
    typeof commandId !== 'string' ||
    typeof sessionId !== 'string' ||
    typeof credentialId !== 'string' ||
    !Array.isArray(proofs)
  ) {
    return undefined;
  }
  const presented: PresentedProof[] = [];
  for (const proof of proofs) {
    if (
      typeof proof !== 'object' ||
      proof === null ||
      typeof (proof as Record<string, unknown>)['factorId'] !== 'string' ||
      typeof (proof as Record<string, unknown>)['material'] !== 'string'
    ) {
      return undefined;
    }
    presented.push(proof as unknown as PresentedProof);
  }
  return { commandId, sessionId, credentialId, proofs: presented };
};

const isAdmitted = (payload: unknown, admitted: ReadonlySet<string>): boolean => {
  if (typeof payload !== 'object' || payload === null) {
    return true; // let reception voice the malformed-payload violation.
  }
  const type = (payload as Record<string, unknown>)['type'];
  return typeof type !== 'string' || admitted.has(type);
};
