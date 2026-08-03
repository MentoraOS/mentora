import 'dart:ui';

import 'package:intl/intl.dart' as intl;

/// The International Engine — the only path to formats (FDI-06).
///
/// Inputs are always canonical (GE-05: UTC instants, ISO currency
/// codes); outputs are presentations in the expert's resolved
/// preferences. Nothing is ever stored localized (GE-14); direction is
/// logical and first-class (GE-07).
final class InternationalEngine {
  const InternationalEngine();

  /// LTR/RTL are equivalent citizens: the direction derives from the
  /// locale — never from an assumption.
  TextDirection directionFor(Locale locale) {
    const rtlLanguages = {'ar', 'fa', 'he', 'ur'};
    return rtlLanguages.contains(locale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// A canonical UTC instant rendered in the expert's zone offset and
  /// locale. The truth stays UTC — this is presentation only.
  String formatInstant({
    required DateTime canonicalUtc,
    required Duration zoneOffset,
    required Locale locale,
  }) {
    assert(canonicalUtc.isUtc, 'Instants are canonical: UTC only (GE-14).');
    final localInstant = canonicalUtc.add(zoneOffset);
    return intl.DateFormat.yMMMMd(
      locale.toLanguageTag(),
    ).add_Hm().format(localInstant);
  }

  /// A canonical date (ISO 8601 semantics) rendered per locale.
  String formatDate({required DateTime canonicalUtc, required Locale locale}) {
    assert(canonicalUtc.isUtc, 'Dates are canonical: UTC only (GE-14).');
    return intl.DateFormat.yMMMMd(locale.toLanguageTag()).format(canonicalUtc);
  }

  /// A number rendered in the locale's conventions — never coded.
  String formatNumber({required num value, required Locale locale}) {
    return intl.NumberFormat.decimalPattern(locale.toLanguageTag()).format(
      value,
    );
  }

  /// An amount rendered as a dated presentation: the display currency
  /// is a preference notion — the amount's truth stays canonical
  /// upstream (GE-04). This engine formats; it never converts.
  String formatAmount({
    required num value,
    required String currencyCode,
    required Locale locale,
  }) {
    return intl.NumberFormat.currency(
      locale: locale.toLanguageTag(),
      name: currencyCode,
    ).format(value);
  }
}
