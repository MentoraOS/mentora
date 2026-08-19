import type { CredentialStateReadPort } from '@mentora/application-identity';
import type { CredentialId, ProofRequirementPolicy, ProofStrength } from '@mentora/domain-identity';
import { proofStrengthOf } from '@mentora/domain-identity';

/**
 * ProofVerifier — the vestibule's verification MECHANISM at the entry
 * (Story #96/#111): presented material dies HERE (I-8 — no password ever
 * crosses toward the dispatch; the domain sees strengths only). The
 * verifier resolves the credential's DECLARED factors (references and
 * natures from the read capability), demonstrates each presented material
 * against the vault (a boolean, never a revelation — T-24), and asks the
 * RATIFIED ProofRequirementPolicy to compose the verified strengths into
 * the ONE presented strength the wire carries ("la ProofRequirementPolicy
 * décide, pas l'adapter" — ADR-0004). Every rejection is the same flat
 * verdict: nothing enumerable leaks (which factor failed, whether the
 * credential exists — one voice, Story #99).
 */

/** The vault surface the entry consumes — owned HERE (I-4: consumer owns the port). */
export interface ProofMaterialVerifyPort {
  verify(factorId: string, material: string): Promise<boolean>;
}

export interface PresentedProof {
  readonly factorId: string;
  readonly material: string;
}

export type ProofVerdict =
  | { readonly kind: 'proven'; readonly strength: ProofStrength }
  | { readonly kind: 'rejected' };

const REJECTED: ProofVerdict = { kind: 'rejected' };

export class ProofVerifier {
  constructor(
    private readonly credentials: CredentialStateReadPort,
    private readonly vault: ProofMaterialVerifyPort,
    private readonly policy: ProofRequirementPolicy,
  ) {}

  async verify(credentialId: string, proofs: readonly PresentedProof[]): Promise<ProofVerdict> {
    if (proofs.length === 0) {
      return REJECTED;
    }
    const credential = await this.credentials.stateOf(credentialId as CredentialId);
    if (!credential.some || credential.value.stateKind !== 'Active') {
      return REJECTED; // same flat voice as a wrong password — nothing enumerable.
    }
    const declared = new Map(
      credential.value.factors.map((factor) => [factor.factorId, factor] as const),
    );
    const verified: ProofStrength[] = [];
    for (const proof of proofs) {
      const factor = declared.get(proof.factorId);
      if (factor === undefined) {
        return REJECTED; // an undeclared factor name proves nothing.
      }
      if (!(await this.vault.verify(proof.factorId, proof.material))) {
        return REJECTED;
      }
      verified.push(proofStrengthOf(factor.strength));
    }
    const composed = this.policy.compose(verified);
    if (!composed.ok) {
      return REJECTED;
    }
    return { kind: 'proven', strength: composed.value };
  }
}
