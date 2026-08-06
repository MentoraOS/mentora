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
import '../../tokens/drawer_tokens.dart';
import '../../components/design_kit_scope.dart';
import 'mentora_navigation_drawer_style.dart';

/// What the map paints around the places it shows.
final class MentoraDrawerVisuals {
  final Color surface;
  final Color? border;
  final Color divider;
  final Color scrim;

  const MentoraDrawerVisuals({
    required this.surface,
    required this.border,
    required this.divider,
    required this.scrim,
  });
}

/// What one destination paints in one state.
final class MentoraDrawerDestinationVisuals {
  final Color? ground;
  final Color mark;
  final ColorRole wordsRole;

  const MentoraDrawerDestinationVisuals({
    required this.ground,
    required this.mark,
    required this.wordsRole,
  });
}

/// The Navigation Drawer Tokens Adapter — the only place where a
/// presentation, a visibility and a state become roles, extents and
/// durations.
final class MentoraNavigationDrawerTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final SpacingTokenEngine _spacing;
  final MotionEngine _motion;
  final AccessibilityEngine _accessibility;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraNavigationDrawerTheme({
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
  factory MentoraNavigationDrawerTheme.fromScope(DesignKitScope scope) {
    return MentoraNavigationDrawerTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      spacing: scope.spacing,
      motion: scope.motion,
      accessibility: scope.accessibility,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// A map coming or going shows the continuity of the space — it is
  /// never an arrival, and never an announcement of itself.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.montrerLaContinuite, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.montrerLaContinuite);

  double widthOf(MentoraDrawerPresentation presentation) =>
      specOf(presentation).width;

  /// A destination is a target: it honors the opposable minimum,
  /// whatever the Token proposes.
  double get destinationExtent =>
      math.max(drawerDestinationExtent, _accessibility.minimumTapTarget);

  EdgeInsetsGeometry get padding =>
      EdgeInsets.all(_spacing.spaceOf(SpacingRelation.proximiteLiee));

  EdgeInsetsGeometry get destinationPadding => EdgeInsets.symmetric(
    horizontal: _spacing.spaceOf(SpacingRelation.separationDistincte),
  );

  double get gap => _spacing.spaceOf(SpacingRelation.proximiteLiee);

  double get sectionGap =>
      _spacing.spaceOf(SpacingRelation.respirationHierarchique);

  /// A map orients; it never speaks with the voice of the content it
  /// orients towards.
  MentoraTextRole get destinationRole => MentoraTextRole.label;

  MentoraTextRole get sectionRole =>
      const MentoraTextRole.of(TypographyRole.supporting);

  MentoraDrawerVisuals visualsOf(MentoraDrawerPresentation presentation) {
    final spec = specOf(presentation);
    return MentoraDrawerVisuals(
      surface: _surfaces.surfaceOf(SurfaceRole.primarySurface, _variant),
      border: spec.hasBorder ? _role(ColorRole.outline) : null,
      divider: _role(ColorRole.divider),
      scrim: _role(
        ColorRole.immersion,
      ).withValues(alpha: spec.dimsScene ? drawerScrimOpacity : 0),
    );
  }

  MentoraDrawerDestinationVisuals destinationVisualsOf(
    MentoraDrawerState state,
  ) {
    switch (state) {
      case MentoraDrawerState.selected:
        // Where the person is: the identity role, on its own ground.
        return MentoraDrawerDestinationVisuals(
          ground: _role(ColorRole.highlight),
          mark: _role(ColorRole.primary),
          wordsRole: ColorRole.primary,
        );
      case MentoraDrawerState.focused:
        return MentoraDrawerDestinationVisuals(
          ground: _role(
            ColorRole.focus,
          ).withValues(alpha: drawerSelectedGroundOpacity),
          mark: _role(ColorRole.focus),
          wordsRole: ColorRole.focus,
        );
      case MentoraDrawerState.hovered:
        return MentoraDrawerDestinationVisuals(
          ground: _role(
            ColorRole.highlight,
          ).withValues(alpha: drawerSelectedGroundOpacity),
          mark: _role(ColorRole.supporting),
          wordsRole: ColorRole.supporting,
        );
      case MentoraDrawerState.disabled:
        return MentoraDrawerDestinationVisuals(
          ground: null,
          mark: _role(ColorRole.unavailable),
          wordsRole: ColorRole.unavailable,
        );
      case MentoraDrawerState.idle:
        return MentoraDrawerDestinationVisuals(
          ground: null,
          mark: _role(ColorRole.supporting),
          wordsRole: ColorRole.supporting,
        );
    }
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
