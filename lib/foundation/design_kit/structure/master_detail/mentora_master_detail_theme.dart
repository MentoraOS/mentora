import 'dart:ui' show Color;

import 'package:flutter/widgets.dart' show Curve;

import '../../appearance/appearance_engine.dart';
import '../../components/design_kit_scope.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/master_detail_tokens.dart';
import 'mentora_master_detail_style.dart';

/// What the relation itself paints — the line between the two spaces
/// and the veil over the one that waits behind the other.
final class MentoraMasterDetailVisuals {
  final Color divider;
  final Color scrim;

  const MentoraMasterDetailVisuals({
    required this.divider,
    required this.scrim,
  });
}

/// What one space paints: the ground it rests on.
///
/// The space being worked in rests on the primary surface; the one
/// that waits rests on the secondary. Nothing shouts: the difference
/// is the ground, never a border and never a colour of its own.
final class MentoraMasterDetailRegionVisuals {
  final Color surface;

  const MentoraMasterDetailRegionVisuals({required this.surface});
}

/// The Master Detail Tokens Adapter — the only place where a
/// presentation, a visibility and a region become roles, extents and
/// durations.
final class MentoraMasterDetailTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final MotionEngine _motion;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraMasterDetailTheme({
    required ColorTokenEngine colors,
    required SurfaceTokenEngine surfaces,
    required MotionEngine motion,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _colors = colors,
       _surfaces = surfaces,
       _motion = motion,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraMasterDetailTheme.fromScope(DesignKitScope scope) {
    return MentoraMasterDetailTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      motion: scope.motion,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// A relation never announces itself: it shows the continuity
  /// between the two spaces it holds together.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.montrerLaContinuite, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.montrerLaContinuite);

  MentoraMasterDetailVisuals visualsOf(
    MentoraMasterDetailPresentation presentation,
  ) {
    final passesInFront =
        presentation == MentoraMasterDetailPresentation.overlay;
    return MentoraMasterDetailVisuals(
      // The line exists only where two spaces share an edge.
      divider: _role(ColorRole.divider),
      scrim: _role(
        ColorRole.immersion,
      ).withValues(alpha: passesInFront ? masterDetailScrimOpacity : 0),
    );
  }

  MentoraMasterDetailRegionVisuals regionVisualsOf({
    required MentoraMasterDetailRegion region,
    required MentoraMasterDetailRegion activeRegion,
  }) {
    return MentoraMasterDetailRegionVisuals(
      surface: _surfaces.surfaceOf(
        region == activeRegion
            ? SurfaceRole.primarySurface
            : SurfaceRole.secondarySurface,
        _variant,
      ),
    );
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
