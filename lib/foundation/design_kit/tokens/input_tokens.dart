/// The v1 materialization of the Input contract (Component domain,
/// chapter Form — catalog §D7). Values live here and nowhere else;
/// upstream admission follows the registry protocol, like the button
/// and container forms.
library;

final class InputSizeSpec {
  /// Proposed field height — the opposable reachable target always
  /// prevails: the effective minimum is
  /// max(height, interactionTokens.cibleAtteignable).
  final double height;
  final double horizontalPadding;
  final double iconGap;
  final double iconSize;

  const InputSizeSpec({
    required this.height,
    required this.horizontalPadding,
    required this.iconGap,
    required this.iconSize,
  });
}

const InputSizeSpec smallInputSpec = InputSizeSpec(
  height: 40,
  horizontalPadding: 12,
  iconGap: 8,
  iconSize: 18,
);
const InputSizeSpec mediumInputSpec = InputSizeSpec(
  height: 48,
  horizontalPadding: 14,
  iconGap: 8,
  iconSize: 20,
);
const InputSizeSpec largeInputSpec = InputSizeSpec(
  height: 56,
  horizontalPadding: 16,
  iconGap: 10,
  iconSize: 22,
);

/// Shared field form materialization (RadiusRole.container,
/// BorderRole.outline, BorderRole.focusRing, OpacityRole.disabledVeil).
const double inputCornerRadius = 12;

/// The search field is a rounded affordance — a lane, not a box.
const double inputSearchCornerRadius = 100;
const double inputBorderWidth = 1;
const double inputFocusRingWidth = 2;
const double inputUnderlineWidth = 1;
const double inputDisabledVeilOpacity = 0.38;
const double inputProgressStroke = 2;
