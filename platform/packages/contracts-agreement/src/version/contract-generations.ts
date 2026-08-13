/**
 * The generation manifest of the Agreement language (F4.3 V-laws):
 * - V-1: the owner owns the contract and its generations — this manifest is
 *   that ownership, written down;
 * - V-2: evolution is ADDITIVE (a new generation adds optional fields);
 * - V-3: a rename/removal is a NEW CONTRACT, never a version bump;
 * - V-5: a generation dies when its declared consumers are gone (derivable).
 */

export interface ContractGeneration {
  readonly version: number;
  readonly deprecated: boolean;
  /** Generations a reader of this generation can still consume (V-4). */
  readonly compatibleWith: readonly number[];
}

const generationOne: ContractGeneration = { version: 1, deprecated: false, compatibleWith: [1] };

/** Every published Agreement contract, at generation 1. */
export const AGREEMENT_CONTRACT_GENERATIONS: Readonly<Record<string, ContractGeneration>> = {
  AgreementRequested: generationOne,
  AgreementAccepted: generationOne,
  AgreementRejected: generationOne,
  AgreementRequestLapsed: generationOne,
  AgreementConfirmed: generationOne,
  AgreementRescheduled: generationOne,
  AgreementCancelled: generationOne,
  AgreementElapsed: generationOne,
  RequestAgreement: generationOne,
  AcceptAgreement: generationOne,
  RejectAgreement: generationOne,
  ConfirmAgreement: generationOne,
  RescheduleAgreement: generationOne,
  CancelAgreement: generationOne,
  LapseAgreementRequest: generationOne,
  ElapseAgreement: generationOne,
  AgreementStateQuery: generationOne,
  AgreementStateResponse: generationOne,
};

/** Can a reader of the current manifest consume `version` of `contract`? */
export const isCompatibleGeneration = (contract: string, version: number): boolean => {
  const generation = AGREEMENT_CONTRACT_GENERATIONS[contract];
  return generation !== undefined && generation.compatibleWith.includes(version);
};
