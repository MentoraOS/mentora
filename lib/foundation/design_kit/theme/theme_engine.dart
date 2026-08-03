import 'package:flutter/material.dart';

import '../appearance/appearance_engine.dart';
import '../tokens/design_tokens.dart';

/// The Theme Engine — the only place where ThemeData is built (FDG-01).
///
/// It consumes color and typography Tokens exclusively; a theme is a
/// value set under stable names (GE-18: changing the theme never
/// changes a meaning). Light, Dark and System are the official modes;
/// Mentora Emerald is the official accent, carried by the Tokens layer.
final class ThemeEngine {
  const ThemeEngine();

  /// System/Light/Dark resolution is a straight mapping of the resolved
  /// preference — the engine never decides beyond it.
  ThemeMode resolveMode(AppearanceState appearance) {
    switch (appearance.theme) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  ThemeData lightTheme(AppearanceState appearance) {
    return _themeFrom(_lightTokensFor(appearance), Brightness.light);
  }

  ThemeData darkTheme(AppearanceState appearance) {
    return _themeFrom(_darkTokensFor(appearance), Brightness.dark);
  }

  ColorTokenSet _lightTokensFor(AppearanceState appearance) {
    return appearance.contrast == ContrastPreference.high
        ? lightHighContrastColorTokens
        : lightColorTokens;
  }

  ColorTokenSet _darkTokensFor(AppearanceState appearance) {
    return appearance.contrast == ContrastPreference.high
        ? darkHighContrastColorTokens
        : darkColorTokens;
  }

  ThemeData _themeFrom(ColorTokenSet tokens, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: tokens.primary,
      onPrimary: tokens.onPrimary,
      secondary: tokens.secondary,
      onSecondary: tokens.onPrimary,
      error: tokens.critical,
      onError: tokens.onCritical,
      surface: tokens.surface,
      onSurface: tokens.foreground,
      outline: tokens.outline,
    );

    final textTheme = TextTheme(
      titleLarge: TextStyle(
        fontSize: typographyTokens.pageTitleSize,
        fontWeight: typographyTokens.pageTitleWeight,
        color: tokens.foreground,
      ),
      bodyMedium: TextStyle(
        fontSize: typographyTokens.bodySize,
        fontWeight: typographyTokens.bodyWeight,
        color: tokens.foreground,
      ),
      labelMedium: TextStyle(
        fontSize: typographyTokens.labelSize,
        fontWeight: typographyTokens.labelWeight,
        color: tokens.mutedForeground,
      ),
      bodySmall: TextStyle(
        fontSize: typographyTokens.supportingSize,
        fontWeight: typographyTokens.supportingWeight,
        color: tokens.mutedForeground,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.background,
      dividerColor: tokens.divider,
      disabledColor: tokens.disabled,
      focusColor: tokens.focus,
      highlightColor: tokens.highlight,
      textTheme: textTheme,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.surface,
        indicatorColor: tokens.highlight,
      ),
    );
  }
}
