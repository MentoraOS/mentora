import 'dart:ui' show Brightness;

import '../appearance/appearance_engine.dart';
import 'theme_variant.dart';

/// Resolves Light / Dark / System into the effective theme variant —
/// pure data in, pure data out: no Widget, no BuildContext, ever.
///
/// "System" is itself an explicit expert choice (Preference Resolution
/// §4.5): following the platform brightness is chosen, never assumed.
final class ThemeResolver {
  const ThemeResolver();

  ThemeVariantId resolve({
    required ThemePreference theme,
    required ContrastPreference contrast,
    required Brightness platformBrightness,
  }) {
    final bool dark;
    switch (theme) {
      case ThemePreference.light:
        dark = false;
      case ThemePreference.dark:
        dark = true;
      case ThemePreference.system:
        dark = platformBrightness == Brightness.dark;
    }
    final high = contrast == ContrastPreference.high;
    if (dark) {
      return high ? ThemeVariantId.darkHighContrast : ThemeVariantId.dark;
    }
    return high ? ThemeVariantId.lightHighContrast : ThemeVariantId.light;
  }
}
