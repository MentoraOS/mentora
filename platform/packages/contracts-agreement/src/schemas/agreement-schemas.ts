import type { ContractSchema, FieldSchema } from './contract-schema.js';

/**
 * The public schemas of every Agreement contract — data-driven, framework-free,
 * consumed by the validators and readable as documentation. One schema per
 * contract, keyed by its ratified name.
 */

const id = (nonBlank = true): FieldSchema => ({ kind: 'string', required: true, nonBlank });
const num = (): FieldSchema => ({ kind: 'number', required: true });
const obj = (): FieldSchema => ({ kind: 'object', required: true });
const arr = (): FieldSchema => ({ kind: 'array', required: true });
const text = (): FieldSchema => ({ kind: 'string', required: true, nonBlank: true });

const eventBase = {
  type: id(),
  contractVersion: num(),
  agreementId: id(),
  sequence: num(),
  occurredAtMs: num(),
} as const;

const commandBase = {
  type: id(),
  contractVersion: num(),
  commandId: id(),
  agreementId: id(),
} as const;

const schema = (
  contract: string,
  fields: Readonly<Record<string, FieldSchema>>,
): ContractSchema => ({ contract, version: 1, fields });

export const AGREEMENT_EVENT_SCHEMAS: Readonly<Record<string, ContractSchema>> = {
  AgreementRequested: schema('AgreementRequested', {
    ...eventBase,
    clientId: id(),
    expertId: id(),
    offerId: id(),
    slot: obj(),
  }),
  AgreementAccepted: schema('AgreementAccepted', { ...eventBase, expertId: id() }),
  AgreementRejected: schema('AgreementRejected', { ...eventBase, expertId: id() }),
  AgreementRequestLapsed: schema('AgreementRequestLapsed', { ...eventBase }),
  AgreementConfirmed: schema('AgreementConfirmed', { ...eventBase, settlementReference: text() }),
  AgreementRescheduled: schema('AgreementRescheduled', {
    ...eventBase,
    previousSlot: obj(),
    newSlot: obj(),
    requestedBy: obj(),
  }),
  AgreementCancelled: schema('AgreementCancelled', {
    ...eventBase,
    cancelledBy: obj(),
    motive: text(),
  }),
  AgreementElapsed: schema('AgreementElapsed', { ...eventBase }),
};

export const AGREEMENT_COMMAND_SCHEMAS: Readonly<Record<string, ContractSchema>> = {
  RequestAgreement: schema('RequestAgreement', {
    ...commandBase,
    clientId: id(),
    expertId: id(),
    offerId: id(),
    slot: obj(),
    availabilityWindows: arr(),
  }),
  AcceptAgreement: schema('AcceptAgreement', { ...commandBase, expertId: id() }),
  RejectAgreement: schema('RejectAgreement', { ...commandBase, expertId: id() }),
  ConfirmAgreement: schema('ConfirmAgreement', { ...commandBase, settlementReference: text() }),
  RescheduleAgreement: schema('RescheduleAgreement', {
    ...commandBase,
    requestedBy: obj(),
    newSlot: obj(),
  }),
  CancelAgreement: schema('CancelAgreement', { ...commandBase, cancelledBy: obj(), motive: text() }),
  LapseAgreementRequest: schema('LapseAgreementRequest', { ...commandBase }),
  ElapseAgreement: schema('ElapseAgreement', { ...commandBase }),
};

export const AGREEMENT_QUERY_SCHEMAS: Readonly<Record<string, ContractSchema>> = {
  AgreementStateQuery: schema('AgreementStateQuery', {
    type: id(),
    contractVersion: num(),
    agreementId: id(),
  }),
};
