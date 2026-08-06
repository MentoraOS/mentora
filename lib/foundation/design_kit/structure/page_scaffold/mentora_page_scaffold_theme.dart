import 'dart:ui' show Color;

import 'package:flutter/widgets.dart'
    show Curve, EdgeInsets, EdgeInsetsGeometry;

import '../../appearance/appearance_engine.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../components/design_kit_scope.dart';

/// What a page paints under everything it assembles.
final class MentoraPageScaffoldVisuals {
  final Color scene;
  final Color divider;

  const MentoraPageScaffoldVisuals({
    required this.scene,
    required this.divider,
  });
}

/// The Page Scaffold Tokens Adapter — the only place where the page's
/// own surface becomes roles and durations.
///
/// It resolves the scene and the lines between zones, and nothing
/// else: the content keeps its own breathing, because a page that
/// padded it would be deciding for it.
final class MentoraPageScaffoldTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final SpacingTokenEngine _spacing;
  final MotionEngine _motion;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraPageScaffoldTheme({
    required ColorTokenEngine colors,
    required SurfaceTokenEngine surfaces,
    required SpacingTokenEngine spacing,
    required MotionEngine motion,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _colors = colors,
       _surfaces = surfaces,
       _spacing = spacing,
       _motion = motion,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraPageScaffoldTheme.fromScope(DesignKitScope scope) {
    return MentoraPageScaffoldTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      spacing: scope.spacing,
      motion: scope.motion,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// A page assembles a context that does not change while one moves
  /// through it: what it expresses is a continuity.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.montrerLaContinuite, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.montrerLaContinuite);

  /// The breathing around the acts a page keeps at hand — a spacing
  /// RELATION, and the only one a page ever applies, because those
  /// acts belong to the page and not to the content.
  EdgeInsetsGeometry get actsPadding =>
      EdgeInsets.all(_spacing.spaceOf(SpacingRelation.separationDistincte));

  double get actsGap => _spacing.spaceOf(SpacingRelation.proximiteLiee);

  MentoraPageScaffoldVisuals get visuals => MentoraPageScaffoldVisuals(
    scene: _surfaces.surfaceOf(SurfaceRole.scene, _variant),
    divider: _colors.colorOf(ColorRole.divider, _variant),
  );
}
