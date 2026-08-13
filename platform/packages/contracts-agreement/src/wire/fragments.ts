import type { AgreementId } from '../ids/identifiers.js';

/**
 * Shared WIRE fragments of the Agreement language. Kept OUTSIDE events/ on
 * purpose: an events file contains only facts (MENTORA0003 — every PascalCase
 * declaration there must be a participle); the union and fragments live here.
 */

export interface AgreementSlotContract {
  readonly startMs: number;
  readonly endMs: number;
}

export interface AgreementPartyContract {
  readonly role: 'Client' | 'Expert';
  readonly id: string;
}

/** Common shape of every published Agreement fact. */
export interface AgreementFactContractBase {
  readonly contractVersion: 1;
  readonly agreementId: AgreementId;
  readonly sequence: number;
  readonly occurredAtMs: number;
}
