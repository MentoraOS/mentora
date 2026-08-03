/// Phase 1 of the token reception: the runtime mirror of the 71
/// admitted Tokens (catalog §D1–§D4). Names only — this file RECEIVES
/// identities, it never creates a Token, never renames one, never
/// merges two (the reception rules).
library;

import 'package:flutter/widgets.dart' show Color, TextStyle;

import '../registry/semantic_roles.dart';
import '../registry/token_identity.dart';
import 'surface_elevation_tokens.dart';

TokenIdentity _color(String group, String name) => TokenIdentity(
  name: 'color.$group.$name',
  domain: TokenDomain.color,
  group: group,
  status: TokenStatus.registered,
);

TokenIdentity _typography(String group, String name) => TokenIdentity(
  name: 'typography.$group.$name',
  domain: TokenDomain.typography,
  group: group,
  status: TokenStatus.registered,
);

TokenIdentity _spacing(String name) => TokenIdentity(
  name: 'spacing.relation.$name',
  domain: TokenDomain.spacing,
  group: 'relation',
  status: TokenStatus.registered,
);

TokenIdentity _surface(String name) => TokenIdentity(
  name: 'surface.$name',
  domain: TokenDomain.elevationSurface,
  group: 'surface',
  status: TokenStatus.registered,
);

TokenIdentity _elevation(String name) => TokenIdentity(
  name: 'elevation.$name',
  domain: TokenDomain.elevationSurface,
  group: 'elevation',
  status: TokenStatus.registered,
);

String _colorGroupOf(ColorRole role) {
  switch (role) {
    case ColorRole.primary:
    case ColorRole.secondary:
    case ColorRole.supporting:
      return 'identity';
    case ColorRole.information:
    case ColorRole.success:
    case ColorRole.warning:
    case ColorRole.critical:
    case ColorRole.neutral:
      return 'signification';
    case ColorRole.unavailable:
    case ColorRole.disabled:
    case ColorRole.attention:
    case ColorRole.focus:
    case ColorRole.highlight:
      return 'state';
    case ColorRole.action:
    case ColorRole.selection:
    case ColorRole.navigation:
    case ColorRole.immersion:
      return 'interaction';
    case ColorRole.verified:
    case ColorRole.declared:
    case ColorRole.prediction:
    case ColorRole.estimate:
    case ColorRole.aiSuggestion:
      return 'trust';
    case ColorRole.background:
    case ColorRole.surface:
    case ColorRole.foreground:
    case ColorRole.outline:
    case ColorRole.divider:
      return 'environment';
  }
}

String _typographyGroupOf(TypographyRole role) {
  switch (role) {
    case TypographyRole.display:
    case TypographyRole.hero:
    case TypographyRole.pageTitle:
    case TypographyRole.sectionTitle:
    case TypographyRole.surfaceTitle:
    case TypographyRole.blockTitle:
      return 'structure';
    case TypographyRole.body:
    case TypographyRole.label:
    case TypographyRole.supporting:
    case TypographyRole.caption:
    case TypographyRole.hint:
    case TypographyRole.metadata:
    case TypographyRole.timestamp:
    case TypographyRole.footnote:
    case TypographyRole.legal:
      return 'body';
    case TypographyRole.value:
    case TypographyRole.status:
    case TypographyRole.emptyState:
    case TypographyRole.loading:
      return 'data';
    case TypographyRole.action:
    case TypographyRole.navigation:
    case TypographyRole.message:
      return 'interaction';
    case TypographyRole.aiSuggestion:
    case TypographyRole.verification:
    case TypographyRole.warning:
    case TypographyRole.critical:
    case TypographyRole.success:
      return 'signification';
  }
}

/// The typed reference of one color role — one ref per admitted name.
TokenRef<Color> colorTokenRef(ColorRole role) {
  return TokenRef<Color>(_color(_colorGroupOf(role), role.name));
}

TokenRef<TextStyle> typographyTokenRef(TypographyRole role) {
  return TokenRef<TextStyle>(_typography(_typographyGroupOf(role), role.name));
}

TokenRef<double> spacingTokenRef(SpacingRelation relation) {
  return TokenRef<double>(_spacing(relation.name));
}

TokenRef<Color> surfaceTokenRef(SurfaceRole role) {
  return TokenRef<Color>(_surface(role.name));
}

TokenRef<ElevationExpression> elevationTokenRef(ElevationMeaning meaning) {
  return TokenRef<ElevationExpression>(_elevation(meaning.name));
}

/// Every Phase 1 identity, in catalog order — 27+27+8+5+4 = 71.
List<TokenIdentity> phase1Identities() {
  return [
    for (final role in ColorRole.values) colorTokenRef(role).identity,
    for (final role in TypographyRole.values) typographyTokenRef(role).identity,
    for (final relation in SpacingRelation.values)
      spacingTokenRef(relation).identity,
    for (final role in SurfaceRole.values) surfaceTokenRef(role).identity,
    for (final meaning in ElevationMeaning.values)
      elevationTokenRef(meaning).identity,
  ];
}
