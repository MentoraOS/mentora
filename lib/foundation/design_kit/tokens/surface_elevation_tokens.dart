import 'dart:ui';

/// The v1 materialization of the surface roles (catalog §D4) — one set
/// per theme variant, values here and nowhere else.
final class SurfaceTokenSet {
  final Color scene;
  final Color primarySurface;
  final Color secondarySurface;
  final Color protectedSurface;
  final Color immersiveSurface;

  const SurfaceTokenSet({
    required this.scene,
    required this.primarySurface,
    required this.secondarySurface,
    required this.protectedSurface,
    required this.immersiveSurface,
  });
}

const SurfaceTokenSet lightSurfaceTokens = SurfaceTokenSet(
  scene: Color(0xFFF6F9F7),
  primarySurface: Color(0xFFFFFFFF),
  secondarySurface: Color(0xFFEFF4F1),
  protectedSurface: Color(0xFFFFFFFF),
  immersiveSurface: Color(0xFF0F1412),
);

const SurfaceTokenSet darkSurfaceTokens = SurfaceTokenSet(
  scene: Color(0xFF0F1412),
  primarySurface: Color(0xFF181E1B),
  secondarySurface: Color(0xFF202723),
  protectedSurface: Color(0xFF181E1B),
  immersiveSurface: Color(0xFF000000),
);

const SurfaceTokenSet lightHighContrastSurfaceTokens = SurfaceTokenSet(
  scene: Color(0xFFFFFFFF),
  primarySurface: Color(0xFFFFFFFF),
  secondarySurface: Color(0xFFF0F0F0),
  protectedSurface: Color(0xFFFFFFFF),
  immersiveSurface: Color(0xFF000000),
);

const SurfaceTokenSet darkHighContrastSurfaceTokens = SurfaceTokenSet(
  scene: Color(0xFF000000),
  primarySurface: Color(0xFF0C100E),
  secondarySurface: Color(0xFF161B18),
  protectedSurface: Color(0xFF0C100E),
  immersiveSurface: Color(0xFF000000),
);

/// The expression of an elevation MEANING — never a height. Flutter
/// only ever learns what being above implies: whether the layer blocks
/// what lies below, whether the scene dims, whether the layer is
/// exclusive (never stacked).
final class ElevationExpression {
  final bool blocksBelow;
  final bool dimsScene;
  final bool isExclusive;

  const ElevationExpression({
    required this.blocksBelow,
    required this.dimsScene,
    required this.isExclusive,
  });
}

/// The four meanings, expressed (catalog §D4): the aside consults and
/// returns; the decision is an enclosure; the immersion covers all by
/// its single door; the signal waits at its own level — no layer.
const ElevationExpression aparteExpression = ElevationExpression(
  blocksBelow: false,
  dimsScene: true,
  isExclusive: true,
);
const ElevationExpression decisionExpression = ElevationExpression(
  blocksBelow: true,
  dimsScene: true,
  isExclusive: true,
);
const ElevationExpression immersionExpression = ElevationExpression(
  blocksBelow: true,
  dimsScene: false,
  isExclusive: true,
);
const ElevationExpression signalementExpression = ElevationExpression(
  blocksBelow: false,
  dimsScene: false,
  isExclusive: false,
);
