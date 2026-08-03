import '../appearance/appearance_engine.dart';
import '../tokens/design_tokens.dart';

/// The Accessibility Engine — turns the opposable requirements into
/// measured guarantees (catalog §D9, TSA-06). It consumes Tokens
/// exclusively; the thresholds are opposable to every surface.
final class AccessibilityEngine {
  const AccessibilityEngine();

  /// Font Scale preference → factor, clamped inside the opposable
  /// bounds so no combination of preferences breaks readability.
  double textScaleFor(AppearanceState state) {
    final double factor;
    switch (state.fontScale) {
      case FontScalePreference.small:
        factor = smallFontScale;
      case FontScalePreference.standard:
        factor = standardFontScale;
      case FontScalePreference.large:
        factor = largeFontScale;
      case FontScalePreference.extraLarge:
        factor = extraLargeFontScale;
    }
    return factor.clamp(minimumFontScale, maximumFontScale);
  }

  /// The text scale for fixed-height chrome (the root navigation):
  /// the content scale, bounded by the chrome token — chrome labels
  /// are redundant with their icons (AFI-04), so bounding them never
  /// removes information, while unbounded scale would break the
  /// fixed-height layout for everyone.
  double chromeTextScaleFor(AppearanceState state) {
    final contentScale = textScaleFor(state);
    return contentScale.clamp(minimumFontScale, maximumChromeFontScale);
  }

  /// The minimal reachable target — every interactive surface must
  /// honor it (Interaction Space).
  double get minimumTapTarget => interactionTokens.cibleAtteignable;

  /// The guaranteed distance around critical acts.
  double get criticalActSafeDistance => interactionTokens.distanceDeSecurite;

  /// The maximal delay for the system's "received" answer (IF-02).
  Duration get acknowledgeImmediacy => interactionTokens.immediateteAccuse;

  bool isHighContrast(AppearanceState state) {
    return state.contrast == ContrastPreference.high;
  }
}
