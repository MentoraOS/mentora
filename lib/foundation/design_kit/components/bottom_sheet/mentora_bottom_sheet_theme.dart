import 'dart:ui' show Color;

import 'package:flutter/widgets.dart'
    show Curve, EdgeInsets, EdgeInsetsGeometry;

import '../../accessibility/accessibility_engine.dart';
import '../../appearance/appearance_engine.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/bottom_sheet_tokens.dart';
import '../../tokens/surface_elevation_tokens.dart';
import '../design_kit_scope.dart';
import '../text/mentora_text_role.dart';
import 'mentora_bottom_sheet_style.dart';

/// What one sheet paints — its surface, its delimitation, its veil
/// and the grip that says it can be moved.
final class MentoraBottomSheetVisuals {
  final Color surface;
  final Color border;
  final Color scrim;
  final Color handle;

  const MentoraBottomSheetVisuals({
    required this.surface,
    required this.border,
    required this.scrim,
    required this.handle,
  });
}

/// The BottomSheet Tokens Adapter — the only place where a variant, a
/// detent and a state become roles, fractions and durations. It
/// consumes the bound engines exclusively.
final class MentoraBottomSheetTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final SpacingTokenEngine _spacing;
  final ElevationTokenEngine<ElevationExpression> _elevation;
  final MotionEngine _motion;
  final AccessibilityEngine _accessibility;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraBottomSheetTheme({
    required ColorTokenEngine colors,
    required SurfaceTokenEngine surfaces,
    required SpacingTokenEngine spacing,
    required ElevationTokenEngine<ElevationExpression> elevation,
    required MotionEngine motion,
    required AccessibilityEngine accessibility,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _colors = colors,
       _surfaces = surfaces,
       _spacing = spacing,
       _elevation = elevation,
       _motion = motion,
       _accessibility = accessibility,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraBottomSheetTheme.fromScope(DesignKitScope scope) {
    return MentoraBottomSheetTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      spacing: scope.spacing,
      elevation: scope.elevation,
      motion: scope.motion,
      accessibility: scope.accessibility,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// A sheet always carries the aparté: it dims without blocking, it
  /// consults and returns.
  ElevationExpression get expression =>
      _elevation.expressionOf(bottomSheetElevationMeaning, _variant);

  /// A sheet accompanies — that is its motion intention, and the only
  /// one it ever uses, for arriving, settling and leaving.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.accompagner, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.accompagner);

  double fractionOf(MentoraBottomSheetDetent detent) {
    switch (detent) {
      case MentoraBottomSheetDetent.collapsed:
        return bottomSheetCollapsedFraction;
      case MentoraBottomSheetDetent.expanded:
        return bottomSheetExpandedFraction;
    }
  }

  /// Which detent a released gesture belongs to — the nearest one,
  /// never a surprise.
  MentoraBottomSheetDetent detentNearest(double fraction) {
    final toCollapsed =
        (fraction - bottomSheetCollapsedFraction).abs();
    final toExpanded = (fraction - bottomSheetExpandedFraction).abs();
    return toCollapsed <= toExpanded
        ? MentoraBottomSheetDetent.collapsed
        : MentoraBottomSheetDetent.expanded;
  }

  /// Past this much travel below its resting place, releasing lets
  /// the sheet go.
  bool releasesTheSheet({
    required double fraction,
    required MentoraBottomSheetDetent from,
  }) {
    final travel = fractionOf(from) - fraction;
    return travel >= fractionOf(from) * bottomSheetDismissTravelFraction;
  }

  EdgeInsetsGeometry get padding =>
      EdgeInsets.all(_spacing.spaceOf(SpacingRelation.espaceFocus));

  double get contentGap => _spacing.spaceOf(SpacingRelation.proximiteLiee);

  double get sectionGap =>
      _spacing.spaceOf(SpacingRelation.respirationHierarchique);

  /// The grip is a target like any other: it honors the opposable
  /// minimum, whatever its painted size.
  double get handleTargetExtent => _accessibility.minimumTapTarget;

  MentoraTextRole get titleRole => MentoraTextRole.subtitle;

  MentoraBottomSheetVisuals visualsOf({
    required MentoraBottomSheetVariant variant,
    required MentoraBottomSheetState state,
  }) {
    final Color border;
    switch (state) {
      case MentoraBottomSheetState.dragging:
        // While it is held, the sheet says so.
        border = _role(ColorRole.focus);
      case MentoraBottomSheetState.closed:
      case MentoraBottomSheetState.opening:
      case MentoraBottomSheetState.opened:
      case MentoraBottomSheetState.expanded:
      case MentoraBottomSheetState.collapsed:
      case MentoraBottomSheetState.processing:
      case MentoraBottomSheetState.closing:
        border = _role(ColorRole.outline);
    }
    return MentoraBottomSheetVisuals(
      surface: _surfaces.surfaceOf(
        variant == MentoraBottomSheetVariant.preview
            ? SurfaceRole.secondarySurface
            : SurfaceRole.primarySurface,
        _variant,
      ),
      border: border,
      scrim: _role(ColorRole.immersion).withValues(
        alpha: expression.dimsScene ? bottomSheetScrimOpacity : 0,
      ),
      handle: _role(ColorRole.supporting),
    );
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
