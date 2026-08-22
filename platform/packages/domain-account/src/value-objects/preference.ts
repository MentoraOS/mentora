import { AccountIdentifierBlankException } from '../errors/account-exceptions.js';

/**
 * Preference — TYPED (canon F3.2-B: « Preference (typée) »). The kinds are
 * exactly the three ratified preference VOs of the dictionary —
 * NotificationPreference, LanguagePreference, Timezone — DERIVED from their
 * names, never an invented list: a fourth kind is a Titre VII question. The
 * VALUE of each kind stays a guarded opaque string (the dictionary ratifies
 * the VOs without enumerating their values — same posture as FactorKind).
 */

export type PreferenceKind = 'notification' | 'language' | 'timezone';

export const PREFERENCE_KINDS: readonly PreferenceKind[] = ['notification', 'language', 'timezone'];

declare const preferenceValueBrand: unique symbol;
export type PreferenceValue = string & { readonly [preferenceValueBrand]: true };

export interface Preference {
  readonly kind: PreferenceKind;
  readonly value: PreferenceValue;
}

export const preferenceKindOf = (value: string): PreferenceKind => {
  const normalized = value.trim().toLowerCase();
  if (!(PREFERENCE_KINDS as readonly string[]).includes(normalized)) {
    throw new AccountIdentifierBlankException(
      `PreferenceKind must be one of ${PREFERENCE_KINDS.join(', ')}`,
    );
  }
  return normalized as PreferenceKind;
};

export const preferenceValueOf = (value: string): PreferenceValue => {
  if (value.trim().length === 0) {
    throw new AccountIdentifierBlankException('PreferenceValue must not be blank');
  }
  return value.trim() as PreferenceValue;
};
