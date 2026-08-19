import type { Result } from '@mentora/kernel';
import { err, instantOf, ok } from '@mentora/kernel';

import type { RevokeCredential } from '../commands/credential-commands.js';
import type { CredentialRefusal } from '../decisions/credential-refusal.js';
import { credentialRefusal } from '../decisions/credential-refusal.js';
import type { Factor } from '../entities/factor.js';
import { CredentialSnapshotCorruptException } from '../errors/identity-exceptions.js';
import type { CredentialId, PersonId } from '../ids/identifiers.js';
import { credentialIdOf, factorIdOf, personIdOf } from '../ids/identifiers.js';
import type { CredentialSnapshot } from '../snapshots/credential-snapshot.js';
import type { CredentialState } from '../value-objects/credential-state.js';
import { factorKindOf } from '../value-objects/factor-kind.js';
import { proofStrengthOf } from '../value-objects/proof-strength.js';

import type { CredentialDomainEvent } from './credential-domain-event.js';

/**
 * Credential — the executable incarnation of the truth "la preuve d'entrée"
 * (dictionary F2.5, canon ch.04 — Identity & Access). The proof, NEVER the
 * person: the proof↔person link lives in the ACL of the Account; here
 * PersonId is an opaque reference.
 *
 * Constitutional posture:
 * - Frozen machine `Active → Revoked` (terminal; re-entering = NEW
 *   Credential, R-B — there is no resurrection verb, by construction).
 * - Entity `Factor` inside — nature and weight of the proof, NEVER its
 *   material ("aucun secret dans l'unité, jamais"). Exactly one PRINCIPAL
 *   factor: the R-A axis.
 * - THE R-A KEY, DECLARED here, APPLIED by the registry at retention (same
 *   split as the Agreement precedent): one ACTIVE Credential per
 *   (person × principal-factor kind). See
 *   ActiveCredentialUniquenessSpecification. The refusal NAME of that key is
 *   a recorded canon gap — settled at the persistence lot, never invented.
 * - `RevokeCredential` is contractually PRIORITARY: revocation is the one
 *   verb that must never wait (canon ch.04 "révocation immédiate").
 * - The clock never enters: instants arrive as data. Facts are born inside,
 *   carried in `pendingFacts`, retained atomically by the registry.
 */
export class Credential {
  private constructor(
    readonly id: CredentialId,
    /** Opaque — the link to the person is the Account ACL's truth. */
    readonly personId: PersonId,
    readonly factors: readonly Factor[],
    readonly state: CredentialState,
    /** Optimistic-concurrency version (F5.2 §4); increments with every fact. */
    readonly version: number,
    /** Facts born and not yet retained — pulled by the Application layer. */
    readonly pendingFacts: readonly CredentialDomainEvent[],
  ) {}

  // ------------------------------------------------------------------ birth

  /** INTERNAL to the domain: called by CredentialFactory only (the birth door, F3.1). */
  static _born(
    id: CredentialId,
    personId: PersonId,
    principalFactor: Factor,
    secondaryFactors: readonly Factor[] = [],
  ): Credential {
    return new Credential(
      id,
      personId,
      [principalFactor, ...secondaryFactors],
      { kind: 'Active', establishedAt: principalFactor.establishedAt },
      1,
      [
        {
          type: 'CredentialEstablished',
          credentialId: id,
          sequence: 1,
          instant: principalFactor.establishedAt,
          personId,
          principalFactorId: principalFactor.factorId,
          principalFactorKind: principalFactor.kind,
        },
      ],
    );
  }

  // ------------------------------------------------------- frozen machine

  /** Revocation — immediate, prioritary, terminal (R-B: no way back). */
  revoke(command: RevokeCredential): Result<Credential, CredentialRefusal> {
    if (this.state.kind !== 'Active') {
      return err(
        credentialRefusal(
          'TransitionUnavailable',
          `revoke requires an Active credential; current state is ${this.state.kind}`,
        ),
      );
    }
    return ok(
      new Credential(
        this.id,
        this.personId,
        this.factors,
        { kind: 'Revoked', revokedAt: command.revokedAt, motive: command.motive },
        this.version + 1,
        [
          ...this.pendingFacts,
          {
            type: 'CredentialRevoked',
            credentialId: this.id,
            sequence: this.version + 1,
            instant: command.revokedAt,
            motive: command.motive,
          },
        ],
      ),
    );
  }

  // ------------------------------------------------------------- carriers

  /** The principal factor — exactly one by construction (the R-A axis). */
  get principalFactor(): Factor {
    const principal = this.factors.find((factor) => factor.principal);
    if (principal === undefined) {
      throw new CredentialSnapshotCorruptException(
        `credential ${this.id} carries no principal factor`,
      );
    }
    return principal;
  }

  /** The Application layer pulls the newborn facts for atomic retention (pas 8). */
  retained(): Credential {
    return new Credential(this.id, this.personId, this.factors, this.state, this.version, []);
  }

  // ------------------------------------------------------- reconstitution

  /** Photograph for the registry — private, never a served shape (F3.1.11). */
  snapshot(): CredentialSnapshot {
    return {
      credentialId: this.id,
      personId: this.personId,
      factors: this.factors.map((factor) => ({
        factorId: factor.factorId,
        kind: factor.kind,
        strength: factor.strength,
        principal: factor.principal,
        establishedAtMs: factor.establishedAt.epochMillis,
      })),
      state:
        this.state.kind === 'Active'
          ? { kind: 'Active', establishedAtMs: this.state.establishedAt.epochMillis }
          : {
              kind: 'Revoked',
              revokedAtMs: this.state.revokedAt.epochMillis,
              motive: this.state.motive,
            },
      version: this.version,
    };
  }

  /** Reconstruction = private snapshot + delta(0) (F5.2.99). Corruption throws — never a Refusal. */
  static fromSnapshot(snapshot: CredentialSnapshot): Credential {
    if (snapshot.version < 1 || snapshot.factors.length === 0) {
      throw new CredentialSnapshotCorruptException(
        `credential ${snapshot.credentialId}: version ${snapshot.version}, ${snapshot.factors.length} factors`,
      );
    }
    const factors: Factor[] = snapshot.factors.map((factor) => ({
      factorId: factorIdOf(factor.factorId),
      kind: factorKindOf(factor.kind),
      strength: proofStrengthOf(factor.strength),
      principal: factor.principal,
      establishedAt: instantOf(factor.establishedAtMs),
    }));
    if (factors.filter((factor) => factor.principal).length !== 1) {
      throw new CredentialSnapshotCorruptException(
        `credential ${snapshot.credentialId}: exactly one principal factor required`,
      );
    }
    const state: CredentialState =
      snapshot.state.kind === 'Active'
        ? { kind: 'Active', establishedAt: instantOf(snapshot.state.establishedAtMs) }
        : {
            kind: 'Revoked',
            revokedAt: instantOf(snapshot.state.revokedAtMs),
            motive: snapshot.state.motive,
          };
    return new Credential(
      credentialIdOf(snapshot.credentialId),
      personIdOf(snapshot.personId),
      factors,
      state,
      snapshot.version,
      [],
    );
  }
}
