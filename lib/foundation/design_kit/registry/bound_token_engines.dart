import 'dart:ui' show Color;

import 'package:flutter/widgets.dart' show TextStyle;

import '../theme/theme_variant.dart';
import '../tokens/surface_elevation_tokens.dart';
import '../tokens/token_catalog_phase1.dart';
import 'semantic_roles.dart';
import 'token_engines.dart';
import 'token_provider.dart';

/// The bound implementations of the five engine ports: every value
/// travels reference → provider → materialization. No literal lives
/// here — this file stays contract-pure (governance-scanned).
final class BoundColorTokenEngine implements ColorTokenEngine {
  final DesignTokenProvider _provider;

  const BoundColorTokenEngine({required DesignTokenProvider provider})
    : _provider = provider;

  @override
  Color colorOf(ColorRole role, ThemeVariantId variant) {
    return _provider.valueOf(colorTokenRef(role), variant);
  }
}

final class BoundTypographyTokenEngine implements TypographyTokenEngine {
  final DesignTokenProvider _provider;

  const BoundTypographyTokenEngine({required DesignTokenProvider provider})
    : _provider = provider;

  @override
  TextStyle styleOf(TypographyRole role, ThemeVariantId variant) {
    return _provider.valueOf(typographyTokenRef(role), variant);
  }
}

final class BoundSpacingTokenEngine implements SpacingTokenEngine {
  final DesignTokenProvider _provider;

  const BoundSpacingTokenEngine({required DesignTokenProvider provider})
    : _provider = provider;

  @override
  double spaceOf(SpacingRelation relation) {
    // Spacing relations are universal: variant-free bindings.
    return _provider.valueOf(spacingTokenRef(relation), ThemeVariantId.light);
  }
}

final class BoundSurfaceTokenEngine implements SurfaceTokenEngine {
  final DesignTokenProvider _provider;

  const BoundSurfaceTokenEngine({required DesignTokenProvider provider})
    : _provider = provider;

  @override
  Color surfaceOf(SurfaceRole role, ThemeVariantId variant) {
    return _provider.valueOf(surfaceTokenRef(role), variant);
  }
}

final class BoundElevationTokenEngine
    implements ElevationTokenEngine<ElevationExpression> {
  final DesignTokenProvider _provider;

  const BoundElevationTokenEngine({required DesignTokenProvider provider})
    : _provider = provider;

  @override
  ElevationExpression expressionOf(
    ElevationMeaning meaning,
    ThemeVariantId variant,
  ) {
    // Elevation meanings are universal: variant-free bindings.
    return _provider.valueOf(elevationTokenRef(meaning), variant);
  }
}
