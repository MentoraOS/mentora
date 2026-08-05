import 'dart:ui' show Color;

import 'package:flutter/material.dart' show IconData, Icons;
import 'package:flutter/widgets.dart' show BorderRadius, Curve;

import '../../appearance/appearance_engine.dart';
import '../../motion/motion_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../../tokens/avatar_tokens.dart';
import '../design_kit_scope.dart';
import '../text/mentora_text_role.dart';
import 'mentora_avatar_style.dart';

/// What one identity paints — a ground, a delimitation and the accent
/// that names what kind of identity it is.
final class MentoraAvatarVisuals {
  final Color ground;
  final Color border;
  final Color accent;
  final double opacity;

  const MentoraAvatarVisuals({
    required this.ground,
    required this.border,
    required this.accent,
    required this.opacity,
  });
}

/// The Avatar Tokens Adapter — the only place where an identity, a
/// form, an extent and a state become roles, distances and durations.
/// It consumes the bound engines exclusively.
final class MentoraAvatarTheme {
  final ColorTokenEngine _colors;
  final SurfaceTokenEngine _surfaces;
  final MotionEngine _motion;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraAvatarTheme({
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
  factory MentoraAvatarTheme.fromScope(DesignKitScope scope) {
    return MentoraAvatarTheme(
      colors: scope.colors,
      surfaces: scope.surfaces,
      motion: scope.motion,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  AvatarSizeSpec specOf(MentoraAvatarSize size) {
    switch (size) {
      case MentoraAvatarSize.extraSmall:
        return extraSmallAvatarSpec;
      case MentoraAvatarSize.small:
        return smallAvatarSpec;
      case MentoraAvatarSize.medium:
        return mediumAvatarSpec;
      case MentoraAvatarSize.large:
        return largeAvatarSpec;
      case MentoraAvatarSize.extraLarge:
        return extraLargeAvatarSpec;
      case MentoraAvatarSize.doubleExtraLarge:
        return doubleExtraLargeAvatarSpec;
    }
  }

  /// The form, expressed at the identity's own extent: a circle is
  /// half of itself, a rounded identity keeps the same softness at
  /// every size.
  BorderRadius radiusOf(MentoraAvatarShape shape, MentoraAvatarSize size) {
    final extent = specOf(size).extent;
    switch (shape) {
      case MentoraAvatarShape.circle:
        return BorderRadius.circular(extent / 2);
      case MentoraAvatarShape.rounded:
        return BorderRadius.circular(extent * avatarRoundedRadiusFactor);
      case MentoraAvatarShape.square:
        return BorderRadius.circular(avatarSquareRadius);
    }
  }

  /// An identity appearing accompanies what it qualifies — it never
  /// announces itself.
  Duration get transitionDuration =>
      _motion.durationFor(MotionIntention.accompagner, _appearance);

  Curve get curve => _motion.curveFor(MotionIntention.accompagner);

  /// The voice the initials speak with — the identity grows with its
  /// extent, and stays legible at every font scale.
  MentoraTextRole initialsRoleOf(MentoraAvatarSize size) {
    switch (size) {
      case MentoraAvatarSize.extraSmall:
      case MentoraAvatarSize.small:
        return MentoraTextRole.caption;
      case MentoraAvatarSize.medium:
        return MentoraTextRole.label;
      case MentoraAvatarSize.large:
        return MentoraTextRole.body;
      case MentoraAvatarSize.extraLarge:
        return MentoraTextRole.subtitle;
      case MentoraAvatarSize.doubleExtraLarge:
        return MentoraTextRole.title;
    }
  }

  /// The role that names the KIND of identity — never a decoration,
  /// and never a status: an avatar says who, never how they are.
  ColorRole accentRoleOf(MentoraAvatarIdentity identity) {
    switch (identity) {
      case MentoraAvatarIdentity.photo:
      case MentoraAvatarIdentity.initials:
      case MentoraAvatarIdentity.user:
        return ColorRole.primary;
      case MentoraAvatarIdentity.organisation:
      case MentoraAvatarIdentity.company:
        return ColorRole.secondary;
      case MentoraAvatarIdentity.ai:
        return ColorRole.aiSuggestion;
      case MentoraAvatarIdentity.system:
        return ColorRole.information;
      case MentoraAvatarIdentity.guest:
        return ColorRole.supporting;
      case MentoraAvatarIdentity.unknown:
      case MentoraAvatarIdentity.loading:
        return ColorRole.neutral;
    }
  }

  /// The colour role the initials speak with, once the state has had
  /// its say.
  ColorRole initialsColorRoleOf({
    required MentoraAvatarIdentity identity,
    required MentoraAvatarState state,
  }) {
    switch (state) {
      case MentoraAvatarState.disabled:
        return ColorRole.unavailable;
      case MentoraAvatarState.archived:
        return ColorRole.neutral;
      case MentoraAvatarState.idle:
      case MentoraAvatarState.loading:
      case MentoraAvatarState.unavailable:
        return accentRoleOf(identity);
    }
  }

  /// The mark that stands for the identity when no portrait and no
  /// initials are available — the identity always survives the
  /// absence of an image.
  IconData markOf(MentoraAvatarIdentity identity) {
    switch (identity) {
      case MentoraAvatarIdentity.photo:
      case MentoraAvatarIdentity.initials:
      case MentoraAvatarIdentity.user:
        return Icons.person_outline;
      case MentoraAvatarIdentity.organisation:
        return Icons.account_balance_outlined;
      case MentoraAvatarIdentity.company:
        return Icons.business_outlined;
      case MentoraAvatarIdentity.ai:
        return Icons.auto_awesome_outlined;
      case MentoraAvatarIdentity.system:
        return Icons.hub_outlined;
      case MentoraAvatarIdentity.guest:
        return Icons.person_add_alt_outlined;
      case MentoraAvatarIdentity.unknown:
        return Icons.help_outline;
      case MentoraAvatarIdentity.loading:
        return Icons.more_horiz_outlined;
    }
  }

  MentoraAvatarVisuals visualsOf({
    required MentoraAvatarIdentity identity,
    required MentoraAvatarState state,
  }) {
    final accent = _role(accentRoleOf(identity));
    switch (state) {
      case MentoraAvatarState.disabled:
        return MentoraAvatarVisuals(
          ground: _role(ColorRole.disabled),
          border: _role(ColorRole.disabled),
          accent: _role(ColorRole.unavailable),
          opacity: avatarDisabledVeilOpacity,
        );
      case MentoraAvatarState.archived:
        return MentoraAvatarVisuals(
          ground: _surfaces.surfaceOf(SurfaceRole.secondarySurface, _variant),
          border: _role(ColorRole.outline),
          accent: _role(ColorRole.neutral),
          opacity: avatarArchivedOpacity,
        );
      case MentoraAvatarState.unavailable:
        // Out of reach, never removed: the identity stays itself.
        return MentoraAvatarVisuals(
          ground: accent.withValues(alpha: avatarGroundOpacity),
          border: _role(ColorRole.unavailable),
          accent: accent,
          opacity: avatarUnavailableOpacity,
        );
      case MentoraAvatarState.idle:
      case MentoraAvatarState.loading:
        return MentoraAvatarVisuals(
          ground: accent.withValues(alpha: avatarGroundOpacity),
          border: accent.withValues(alpha: avatarGroundOpacity * 2),
          accent: accent,
          opacity: avatarFullOpacity,
        );
    }
  }

  Color _role(ColorRole role) => _colors.colorOf(role, _variant);
}
