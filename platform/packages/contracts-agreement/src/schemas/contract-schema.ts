import type { Result, UnknownRecord } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { AgreementContractViolation } from '../errors/agreement-error-contract.js';

import { isPlainObject } from './plain-object.js';


/**
 * A minimal, framework-free schema engine for CONTRACT validation (structure
 * only — business judgment belongs to the domain). Deliberately a TOLERANT
 * READER (V-2: "tout consommateur est un lecteur tolérant — il ignore les
 * champs inconnus"): unknown fields never fail validation.
 */

export type FieldKind = 'string' | 'number' | 'boolean' | 'object' | 'array';

export interface FieldSchema {
  readonly kind: FieldKind;
  readonly required: boolean;
  /** For strings that must not be blank (identifiers, references). */
  readonly nonBlank?: boolean;
}

export interface ContractSchema {
  readonly contract: string;
  readonly version: number;
  readonly fields: Readonly<Record<string, FieldSchema>>;
}

const kindOf = (value: unknown): FieldKind | 'other' => {
  if (typeof value === 'string') return 'string';
  if (typeof value === 'number') return 'number';
  if (typeof value === 'boolean') return 'boolean';
  if (Array.isArray(value)) return 'array';
  if (isPlainObject(value)) return 'object';
  return 'other';
};

/** Validate a raw value against a schema. Tolerant of unknown extra fields. */
export const validateAgainstSchema = (
  value: unknown,
  schema: ContractSchema,
): Result<UnknownRecord, readonly AgreementContractViolation[]> => {
  if (!isPlainObject(value)) {
    return err([
      {
        code: 'CONTRACT.NOT_AN_OBJECT',
        field: '$',
        message: `${schema.contract} must be an object`,
      },
    ]);
  }
  const violations: AgreementContractViolation[] = [];
  for (const [field, fieldSchema] of Object.entries(schema.fields)) {
    const present = field in value && value[field] !== undefined;
    if (!present) {
      if (fieldSchema.required) {
        violations.push({
          code: 'CONTRACT.FIELD_MISSING',
          field,
          message: `${schema.contract}.${field} is required`,
        });
      }
      continue;
    }
    const actual = kindOf(value[field]);
    if (actual !== fieldSchema.kind) {
      violations.push({
        code: 'CONTRACT.FIELD_TYPE',
        field,
        message: `${schema.contract}.${field} must be a ${fieldSchema.kind}, got ${actual}`,
      });
      continue;
    }
    if (fieldSchema.kind === 'string' && fieldSchema.nonBlank === true) {
      const text = value[field] as string;
      if (text.trim().length === 0) {
        violations.push({
          code: 'CONTRACT.FIELD_BLANK',
          field,
          message: `${schema.contract}.${field} must not be blank`,
        });
      }
    }
  }
  return violations.length === 0 ? ok(value) : err(violations);
};
