import 'dart:ui' show Color;

import '../theme/theme_variant.dart';
import 'design_tokens.dart';

/// Materialization internals of the identity/critical pairs — part of
/// the primary/critical value sets, read from the values home.
///
/// This is the single sanctioned accessor: the Theme Engine and the
/// component tokens adapters consume it; nothing else ever reads the
/// value sets directly.
({Color onPrimary, Color onCritical}) identityInternalsFor(
  ThemeVariantId variant,
) {
  final ColorTokenSet set;
  switch (variant) {
    case ThemeVariantId.light:
      set = lightColorTokens;
    case ThemeVariantId.dark:
      set = darkColorTokens;
    case ThemeVariantId.lightHighContrast:
      set = lightHighContrastColorTokens;
    case ThemeVariantId.darkHighContrast:
      set = darkHighContrastColorTokens;
  }
  return (onPrimary: set.onPrimary, onCritical: set.onCritical);
}
