import 'dart:ui';

/// The Localization Engine — the application-language notion only
/// (Global Experience §3.2: the six language notions are independent;
/// the other five belong to their own resolutions).
final class LocalizationEngine {
  const LocalizationEngine();

  /// The locales the foundation ships ready for. The world is the
  /// nominal case — this list grows by configuration, never by code
  /// changes elsewhere (GE-12).
  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('en'),
    Locale('ar'),
    Locale('es'),
    Locale('pt'),
    Locale('de'),
  ];

  /// The official resolution order (Experience Preferences §4.5):
  /// 1. the expert's explicit choice, 2. the system locale when
  /// supported, 3. the worldwide fail-safe — never a country default.
  Locale resolve({Locale? explicitChoice, Locale? systemLocale}) {
    if (explicitChoice != null && _isSupported(explicitChoice)) {
      return explicitChoice;
    }
    if (systemLocale != null && _isSupported(systemLocale)) {
      return Locale(systemLocale.languageCode);
    }
    return const Locale('en');
  }

  bool _isSupported(Locale locale) {
    return supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }
}
