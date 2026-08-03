import 'dart:ui' show Color;

import 'package:flutter/widgets.dart' show TextStyle;

import '../theme/theme_variant.dart';
import 'semantic_roles.dart';

/// The five token-engine contracts — the receiving ports of the Kit
/// (Flutter Design Kit §7: every engine consumes Tokens, never
/// anything else). Their implementations arrive with the binding
/// waves; consumers depend on these contracts only, so the arrival of
/// the 172 Tokens changes no architecture.
abstract interface class ColorTokenEngine {
  Color colorOf(ColorRole role, ThemeVariantId variant);
}

abstract interface class TypographyTokenEngine {
  TextStyle styleOf(TypographyRole role, ThemeVariantId variant);
}

abstract interface class SpacingTokenEngine {
  double spaceOf(SpacingRelation relation);
}

abstract interface class SurfaceTokenEngine {
  Color surfaceOf(SurfaceRole role, ThemeVariantId variant);
}

/// Elevation resolves a MEANING into its expression — the expression
/// type stays opaque here (heights never enter the contract).
abstract interface class ElevationTokenEngine<TExpression> {
  TExpression expressionOf(ElevationMeaning meaning, ThemeVariantId variant);
}
