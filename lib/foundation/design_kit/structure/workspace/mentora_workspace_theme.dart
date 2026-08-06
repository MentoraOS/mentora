import 'dart:ui' show Color;

import 'package:flutter/widgets.dart' show Curve;

import '../../appearance/appearance_engine.dart';
import '../../components/design_kit_scope.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';

/// The Workspace Tokens Adapter — the only place where a working
/// context becomes a ground and a duration.
///
/// A workspace paints almost nothing: it assembles. What it does paint
/// is the ground of the whole context — the one every transparent
/// chrome above it reveals.
final class MentoraWorkspaceTheme {
  final SurfaceTokenEngine _surfaces;
  final MotionEngine _motion;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraWorkspaceTheme({
    required SurfaceTokenEngine surfaces,
    required MotionEngine motion,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _surfaces = surfaces,
       _motion = motion,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraWorkspaceTheme.fromScope(DesignKitScope scope) {
    return MentoraWorkspaceTheme(
      surfaces: scope.surfaces,
      motion: scope.motion,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// A working context never announces itself: it shows the continuity
  /// of the context a person stays in.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.montrerLaContinuite, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.montrerLaContinuite);

  /// The ground of the whole working context.
  Color get scene => _surfaces.surfaceOf(SurfaceRole.scene, _variant);
}
