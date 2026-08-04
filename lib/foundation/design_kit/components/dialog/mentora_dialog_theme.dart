import 'dart:ui' show Color;

import 'package:flutter/material.dart' show IconData, Icons;
import 'package:flutter/widgets.dart'
    show Curve, EdgeInsets, EdgeInsetsGeometry;

import '../../appearance/appearance_engine.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/dialog_tokens.dart';
import '../../tokens/surface_elevation_tokens.dart';
import '../button/mentora_button_style.dart';
import '../design_kit_scope.dart';
import '../text/mentora_text_role.dart';
import 'mentora_dialog_request.dart';
import 'mentora_dialog_style.dart';

/// What one dialog paints — its surface, its delimitation and the
/// accent that names its meaning.
final class MentoraDialogVisuals {
  final Color surface;
  final Color border;
  final Color scrim;
  final Color accent;

  const MentoraDialogVisuals({
    required this.surface,
    required this.border,
    required this.scrim,
    required this.accent,
  });
}

/// The Dialog Tokens Adapter — the only place where a variant, a
/// state and an elevation MEANING become roles, durations and forms.
/// It consumes the bound engines exclusively.
final class MentoraDialogTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final SpacingTokenEngine _spacing;
  final ElevationTokenEngine<ElevationExpression> _elevation;
  final MotionEngine _motion;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraDialogTheme({
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
  factory MentoraDialogTheme.fromScope(DesignKitScope scope) {
    return MentoraDialogTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      spacing: scope.spacing,
      elevation: scope.elevation,
      motion: scope.motion,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// The expression of the variant's elevation MEANING — the meaning
  /// itself is declared once, in the style vocabulary.
  ElevationExpression expressionOf(MentoraDialogVariant variant) =>
      _elevation.expressionOf(elevationMeaningOf(variant), _variant);

  /// Stepping back is offered exactly when the layer does not block
  /// what lies below — the expression decides, never a boolean the
  /// caller invents.
  bool allowsStepBack(MentoraDialogVariant variant) =>
      !expressionOf(variant).blocksBelow;

  /// A layer arrives while the scene stays: the context is preserved.
  /// A critical layer must be seen: it attracts.
  Duration transitionDurationFor(MentoraDialogVariant variant) {
    final intention = variant == MentoraDialogVariant.critical
        ? MotionIntention.attirerLAttention
        : MotionIntention.preserverLeContexte;
    return _motion.durationFor(intention, _appearance);
  }

  Curve curveFor(MentoraDialogVariant variant) {
    final intention = variant == MentoraDialogVariant.critical
        ? MotionIntention.attirerLAttention
        : MotionIntention.preserverLeContexte;
    return _motion.curveFor(intention);
  }

  EdgeInsetsGeometry get padding =>
      EdgeInsets.all(_spacing.spaceOf(SpacingRelation.espaceFocus));

  double get contentGap => _spacing.spaceOf(SpacingRelation.proximiteLiee);

  double get sectionGap =>
      _spacing.spaceOf(SpacingRelation.respirationHierarchique);

  double get sceneMargin =>
      _spacing.spaceOf(SpacingRelation.separationDistincte);

  MentoraTextRole get titleRole => MentoraTextRole.subtitle;

  MentoraTextRole get messageRole => MentoraTextRole.body;

  /// A consequence is stated with the weight of what it costs — it is
  /// never a footnote of the message.
  MentoraTextRole consequenceRoleFor(MentoraDialogVariant variant) {
    return variant == MentoraDialogVariant.critical
        ? const MentoraTextRole.of(TypographyRole.critical)
        : const MentoraTextRole.of(TypographyRole.warning);
  }

  /// The accent that names the meaning — a role, never a decoration.
  ColorRole accentRoleOf(MentoraDialogVariant variant) {
    switch (variant) {
      case MentoraDialogVariant.information:
        return ColorRole.information;
      case MentoraDialogVariant.success:
        return ColorRole.success;
      case MentoraDialogVariant.warning:
        return ColorRole.warning;
      case MentoraDialogVariant.critical:
        return ColorRole.critical;
      case MentoraDialogVariant.confirmation:
        return ColorRole.primary;
      case MentoraDialogVariant.decision:
        return ColorRole.attention;
      case MentoraDialogVariant.progress:
      case MentoraDialogVariant.custom:
        return ColorRole.neutral;
    }
  }

  /// The signature of the meaning — a second reading, never the only
  /// one: the title always carries the sense (AFS-01).
  IconData? iconOf(MentoraDialogVariant variant) {
    switch (variant) {
      case MentoraDialogVariant.information:
        return Icons.info_outline;
      case MentoraDialogVariant.success:
        return Icons.check_circle_outline;
      case MentoraDialogVariant.warning:
        return Icons.warning_amber_outlined;
      case MentoraDialogVariant.critical:
        return Icons.report_gmailerrorred_outlined;
      case MentoraDialogVariant.confirmation:
        return Icons.help_outline;
      case MentoraDialogVariant.decision:
        return Icons.alt_route_outlined;
      case MentoraDialogVariant.progress:
      case MentoraDialogVariant.custom:
        return null;
    }
  }

  /// How an act presents itself: a recommendation is visible, a
  /// danger stays explicit, the rest steps back.
  MentoraButtonVariant buttonVariantOf(
    MentoraDialogAction action,
    MentoraDialogVariant variant,
  ) {
    if (action.isDangerous) return MentoraButtonVariant.danger;
    if (action.isRecommended) {
      return variant == MentoraDialogVariant.critical
          ? MentoraButtonVariant.tonal
          : MentoraButtonVariant.contained;
    }
    return MentoraButtonVariant.text;
  }

  MentoraDialogVisuals visualsOf({
    required MentoraDialogVariant variant,
    required MentoraDialogState state,
  }) {
    final accent = _role(accentRoleOf(variant));
    final Color border;
    switch (state) {
      case MentoraDialogState.error:
        border = _role(ColorRole.critical);
      case MentoraDialogState.success:
        border = _role(ColorRole.success);
      case MentoraDialogState.closed:
      case MentoraDialogState.opening:
      case MentoraDialogState.opened:
      case MentoraDialogState.waiting:
      case MentoraDialogState.processing:
      case MentoraDialogState.closing:
        border = _role(ColorRole.outline);
    }
    return MentoraDialogVisuals(
      surface: _surfaces.surfaceOf(SurfaceRole.protectedSurface, _variant),
      border: border,
      // The scene dims only when the expression says it dims.
      scrim: _role(ColorRole.immersion).withValues(
        alpha: expressionOf(variant).dimsScene ? dialogScrimOpacity : 0,
      ),
      accent: accent,
    );
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
