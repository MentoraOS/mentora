import type { Credential } from '../aggregate/credential.js';

/**
 * ActiveCredentialUniquenessSpecification — THE DECLARED R-A RULE of the
 * Credential (canon ch.04: "un Credential actif par (personne ×
 * facteur-principal)"). Same constitutional split as the Agreement precedent
 * (OverlappingSlotSpecification): the RULE lives here, readable and
 * testable; the KEY is applied STRUCTURALLY by the registry at retention —
 * the unit never scans the world.
 */
export class ActiveCredentialUniquenessSpecification {
  /** True when the two credentials would violate the R-A key together. */
  conflicts(candidate: Credential, existing: Credential): boolean {
    return (
      candidate.id !== existing.id &&
      candidate.state.kind === 'Active' &&
      existing.state.kind === 'Active' &&
      candidate.personId === existing.personId &&
      candidate.principalFactor.kind === existing.principalFactor.kind
    );
  }
}
