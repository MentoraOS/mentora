/// Phase 1 bindings: the 71 admitted Tokens receive their v1 value
/// sets. Values come exclusively from the tokens layer; every binding
/// goes through the official provider — no bypass exists.
library;

import 'package:flutter/widgets.dart';

import '../registry/semantic_roles.dart';
import '../registry/token_provider.dart';
import '../registry/token_registry.dart';
import '../theme/theme_variant.dart';
import 'design_tokens.dart';
import 'surface_elevation_tokens.dart';
import 'token_catalog_phase1.dart';
import 'typography_role_tokens.dart';

ColorTokenSet _colorsFor(ThemeVariantId variant) {
  switch (variant) {
    case ThemeVariantId.light:
      return lightColorTokens;
    case ThemeVariantId.dark:
      return darkColorTokens;
    case ThemeVariantId.lightHighContrast:
      return lightHighContrastColorTokens;
    case ThemeVariantId.darkHighContrast:
      return darkHighContrastColorTokens;
  }
}

SurfaceTokenSet _surfacesFor(ThemeVariantId variant) {
  switch (variant) {
    case ThemeVariantId.light:
      return lightSurfaceTokens;
    case ThemeVariantId.dark:
      return darkSurfaceTokens;
    case ThemeVariantId.lightHighContrast:
      return lightHighContrastSurfaceTokens;
    case ThemeVariantId.darkHighContrast:
      return darkHighContrastSurfaceTokens;
  }
}

Color _colorValue(ColorRole role, ColorTokenSet tokens) {
  switch (role) {
    case ColorRole.primary:
      return tokens.primary;
    case ColorRole.secondary:
      return tokens.secondary;
    case ColorRole.supporting:
      return tokens.supporting;
    case ColorRole.information:
      return tokens.information;
    case ColorRole.success:
      return tokens.success;
    case ColorRole.warning:
      return tokens.warning;
    case ColorRole.critical:
      return tokens.critical;
    case ColorRole.neutral:
      return tokens.mutedForeground;
    case ColorRole.unavailable:
      return tokens.unavailable;
    case ColorRole.disabled:
      return tokens.disabled;
    case ColorRole.attention:
      return tokens.attention;
    case ColorRole.focus:
      return tokens.focus;
    case ColorRole.highlight:
      return tokens.highlight;
    case ColorRole.action:
      return tokens.primary;
    case ColorRole.selection:
      return tokens.highlight;
    case ColorRole.navigation:
      return tokens.mutedForeground;
    case ColorRole.immersion:
      return tokens.background;
    case ColorRole.verified:
      return tokens.success;
    case ColorRole.declared:
      return tokens.mutedForeground;
    case ColorRole.prediction:
      return tokens.information;
    case ColorRole.estimate:
      return tokens.information;
    case ColorRole.aiSuggestion:
      return tokens.secondary;
    case ColorRole.background:
      return tokens.background;
    case ColorRole.surface:
      return tokens.surface;
    case ColorRole.foreground:
      return tokens.foreground;
    case ColorRole.outline:
      return tokens.outline;
    case ColorRole.divider:
      return tokens.divider;
  }
}

TypographyRoleSpec _specFor(TypographyRole role) {
  switch (role) {
    case TypographyRole.display:
      return displaySpec;
    case TypographyRole.hero:
      return heroSpec;
    case TypographyRole.pageTitle:
      return pageTitleSpec;
    case TypographyRole.sectionTitle:
      return sectionTitleSpec;
    case TypographyRole.surfaceTitle:
      return surfaceTitleSpec;
    case TypographyRole.blockTitle:
      return blockTitleSpec;
    case TypographyRole.body:
      return bodySpec;
    case TypographyRole.label:
      return labelSpec;
    case TypographyRole.supporting:
      return supportingSpec;
    case TypographyRole.caption:
      return captionSpec;
    case TypographyRole.hint:
      return hintSpec;
    case TypographyRole.metadata:
      return metadataSpec;
    case TypographyRole.timestamp:
      return timestampSpec;
    case TypographyRole.footnote:
      return footnoteSpec;
    case TypographyRole.legal:
      return legalSpec;
    case TypographyRole.value:
      return valueSpec;
    case TypographyRole.status:
      return statusSpec;
    case TypographyRole.emptyState:
      return emptyStateSpec;
    case TypographyRole.loading:
      return loadingSpec;
    case TypographyRole.action:
      return actionTextSpec;
    case TypographyRole.navigation:
      return navigationTextSpec;
    case TypographyRole.message:
      return messageSpec;
    case TypographyRole.aiSuggestion:
      return aiSuggestionTextSpec;
    case TypographyRole.verification:
      return verificationSpec;
    case TypographyRole.warning:
      return warningTextSpec;
    case TypographyRole.critical:
      return criticalTextSpec;
    case TypographyRole.success:
      return successTextSpec;
  }
}

/// The color each written role speaks with — signification roles align
/// on their color homonyms (Typography System §3.3), muted roles stay
/// in the background of the reading.
Color _typographyColor(TypographyRole role, ColorTokenSet tokens) {
  switch (role) {
    case TypographyRole.aiSuggestion:
      return tokens.secondary;
    case TypographyRole.verification:
      return tokens.success;
    case TypographyRole.warning:
      return tokens.warning;
    case TypographyRole.critical:
      return tokens.critical;
    case TypographyRole.success:
      return tokens.success;
    case TypographyRole.action:
      return tokens.primary;
    case TypographyRole.label:
    case TypographyRole.supporting:
    case TypographyRole.caption:
    case TypographyRole.hint:
    case TypographyRole.metadata:
    case TypographyRole.timestamp:
    case TypographyRole.footnote:
    case TypographyRole.legal:
    case TypographyRole.status:
    case TypographyRole.emptyState:
    case TypographyRole.loading:
    case TypographyRole.navigation:
      return tokens.mutedForeground;
    case TypographyRole.display:
    case TypographyRole.hero:
    case TypographyRole.pageTitle:
    case TypographyRole.sectionTitle:
    case TypographyRole.surfaceTitle:
    case TypographyRole.blockTitle:
    case TypographyRole.body:
    case TypographyRole.value:
    case TypographyRole.message:
      return tokens.foreground;
  }
}

double _spacingValue(SpacingRelation relation) {
  switch (relation) {
    case SpacingRelation.proximiteLiee:
      return standardSpacingTokens.proximiteLiee;
    case SpacingRelation.separationDistincte:
      return standardSpacingTokens.separationDistincte;
    case SpacingRelation.respirationHierarchique:
      return standardSpacingTokens.respirationHierarchique;
    case SpacingRelation.contractionCalme:
      return standardSpacingTokens.contractionCalme;
    case SpacingRelation.cadenceVerticale:
      return standardSpacingTokens.cadenceVerticale;
    case SpacingRelation.respirationIntention:
      return standardSpacingTokens.respirationIntention;
    case SpacingRelation.espaceFocus:
      return standardSpacingTokens.espaceFocus;
    case SpacingRelation.aireSaisie:
      return standardSpacingTokens.aireSaisie;
  }
}

Color _surfaceValue(SurfaceRole role, SurfaceTokenSet tokens) {
  switch (role) {
    case SurfaceRole.scene:
      return tokens.scene;
    case SurfaceRole.primarySurface:
      return tokens.primarySurface;
    case SurfaceRole.secondarySurface:
      return tokens.secondarySurface;
    case SurfaceRole.protectedSurface:
      return tokens.protectedSurface;
    case SurfaceRole.immersiveSurface:
      return tokens.immersiveSurface;
  }
}

ElevationExpression _elevationValue(ElevationMeaning meaning) {
  switch (meaning) {
    case ElevationMeaning.aparte:
      return aparteExpression;
    case ElevationMeaning.decision:
      return decisionExpression;
    case ElevationMeaning.immersion:
      return immersionExpression;
    case ElevationMeaning.signalement:
      return signalementExpression;
  }
}

/// Receives and binds the 71 Phase 1 Tokens through the official
/// architecture — receive, then bind, nothing else. Idempotence is not
/// a goal: a double reception is a defect and fails closed upstream.
void receivePhase1Tokens(
  DesignTokenRegistry registry,
  DesignTokenProvider provider,
) {
  for (final identity in phase1Identities()) {
    registry.receive(identity);
  }

  for (final role in ColorRole.values) {
    provider.bind(colorTokenRef(role), {
      for (final variant in ThemeVariantId.values)
        variant: _colorValue(role, _colorsFor(variant)),
    });
  }

  for (final role in TypographyRole.values) {
    final spec = _specFor(role);
    provider.bind(typographyTokenRef(role), {
      for (final variant in ThemeVariantId.values)
        variant: TextStyle(
          fontSize: spec.size,
          fontWeight: spec.weight,
          fontStyle: spec.style,
          color: _typographyColor(role, _colorsFor(variant)),
        ),
    });
  }

  for (final relation in SpacingRelation.values) {
    provider.bindUniversal(spacingTokenRef(relation), _spacingValue(relation));
  }

  for (final role in SurfaceRole.values) {
    provider.bind(surfaceTokenRef(role), {
      for (final variant in ThemeVariantId.values)
        variant: _surfaceValue(role, _surfacesFor(variant)),
    });
  }

  for (final meaning in ElevationMeaning.values) {
    provider.bindUniversal(elevationTokenRef(meaning), _elevationValue(meaning));
  }
}
