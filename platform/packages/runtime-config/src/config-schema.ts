/**
 * The declarative TECHNICAL configuration schema (I-5: "Technique (pools,
 * timeouts, tailles de files) — au runtime"). The boot law it serves:
 * "chaque configuration est du bon type et dans ses bornes … Une seule
 * erreur = pas de démarrage" (F4.4 §7); "configuration invalide" is one of
 * the four immediate-death causes (F4.4 §6, fail closed).
 *
 * Discipline: a field is REQUIRED unless it declares a default — an
 * "optional without default" does not exist (a half-configured application
 * already lies). Secrets NEVER ride this schema: only their NAMES may
 * (references — F4.4 §9/I-8); resolution belongs to the vestibule.
 */

export type ConfigFieldSpec =
  | { readonly kind: 'string'; readonly default?: string; readonly nonBlank?: boolean }
  | { readonly kind: 'number'; readonly default?: number; readonly min?: number; readonly max?: number }
  | { readonly kind: 'boolean'; readonly default?: boolean }
  | { readonly kind: 'choice'; readonly values: readonly string[]; readonly default?: string };

export type ConfigSchema = Readonly<Record<string, ConfigFieldSpec>>;

export type ConfigFieldValue<TSpec extends ConfigFieldSpec> = TSpec extends { kind: 'number' }
  ? number
  : TSpec extends { kind: 'boolean' }
    ? boolean
    : string;

/** The typed configuration a schema yields — every declared key present. */
export type ConfigValues<TSchema extends ConfigSchema> = {
  readonly [K in keyof TSchema]: ConfigFieldValue<TSchema[K]>;
};

export interface ConfigViolation {
  readonly key: string;
  readonly code: 'CONFIG.MISSING' | 'CONFIG.TYPE' | 'CONFIG.BOUNDS' | 'CONFIG.CHOICE' | 'CONFIG.BLANK';
  readonly message: string;
}
