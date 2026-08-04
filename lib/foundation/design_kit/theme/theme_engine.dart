import 'package:flutter/material.dart';

import '../appearance/appearance_engine.dart';
import '../registry/semantic_roles.dart';
import '../registry/token_engines.dart';
import '../tokens/color_internals.dart';
import 'theme_resolver.dart';
import 'theme_variant.dart';

/// The Theme Engine — the only place where ThemeData is built (FDG-01).
///
/// Since F1.2 it produces the complete theme EXCLUSIVELY from the bound
/// token engines: it knows roles and relations — never a color, never
/// a size. The only direct tokens-layer reads are the materialization
/// internals of the identity pair (onPrimary/onCritical), which belong
/// to the primary/critical value sets and live in the values home.
final class ThemeEngine {
  final ColorTokenEngine _colors;
  final TypographyTokenEngine _typography;
  final SurfaceTokenEngine _surfaces;
  final ThemeResolver _resolver;

  const ThemeEngine({
    required ColorTokenEngine colors,
    required TypographyTokenEngine typography,
    required SurfaceTokenEngine surfaces,
    ThemeResolver resolver = const ThemeResolver(),
  }) : _colors = colors,
       _typography = typography,
       _surfaces = surfaces,
       _resolver = resolver;

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
    return themeForVariant(
      _resolver.resolve(
        theme: ThemePreference.light,
        contrast: appearance.contrast,
        platformBrightness: Brightness.light,
      ),
    );
  }

  ThemeData darkTheme(AppearanceState appearance) {
    return themeForVariant(
      _resolver.resolve(
        theme: ThemePreference.dark,
        contrast: appearance.contrast,
        platformBrightness: Brightness.dark,
      ),
    );
  }

  /// Builds one variant's complete theme from Tokens only.
  ThemeData themeForVariant(ThemeVariantId variant) {
    final brightness =
        variant == ThemeVariantId.dark ||
            variant == ThemeVariantId.darkHighContrast
        ? Brightness.dark
        : Brightness.light;
    final identityInternals = identityInternalsFor(variant);

    Color role(ColorRole r) => _colors.colorOf(r, variant);
    TextStyle style(TypographyRole r) => _typography.styleOf(r, variant);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: role(ColorRole.primary),
      onPrimary: identityInternals.onPrimary,
      secondary: role(ColorRole.secondary),
      onSecondary: identityInternals.onPrimary,
      error: role(ColorRole.critical),
      onError: identityInternals.onCritical,
      surface: _surfaces.surfaceOf(SurfaceRole.primarySurface, variant),
      onSurface: role(ColorRole.foreground),
      outline: role(ColorRole.outline),
    );

    final textTheme = TextTheme(
      headlineMedium: style(TypographyRole.hero),
      titleLarge: style(TypographyRole.pageTitle),
      titleMedium: style(TypographyRole.sectionTitle),
      titleSmall: style(TypographyRole.blockTitle),
      bodyMedium: style(TypographyRole.body),
      labelMedium: style(TypographyRole.label),
      bodySmall: style(TypographyRole.supporting),
      labelSmall: style(TypographyRole.caption),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _surfaces.surfaceOf(SurfaceRole.scene, variant),
      dividerColor: role(ColorRole.divider),
      disabledColor: role(ColorRole.disabled),
      focusColor: role(ColorRole.focus),
      highlightColor: role(ColorRole.highlight),
      textTheme: textTheme,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaces.surfaceOf(
          SurfaceRole.primarySurface,
          variant,
        ),
        indicatorColor: role(ColorRole.highlight),
      ),
    );
  }
}
