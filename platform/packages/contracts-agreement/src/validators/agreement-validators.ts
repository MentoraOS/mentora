import type { Result } from '@mentora/kernel';
import { err } from '@mentora/kernel';

import type { AgreementCommandContract } from '../commands/agreement-command-contracts.js';
import type { AgreementContractViolation } from '../errors/agreement-error-contract.js';
import type { AgreementStateQuery } from '../queries/agreement-state.query.js';
import {
  AGREEMENT_COMMAND_SCHEMAS,
  AGREEMENT_EVENT_SCHEMAS,
  AGREEMENT_QUERY_SCHEMAS,
} from '../schemas/agreement-schemas.js';
import type { ContractSchema } from '../schemas/contract-schema.js';
import { validateAgainstSchema } from '../schemas/contract-schema.js';
import { isPlainObject } from '../schemas/plain-object.js';
import { isCompatibleGeneration } from '../version/contract-generations.js';
import type { AgreementEventContract } from '../wire/event-union.js';

/**
 * The public validators of the Agreement language. CONTRACT validation only —
 * structure, presence, kinds, blankness, generation compatibility. Business
 * judgment (frame fit, machine transitions…) belongs to the domain. Tolerant
 * readers by law (V-2): unknown fields are ignored, never refused.
 */

type Validated<T> = Result<T, readonly AgreementContractViolation[]>;

const validateNamed = <T>(
  value: unknown,
  schemas: Readonly<Record<string, ContractSchema>>,
  family: string,
): Validated<T> => {
  if (!isPlainObject(value)) {
    return err([
      { code: 'CONTRACT.NOT_AN_OBJECT', field: '$', message: `${family} must be an object` },
    ]);
  }
  const typeName = (value)['type'];
  if (typeof typeName !== 'string' || !(typeName in schemas)) {
    return err([
      {
        code: 'CONTRACT.UNKNOWN_CONTRACT',
        field: 'type',
        message: `Unknown ${family} contract: ${String(typeName)}`,
      },
    ]);
  }
  const schema = schemas[typeName];
  if (schema === undefined) {
    return err([
      { code: 'CONTRACT.UNKNOWN_CONTRACT', field: 'type', message: `Unknown ${family}` },
    ]);
  }
  const structural = validateAgainstSchema(value, schema);
  if (!structural.ok) {
    return structural;
  }
  const version = (value)['contractVersion'];
  if (typeof version !== 'number' || !isCompatibleGeneration(typeName, version)) {
    return err([
      {
        code: 'CONTRACT.VERSION_INCOMPATIBLE',
        field: 'contractVersion',
        message: `${typeName} generation ${String(version)} is not consumable by this reader`,
      },
    ]);
  }
  return structural as unknown as Validated<T>;
};

export const validateAgreementEvent = (value: unknown): Validated<AgreementEventContract> =>
  validateNamed<AgreementEventContract>(value, AGREEMENT_EVENT_SCHEMAS, 'event');

export const validateAgreementCommand = (value: unknown): Validated<AgreementCommandContract> =>
  validateNamed<AgreementCommandContract>(value, AGREEMENT_COMMAND_SCHEMAS, 'command');

export const validateAgreementQuery = (value: unknown): Validated<AgreementStateQuery> =>
  validateNamed<AgreementStateQuery>(value, AGREEMENT_QUERY_SCHEMAS, 'query');
