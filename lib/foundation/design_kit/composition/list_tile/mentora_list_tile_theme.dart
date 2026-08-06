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
import '../../tokens/list_tile_tokens.dart';
import '../../components/design_kit_scope.dart';
import 'mentora_list_tile_style.dart';

/// What one tile paints — the ground it offers an entity, its
/// delimitation and how present it is.
final class MentoraListTileVisuals {
  final Color? ground;
  final Color? border;
  final Color? divider;
  final double opacity;

  const MentoraListTileVisuals({
    required this.ground,
    required this.border,
    required this.divider,
    required this.opacity,
  });
}

/// The List Tile Tokens Adapter — the only place where a density, a
/// chrome and a state become roles, relations and durations.
///
/// It resolves the tile's own surface and nothing else: the identity,
/// the words, the states and the acts are resolved by the components
/// that own them.
final class MentoraListTileTheme {
  final ColorTokenEngine _colors;
  final SpacingTokenEngine _spacing;
  final MotionEngine _motion;
  final AccessibilityEngine _accessibility;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraListTileTheme({
    required ColorTokenEngine colors,
    required SpacingTokenEngine spacing,
    required MotionEngine motion,
    required AccessibilityEngine accessibility,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _colors = colors,
       _spacing = spacing,
       _motion = motion,
       _accessibility = accessibility,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraListTileTheme.fromScope(DesignKitScope scope) {
    return MentoraListTileTheme(
      colors: scope.colors,
      spacing: scope.spacing,
      motion: scope.motion,
      accessibility: scope.accessibility,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  ListTileDensitySpec specOf(MentoraListTileDensity density) {
    switch (density) {
      case MentoraListTileDensity.standard:
        return standardListTileSpec;
      case MentoraListTileDensity.compact:
        return compactListTileSpec;
      case MentoraListTileDensity.large:
        return largeListTileSpec;
      case MentoraListTileDensity.dense:
        return denseListTileSpec;
    }
  }

  /// The breathing an entity is given — a spacing RELATION, declined
  /// by the density's own factor. Never a distance chosen here.
  EdgeInsetsGeometry paddingOf(MentoraListTileDensity density) {
    final breathing =
        _spacing.spaceOf(SpacingRelation.separationDistincte) *
        specOf(density).breathingFactor;
    return EdgeInsets.all(breathing);
  }

  double gapOf(MentoraListTileDensity density) =>
      _spacing.spaceOf(SpacingRelation.proximiteLiee) *
      specOf(density).breathingFactor;

  /// What survives of the breathing when the room grows short. The
  /// space is the first thing an entity gives up, and it gives up a
  /// share of its own gap — never a distance chosen here.
  double surrenderedGapOf(MentoraListTileDensity density) =>
      gapOf(density) * listTileSurrenderedGapFactor;

  double get lineGap => _spacing.spaceOf(SpacingRelation.proximiteLiee);

  /// The room a name needs to stay a name — everything else is given
  /// up before the words fall below it.
  double get wordsFloor => listTileWordsFloor;

  /// The room under which what completes the name says nothing.
  double get secondaryWordsFloor => listTileSecondaryWordsFloor;

  /// An entity that invites an act is a target: it honors the
  /// opposable minimum, whatever the density proposes.
  double minimumExtentOf({
    required MentoraListTileDensity density,
    required bool invitesAct,
  }) {
    final proposed = specOf(density).minimumExtent;
    if (!invitesAct) return proposed;
    return math.max(proposed, _accessibility.minimumTapTarget);
  }

  /// A tile accompanies the list it belongs to — it never announces
  /// itself.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.accompagner, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.accompagner);

  /// The ink of a held or hovered entity.
  Color get overlay => _role(ColorRole.highlight);

  /// The voices of an entity. The tile chooses WHICH role each zone
  /// speaks with; the words themselves are always MentoraText's.
  MentoraTextRole headlineRoleOf(MentoraListTileDensity density) {
    return density == MentoraListTileDensity.large
        ? MentoraTextRole.subtitle
        : MentoraTextRole.body;
  }

  MentoraTextRole get supportingRole =>
      const MentoraTextRole.of(TypographyRole.supporting);

  MentoraTextRole get metadataRole =>
      const MentoraTextRole.of(TypographyRole.metadata);

  MentoraTextRole get footerRole => MentoraTextRole.caption;

  MentoraListTileVisuals visualsOf({
    required MentoraListTileChrome chrome,
    required MentoraListTileState state,
  }) {
    final divider = chrome == MentoraListTileChrome.separated
        ? _role(ColorRole.divider)
        : null;

    switch (state) {
      case MentoraListTileState.disabled:
        return MentoraListTileVisuals(
          ground: _groundOf(chrome),
          border: _borderOf(chrome, _role(ColorRole.disabled)),
          divider: divider,
          opacity: listTileDisabledVeilOpacity,
        );
      case MentoraListTileState.archived:
        return MentoraListTileVisuals(
          ground: _groundOf(chrome),
          border: _borderOf(chrome, _role(ColorRole.outline)),
          divider: divider,
          opacity: listTileArchivedOpacity,
        );
      case MentoraListTileState.selected:
        // The chosen entity is brought forward by the selection role.
        return MentoraListTileVisuals(
          ground: _role(ColorRole.highlight),
          border: _borderOf(chrome, _role(ColorRole.selection)),
          divider: divider,
          opacity: listTileFullOpacity,
        );
      case MentoraListTileState.focused:
        return MentoraListTileVisuals(
          ground: _groundOf(chrome),
          border: _role(ColorRole.focus),
          divider: divider,
          opacity: listTileFullOpacity,
        );
      case MentoraListTileState.idle:
      case MentoraListTileState.hovered:
      case MentoraListTileState.loading:
        return MentoraListTileVisuals(
          ground: _groundOf(chrome),
          border: _borderOf(chrome, _role(ColorRole.outline)),
          divider: divider,
          opacity: listTileFullOpacity,
        );
    }
  }

  Color? _groundOf(MentoraListTileChrome chrome) {
    return chrome == MentoraListTileChrome.highlighted
        ? _role(ColorRole.highlight).withValues(alpha: listTileHighlightOpacity)
        : null;
  }

  Color? _borderOf(MentoraListTileChrome chrome, Color color) {
    return chrome == MentoraListTileChrome.outlined ? color : null;
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
