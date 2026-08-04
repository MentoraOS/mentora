/// The v1 materialization of the Card contract (Component domain,
/// chapter Container — catalog §D7). Values live here and nowhere
/// else; upstream admission follows the registry protocol, like the
/// button form and the navigation chrome.
library;

/// How a raised container reads its depth. A Card never carries an
/// elevation MEANING: the four meanings (aparté, décision, immersion,
/// signalement) belong to the layers that pass in front of the scene.
/// A Card lives IN the scene — its depth is a surface expression.
final class CardShadowSpec {
  final double blurRadius;
  final double verticalOffset;
  final double spreadRadius;

  /// The diffusion of the scene's ink under the raised container.
  final double opacity;

  const CardShadowSpec({
    required this.blurRadius,
    required this.verticalOffset,
    required this.spreadRadius,
    required this.opacity,
  });
}

const CardShadowSpec cardShadow = CardShadowSpec(
  blurRadius: 12,
  verticalOffset: 2,
  spreadRadius: 0,
  opacity: 0.08,
);

/// Shared container form materialization (RadiusRole.container,
/// BorderRole.outline, BorderRole.focusRing, OpacityRole.disabledVeil).
const double cardCornerRadius = 16;
const double cardBorderWidth = 1;
const double cardFocusRingWidth = 2;
const double cardDisabledVeilOpacity = 0.38;
