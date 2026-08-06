import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/material.dart' show IconData, Icons;
import 'package:flutter/widgets.dart'
    show Curve, EdgeInsets, EdgeInsetsGeometry;

import '../../accessibility/accessibility_engine.dart';
import '../../appearance/appearance_engine.dart';
import '../../components/text/mentora_text_role.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/search_bar_tokens.dart';
import '../../components/design_kit_scope.dart';
import 'mentora_search_bar_style.dart';

/// What the bar paints around the intention it carries.
final class MentoraSearchBarVisuals {
  final Color? ground;
  final Color? border;
  final Color mark;
  final double opacity;

  const MentoraSearchBarVisuals({
    required this.ground,
    required this.border,
    required this.mark,
    required this.opacity,
  });
}

/// The Search Bar Tokens Adapter — the only place where a variant and
/// a state become roles, extents and durations.
final class MentoraSearchBarTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final SpacingTokenEngine _spacing;
  final MotionEngine _motion;
  final AccessibilityEngine _accessibility;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraSearchBarTheme({
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
  factory MentoraSearchBarTheme.fromScope(DesignKitScope scope) {
    return MentoraSearchBarTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      spacing: scope.spacing,
      motion: scope.motion,
      accessibility: scope.accessibility,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// A bar accompanies someone writing an intention — it never
  /// announces itself, and it never hurries anyone.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.accompagner, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.accompagner);

  double extentOf(MentoraSearchBarVariant variant) =>
      math.max(specOf(variant).extent, _accessibility.minimumTapTarget);

  /// An aid is a target: it honors the opposable minimum, whatever the
  /// Token proposes.
  double get suggestionExtent =>
      math.max(searchSuggestionExtent, _accessibility.minimumTapTarget);

  EdgeInsetsGeometry get padding => EdgeInsets.symmetric(
    horizontal: _spacing.spaceOf(SpacingRelation.proximiteLiee),
  );

  EdgeInsetsGeometry get suggestionPadding => EdgeInsets.symmetric(
    horizontal: _spacing.spaceOf(SpacingRelation.separationDistincte),
  );

  double get gap => _spacing.spaceOf(SpacingRelation.proximiteLiee);

  double get sectionGap =>
      _spacing.spaceOf(SpacingRelation.respirationHierarchique);

  /// A bar helps; it never speaks with the voice of what is sought.
  MentoraTextRole get suggestionRole => MentoraTextRole.body;

  MentoraTextRole get suggestionSupportingRole =>
      const MentoraTextRole.of(TypographyRole.supporting);

  IconData get intentionMark => Icons.search;

  IconData get clearMark => Icons.close;

  MentoraSearchBarVisuals visualsOf({
    required MentoraSearchBarVariant variant,
    required MentoraSearchBarState state,
  }) {
    final presentation = specOf(variant);
    final Color mark;
    switch (state) {
      case MentoraSearchBarState.error:
        mark = _role(ColorRole.critical);
      case MentoraSearchBarState.focused:
      case MentoraSearchBarState.typing:
      case MentoraSearchBarState.searching:
        mark = _role(ColorRole.primary);
      case MentoraSearchBarState.disabled:
        mark = _role(ColorRole.unavailable);
      case MentoraSearchBarState.idle:
      case MentoraSearchBarState.loading:
        mark = _role(ColorRole.supporting);
    }

    return MentoraSearchBarVisuals(
      ground: presentation.hasGround
          ? _surfaces.surfaceOf(SurfaceRole.secondarySurface, _variant)
          : null,
      border: presentation.hasBorder ? _role(ColorRole.outline) : null,
      mark: mark,
      opacity: state == MentoraSearchBarState.disabled
          ? searchBarDisabledVeilOpacity
          : searchBarFullOpacity,
    );
  }

  /// The ground of an aid the pointer or the focus is holding.
  Color groundOfHeldSuggestion() => _role(
    ColorRole.highlight,
  ).withValues(alpha: searchSuggestionGroundOpacity);

  Color get suggestionMark => _role(ColorRole.supporting);

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
