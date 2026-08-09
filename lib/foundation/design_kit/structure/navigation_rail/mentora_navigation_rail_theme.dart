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
import '../../tokens/navigation_rail_tokens.dart';
import '../../components/design_kit_scope.dart';
import 'mentora_navigation_rail_style.dart';

/// What the structure paints — the ground it rests on, its
/// delimitation and how present it is.
final class MentoraNavigationRailVisuals {
  final Color? surface;
  final Color? border;
  final Color? divider;
  final double opacity;

  const MentoraNavigationRailVisuals({
    required this.surface,
    required this.border,
    required this.divider,
    required this.opacity,
  });
}

/// What one destination paints in one state.
final class MentoraNavigationRailDestinationVisuals {
  final Color? indicator;
  final Color mark;
  final ColorRole wordsRole;

  const MentoraNavigationRailDestinationVisuals({
    required this.indicator,
    required this.mark,
    required this.wordsRole,
  });
}

/// The Navigation Rail Tokens Adapter — the only place where a
/// display, a chrome and a state become roles, extents and durations.
///
/// It resolves the structure's own surface and the expression of its
/// destinations; the words, the states and the identity are resolved
/// by the components that own them.
final class MentoraNavigationRailTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final SpacingTokenEngine _spacing;
  final MotionEngine _motion;
  final AccessibilityEngine _accessibility;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraNavigationRailTheme({
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
  factory MentoraNavigationRailTheme.fromScope(DesignKitScope scope) {
    return MentoraNavigationRailTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      spacing: scope.spacing,
      motion: scope.motion,
      accessibility: scope.accessibility,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// A structure accompanies the content beside it — it never
  /// announces itself, and it never competes.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.accompagner, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.accompagner);

  double widthOf(MentoraNavigationRailDisplay display) => specOf(display).width;

  /// A destination is a target: it honors the opposable minimum,
  /// whatever the Token proposes.
  double get destinationExtent => math.max(
    navigationRailDestinationExtent,
    _accessibility.minimumTapTarget,
  );

  EdgeInsetsGeometry get padding =>
      EdgeInsets.all(_spacing.spaceOf(SpacingRelation.proximiteLiee));

  double get gap => _spacing.spaceOf(SpacingRelation.proximiteLiee);

  double get sectionGap =>
      _spacing.spaceOf(SpacingRelation.respirationHierarchique);

  /// A structure never competes with the content: its words stay a
  /// label, never a title.
  MentoraTextRole get wordsRole => MentoraTextRole.label;

  MentoraNavigationRailVisuals visualsOf({
    required MentoraNavigationRailChrome chrome,
    required MentoraNavigationRailState state,
  }) {
    final transparent = chrome == MentoraNavigationRailChrome.transparent;
    return MentoraNavigationRailVisuals(
      surface: transparent
          ? null
          : _surfaces.surfaceOf(SurfaceRole.primarySurface, _variant),
      border: chrome == MentoraNavigationRailChrome.floating
          ? _role(ColorRole.outline)
          : null,
      // A structure that stands against the content delimits itself;
      // one that floats beside it does not need to.
      divider: chrome == MentoraNavigationRailChrome.surface
          ? _role(ColorRole.divider)
          : null,
      opacity: state == MentoraNavigationRailState.disabled
          ? navigationRailDisabledVeilOpacity
          : navigationRailFullOpacity,
    );
  }

  MentoraNavigationRailDestinationVisuals destinationVisualsOf(
    MentoraNavigationRailState state,
  ) {
    switch (state) {
      case MentoraNavigationRailState.selected:
        // Where the person is: the identity role, on its own ground.
        return MentoraNavigationRailDestinationVisuals(
          indicator: _role(ColorRole.highlight),
          mark: _role(ColorRole.primary),
          wordsRole: ColorRole.primary,
        );
      case MentoraNavigationRailState.focused:
        return MentoraNavigationRailDestinationVisuals(
          indicator: _role(
            ColorRole.focus,
          ).withValues(alpha: navigationRailIndicatorOpacity),
          mark: _role(ColorRole.focus),
          wordsRole: ColorRole.focus,
        );
      case MentoraNavigationRailState.hovered:
        return MentoraNavigationRailDestinationVisuals(
          indicator: _role(
            ColorRole.highlight,
          ).withValues(alpha: navigationRailIndicatorOpacity),
          mark: _role(ColorRole.supporting),
          wordsRole: ColorRole.supporting,
        );
      case MentoraNavigationRailState.disabled:
        return MentoraNavigationRailDestinationVisuals(
          indicator: null,
          mark: _role(ColorRole.unavailable),
          wordsRole: ColorRole.unavailable,
        );
      case MentoraNavigationRailState.idle:
      case MentoraNavigationRailState.collapsed:
      case MentoraNavigationRailState.expanded:
        return MentoraNavigationRailDestinationVisuals(
          indicator: null,
          mark: _role(ColorRole.supporting),
          wordsRole: ColorRole.supporting,
        );
    }
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
