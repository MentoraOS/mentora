import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/widgets.dart' show Curve;

import '../../accessibility/accessibility_engine.dart';
import '../../appearance/appearance_engine.dart';
import '../../components/design_kit_scope.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/split_view_tokens.dart';
import 'mentora_split_view_style.dart';

/// What one separation paints in one state.
///
/// A separation is a line: it says that two regions exist. When a
/// person may move it, it says that too — by its own presence, never
/// by a decoration.
final class MentoraSplitSeparatorVisuals {
  final Color line;

  const MentoraSplitSeparatorVisuals({required this.line});
}

/// The Split View Tokens Adapter — the only place where an axis and a
/// separation state become roles, extents and durations.
final class MentoraSplitViewTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final MotionEngine _motion;
  final AccessibilityEngine _accessibility;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraSplitViewTheme({
    required ColorTokenEngine colors,
    required SurfaceTokenEngine surfaces,
    required MotionEngine motion,
    required AccessibilityEngine accessibility,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _colors = colors,
       _surfaces = surfaces,
       _motion = motion,
       _accessibility = accessibility,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraSplitViewTheme.fromScope(DesignKitScope scope) {
    return MentoraSplitViewTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      motion: scope.motion,
      accessibility: scope.accessibility,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// A workspace never announces itself: it shows the continuity of
  /// the space the regions share.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.montrerLaContinuite, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.montrerLaContinuite);

  /// The ground the regions share. They are equals: none of them is
  /// more of a region than the others.
  Color get regionSurface =>
      _surfaces.surfaceOf(SurfaceRole.primarySurface, _variant);

  double get separatorThickness => splitViewSeparatorThickness;

  /// The room a person may take hold of. A separation one can move is
  /// an interactive surface: the opposable reachable target prevails
  /// over the token, always.
  double get separatorGrabExtent =>
      math.max(splitViewSeparatorGrabExtent, _accessibility.minimumTapTarget);

  /// One step of a move asked without a pointer.
  double get resizeStep => splitViewResizeStep;

  MentoraSplitSeparatorVisuals separatorVisualsOf(
    MentoraSplitSeparatorState state,
  ) {
    switch (state) {
      case MentoraSplitSeparatorState.dragged:
      case MentoraSplitSeparatorState.hovered:
        // The person is about to act on it, or is acting on it: the
        // line says so, and says nothing else.
        return MentoraSplitSeparatorVisuals(line: _role(ColorRole.focus));
      case MentoraSplitSeparatorState.fixed:
      case MentoraSplitSeparatorState.idle:
        return MentoraSplitSeparatorVisuals(line: _role(ColorRole.divider));
    }
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
