import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/widgets.dart'
    show Curve, EdgeInsets, EdgeInsetsGeometry;

import '../../accessibility/accessibility_engine.dart';
import '../../appearance/appearance_engine.dart';
import '../../components/text/mentora_text_role.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/tabs_tokens.dart';
import '../../components/design_kit_scope.dart';
import 'mentora_tabs_style.dart';

/// What the set paints around its facets.
final class MentoraTabsVisuals {
  final Color? enclosure;
  final Color? border;
  final Color? baseline;
  final double opacity;

  const MentoraTabsVisuals({
    required this.enclosure,
    required this.border,
    required this.baseline,
    required this.opacity,
  });
}

/// What one facet paints in one state.
final class MentoraTabVisuals {
  final Color? ground;
  final Color? indicator;
  final Color mark;
  final ColorRole wordsRole;

  const MentoraTabVisuals({
    required this.ground,
    required this.indicator,
    required this.mark,
    required this.wordsRole,
  });
}

/// The Tabs Tokens Adapter — the only place where an emphasis, a
/// shape and a state become roles, extents and durations.
final class MentoraTabsTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final SpacingTokenEngine _spacing;
  final MotionEngine _motion;
  final AccessibilityEngine _accessibility;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraTabsTheme({
    required ColorTokenEngine colors,
    required SurfaceTokenEngine surfaces,
    required SpacingTokenEngine spacing,
    required MotionEngine motion,
    required AccessibilityEngine accessibility,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _colors = colors,
       _surfaces = surfaces,
       _spacing = spacing,
       _motion = motion,
       _accessibility = accessibility,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraTabsTheme.fromScope(DesignKitScope scope) {
    return MentoraTabsTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      spacing: scope.spacing,
      motion: scope.motion,
      accessibility: scope.accessibility,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// Revealing another facet of the same context is a continuity —
  /// never an arrival, never an announcement.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.montrerLaContinuite, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.montrerLaContinuite);

  /// A facet is a target: it honors the opposable minimum, whatever
  /// the Token proposes.
  double get facetExtent =>
      math.max(tabExtent, _accessibility.minimumTapTarget);

  EdgeInsetsGeometry get facetPadding => EdgeInsets.symmetric(
    horizontal: _spacing.spaceOf(SpacingRelation.separationDistincte),
  );

  EdgeInsetsGeometry get enclosurePadding =>
      EdgeInsets.all(_spacing.spaceOf(SpacingRelation.proximiteLiee));

  double get gap => _spacing.spaceOf(SpacingRelation.proximiteLiee);

  double radiusOf(MentoraTabsShape shape) {
    switch (shape) {
      case MentoraTabsShape.underline:
        return tabIndicatorRadius;
      case MentoraTabsShape.segmented:
        return tabSegmentedRadius;
      case MentoraTabsShape.contained:
        return tabContainedRadius;
    }
  }

  /// A set organizes; it never speaks with the voice of the content
  /// it organizes.
  MentoraTextRole get wordsRole => MentoraTextRole.label;

  /// The role that names the chosen facet — the identity of the
  /// context for a primary set, its second voice for a secondary one.
  ColorRole emphasisRoleOf(MentoraTabsEmphasis emphasis) {
    return emphasis == MentoraTabsEmphasis.primary
        ? ColorRole.primary
        : ColorRole.secondary;
  }

  MentoraTabsVisuals visualsOf({
    required MentoraTabsShape shape,
    required bool live,
  }) {
    return MentoraTabsVisuals(
      // A segmented set is an enclosure; the others are not.
      enclosure: shape == MentoraTabsShape.segmented
          ? _surfaces.surfaceOf(SurfaceRole.secondarySurface, _variant)
          : null,
      border: shape == MentoraTabsShape.segmented
          ? _role(ColorRole.outline)
          : null,
      // An underlined set rests on the line its facets share.
      baseline: shape == MentoraTabsShape.underline
          ? _role(ColorRole.divider)
          : null,
      opacity: live ? tabsFullOpacity : tabsDisabledVeilOpacity,
    );
  }

  MentoraTabVisuals facetVisualsOf({
    required MentoraTabsEmphasis emphasis,
    required MentoraTabsShape shape,
    required MentoraTabsState state,
  }) {
    final accent = _role(emphasisRoleOf(emphasis));
    switch (state) {
      case MentoraTabsState.selected:
        return MentoraTabVisuals(
          ground: shape == MentoraTabsShape.underline
              ? null
              : accent.withValues(alpha: tabSelectedGroundOpacity),
          indicator: shape == MentoraTabsShape.underline ? accent : null,
          mark: accent,
          wordsRole: emphasisRoleOf(emphasis),
        );
      case MentoraTabsState.focused:
        return MentoraTabVisuals(
          ground: _role(
            ColorRole.focus,
          ).withValues(alpha: tabSelectedGroundOpacity),
          indicator: null,
          mark: _role(ColorRole.focus),
          wordsRole: ColorRole.focus,
        );
      case MentoraTabsState.hovered:
        return MentoraTabVisuals(
          ground: _role(
            ColorRole.highlight,
          ).withValues(alpha: tabSelectedGroundOpacity),
          indicator: null,
          mark: _role(ColorRole.supporting),
          wordsRole: ColorRole.supporting,
        );
      case MentoraTabsState.disabled:
        return MentoraTabVisuals(
          ground: null,
          indicator: null,
          mark: _role(ColorRole.unavailable),
          wordsRole: ColorRole.unavailable,
        );
      case MentoraTabsState.loading:
      case MentoraTabsState.idle:
        return MentoraTabVisuals(
          ground: null,
          indicator: null,
          mark: _role(ColorRole.supporting),
          wordsRole: ColorRole.supporting,
        );
    }
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
