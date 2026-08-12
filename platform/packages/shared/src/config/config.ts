import type { Option } from '@mentora/kernel';

/**
 * The `Config` **port**. Configuration is read once at the composition root and
 * injected (F4.4 I-5, F4.1 A-6) — never read ad hoc from `process.env` inside a
 * library. This is the contract; a concrete source (env, file, vault) is an
 * adapter. Lookups return `Option` so "absent" is an explicit case.
 */
export interface Config {
  /** The raw string value for `key`, if present. */
  get(key: string): Option<string>;
}
