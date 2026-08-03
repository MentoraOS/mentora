import 'package:flutter/foundation.dart';

/// The seven official appearance preferences (catalog §D8), as pure
/// state. Rules belong to the Global Experience Foundation; storage to
/// the Account Platform; this engine only holds the RESOLVED state and
/// notifies — it never decides a resolution and never touches meaning
/// (GE-18, GE-19).
enum ThemePreference { light, dark, system }

enum AccentPreference { emerald }

enum DensityPreference { compact, standard, comfortable }

enum FontScalePreference { small, standard, large, extraLarge }

enum MotionPreference { full, reduced, none }

enum ContrastPreference { standard, high }

/// Future extensions arrive by upstream revision — never here.
enum ReadingComfortPreference { standard }

/// Immutable snapshot of the appearance preferences.
///
/// Defaults are the Mentora fail-safe (Preference Resolution §4.5):
/// accessible, neutral, worldwide — never a country default.
final class AppearanceState {
  final ThemePreference theme;
  final AccentPreference accent;
  final DensityPreference density;
  final FontScalePreference fontScale;
  final MotionPreference motion;
  final ContrastPreference contrast;
  final ReadingComfortPreference readingComfort;

  const AppearanceState({
    this.theme = ThemePreference.system,
    this.accent = AccentPreference.emerald,
    this.density = DensityPreference.standard,
    this.fontScale = FontScalePreference.standard,
    this.motion = MotionPreference.full,
    this.contrast = ContrastPreference.standard,
    this.readingComfort = ReadingComfortPreference.standard,
  });

  AppearanceState copyWith({
    ThemePreference? theme,
    AccentPreference? accent,
    DensityPreference? density,
    FontScalePreference? fontScale,
    MotionPreference? motion,
    ContrastPreference? contrast,
    ReadingComfortPreference? readingComfort,
  }) {
    return AppearanceState(
      theme: theme ?? this.theme,
      accent: accent ?? this.accent,
      density: density ?? this.density,
      fontScale: fontScale ?? this.fontScale,
      motion: motion ?? this.motion,
      contrast: contrast ?? this.contrast,
      readingComfort: readingComfort ?? this.readingComfort,
    );
  }
}

/// Holds the current appearance state and notifies its consumers.
///
/// GE-16 by construction: every update touches exactly the preference
/// it names — no preference ever implicitly changes another.
final class AppearanceEngine extends ChangeNotifier {
  AppearanceEngine({AppearanceState initial = const AppearanceState()})
    : _state = initial;

  AppearanceState _state;

  AppearanceState get state => _state;

  void updateTheme(ThemePreference theme) {
    _update(_state.copyWith(theme: theme));
  }

  void updateAccent(AccentPreference accent) {
    _update(_state.copyWith(accent: accent));
  }

  void updateDensity(DensityPreference density) {
    _update(_state.copyWith(density: density));
  }

  void updateFontScale(FontScalePreference fontScale) {
    _update(_state.copyWith(fontScale: fontScale));
  }

  void updateMotion(MotionPreference motion) {
    _update(_state.copyWith(motion: motion));
  }

  void updateContrast(ContrastPreference contrast) {
    _update(_state.copyWith(contrast: contrast));
  }

  void updateReadingComfort(ReadingComfortPreference readingComfort) {
    _update(_state.copyWith(readingComfort: readingComfort));
  }

  void _update(AppearanceState next) {
    _state = next;
    notifyListeners();
  }
}
