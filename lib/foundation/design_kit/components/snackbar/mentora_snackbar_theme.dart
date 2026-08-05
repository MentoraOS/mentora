import 'dart:ui' show Color;

import 'package:flutter/material.dart' show IconData, Icons;
import 'package:flutter/widgets.dart'
    show Curve, EdgeInsets, EdgeInsetsGeometry;

import '../../appearance/appearance_engine.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/surface_elevation_tokens.dart';
import '../design_kit_scope.dart';
import '../text/mentora_text_role.dart';
import 'mentora_snackbar_style.dart';

/// What one message paints — its surface, its delimitation and the
/// accent that names its meaning.
final class MentoraSnackbarVisuals {
  final Color surface;
  final Color border;
  final Color accent;

  const MentoraSnackbarVisuals({
    required this.surface,
    required this.border,
    required this.accent,
  });
}

/// The Snackbar Tokens Adapter — the only place where a variant and a
/// state become roles, durations and forms. It consumes the bound
/// engines exclusively.
final class MentoraSnackbarTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final SpacingTokenEngine _spacing;
  final ElevationTokenEngine<ElevationExpression> _elevation;
  final MotionEngine _motion;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraSnackbarTheme({
    required ColorTokenEngine colors,
    required SurfaceTokenEngine surfaces,
    required SpacingTokenEngine spacing,
    required ElevationTokenEngine<ElevationExpression> elevation,
    required MotionEngine motion,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _colors = colors,
       _surfaces = surfaces,
       _spacing = spacing,
       _elevation = elevation,
       _motion = motion,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraSnackbarTheme.fromScope(DesignKitScope scope) {
    return MentoraSnackbarTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      spacing: scope.spacing,
      elevation: scope.elevation,
      motion: scope.motion,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// A message waits at its own level: it takes no layer from anyone.
  ElevationExpression get expression =>
      _elevation.expressionOf(snackbarElevationMeaning, _variant);

  /// A message reassures — that is its motion intention, for arriving
  /// and for leaving. A message that must be seen attracts instead.
  Duration transitionDurationFor(MentoraSnackbarVariant variant) =>
      _motion.durationFor(_intentionOf(variant), _appearance);

  Curve curveFor(MentoraSnackbarVariant variant) =>
      _motion.curveFor(_intentionOf(variant));

  MotionIntention _intentionOf(MentoraSnackbarVariant variant) {
    switch (variant) {
      case MentoraSnackbarVariant.error:
      case MentoraSnackbarVariant.offline:
        return MotionIntention.attirerLAttention;
      case MentoraSnackbarVariant.information:
      case MentoraSnackbarVariant.success:
      case MentoraSnackbarVariant.warning:
      case MentoraSnackbarVariant.sync:
      case MentoraSnackbarVariant.processing:
      case MentoraSnackbarVariant.custom:
        return MotionIntention.rassurer;
    }
  }

  EdgeInsetsGeometry get padding => EdgeInsets.all(
    _spacing.spaceOf(SpacingRelation.separationDistincte),
  );

  double get contentGap => _spacing.spaceOf(SpacingRelation.proximiteLiee);

  /// The distance kept from the edges of the scene.
  double get sceneMargin =>
      _spacing.spaceOf(SpacingRelation.separationDistincte);

  MentoraTextRole get messageRole => MentoraTextRole.body;

  /// The accent that names the meaning — a role, never a decoration.
  ColorRole accentRoleOf(MentoraSnackbarVariant variant) {
    switch (variant) {
      case MentoraSnackbarVariant.information:
        return ColorRole.information;
      case MentoraSnackbarVariant.success:
        return ColorRole.success;
      case MentoraSnackbarVariant.warning:
        return ColorRole.warning;
      case MentoraSnackbarVariant.error:
        return ColorRole.critical;
      case MentoraSnackbarVariant.offline:
        return ColorRole.unavailable;
      case MentoraSnackbarVariant.sync:
      case MentoraSnackbarVariant.processing:
        return ColorRole.information;
      case MentoraSnackbarVariant.custom:
        return ColorRole.neutral;
    }
  }

  /// The signature of the meaning — a second reading, never the only
  /// one: the sentence always carries the sense (AFS-01).
  IconData? iconOf(MentoraSnackbarVariant variant) {
    switch (variant) {
      case MentoraSnackbarVariant.information:
        return Icons.info_outline;
      case MentoraSnackbarVariant.success:
        return Icons.check_circle_outline;
      case MentoraSnackbarVariant.warning:
        return Icons.warning_amber_outlined;
      case MentoraSnackbarVariant.error:
        return Icons.error_outline;
      case MentoraSnackbarVariant.offline:
        return Icons.cloud_off_outlined;
      case MentoraSnackbarVariant.sync:
      case MentoraSnackbarVariant.processing:
      case MentoraSnackbarVariant.custom:
        return null;
    }
  }

  MentoraSnackbarVisuals visualsOf({
    required MentoraSnackbarVariant variant,
    required MentoraSnackbarState state,
  }) {
    final accent = _role(accentRoleOf(variant));
    return MentoraSnackbarVisuals(
      // A message rests on the protected surface: it is readable over
      // anything the scene already carries.
      surface: _surfaces.surfaceOf(SurfaceRole.protectedSurface, _variant),
      // While it is being replaced in place, the message says so.
      border: state == MentoraSnackbarState.updating
          ? accent
          : _role(ColorRole.outline),
      accent: accent,
    );
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
