import type { ActorRef } from '@mentora/contracts';
import type {
  AgreementId,
  AgreementSlotContract,
  AgreementStateResponse,
  ClientId,
  ExpertId,
} from '@mentora/contracts-agreement';
import type { Option } from '@mentora/kernel';

/**
 * The READ ports of the Agreement query side — owned by their consumer, the
 * application (I-4); implemented by adapters below (I-12). READ ONLY by
 * construction: no save, no retain, no publish exists on these surfaces.
 *
 * SIGNALED (règle constitutionnelle : R2 gagne): the mandate named this port
 * "AgreementQueryRepository". A Repository is the DOMAIN's registry of ONE
 * truth (F3.1: `<Truth>Repository`; the Agreement domain owns exactly one —
 * AgreementRepository, 1A) and F4.1 §7 guards "contre le Repository métier".
 * A read port is a CAPABILITY port — frozen naming `<Capability>Port`
 * (F2.5 §9). Hence AgreementStateReadPort.
 */

/**
 * The Read Model row the lecture reads (F4.1 §5: "route vers le Read Model ou
 * la source") — a VIEW, never the Agreement unit: the domain never exits
 * directly. It carries the parties so the RIGHTS adapter below can answer the
 * declared grid ("les parties, l'outillage du temps" — F3.3 §5); the mapping
 * to the published response STRIPS them ("l'état ⊘ les conditions à des
 * tiers").
 */
export interface AgreementStateView {
  readonly agreementId: AgreementId;
  readonly stateKind: AgreementStateResponse['stateKind'];
  readonly slot: AgreementSlotContract;
  readonly version: number;
  readonly clientId: ClientId;
  readonly expertId: ExpertId;
}

/** Pas 4 — the lecture of ONE agreement's state, by Identifier, nothing else. */
export interface AgreementStateReadPort {
  stateOf(agreementId: AgreementId): Promise<Option<AgreementStateView>>;
}

/**
 * Pas 3 — R-C: the DECLARED rights grid of AgreementStateQuery, verbatim from
 * the frozen catalogue (F3.3 §5): "les parties, l'outillage du temps". The
 * grid is applied on the INJECTED identity (F4.1 §5); HOW the adapter below
 * knows the parties or recognizes the time tooling is its mechanism (frozen
 * properties, free mechanisms — F4.1.99). ActorRef stays opaque here (its
 * refined shape is signaled to Titre VII since 1C-2).
 */
export interface AgreementReadRightsPort {
  holdsStateRight(actor: ActorRef, agreementId: AgreementId): Promise<boolean>;
}
