import '../registry/semantic_roles.dart';

/// The v1 materialization of the Button contract (Component domain,
/// chapter Action — catalog §D7). Values live here and nowhere else;
/// upstream admission follows the registry protocol, like the
/// navigation chrome and the responsive thresholds.
final class ButtonSizeSpec {
  /// Proposed visual height — the opposable reachable target always
  /// prevails: the effective minimum is
  /// max(height, interactionTokens.cibleAtteignable).
  final double height;
  final double horizontalPadding;
  final double iconGap;
  final double iconSize;

  const ButtonSizeSpec({
    required this.height,
    required this.horizontalPadding,
    required this.iconGap,
    required this.iconSize,
  });
}

const ButtonSizeSpec smallButtonSpec = ButtonSizeSpec(
  height: 40,
  horizontalPadding: 14,
  iconGap: 6,
  iconSize: 16,
);
const ButtonSizeSpec mediumButtonSpec = ButtonSizeSpec(
  height: 48,
  horizontalPadding: 18,
  iconGap: 8,
  iconSize: 18,
);
const ButtonSizeSpec largeButtonSpec = ButtonSizeSpec(
  height: 56,
  horizontalPadding: 24,
  iconGap: 8,
  iconSize: 20,
);

/// Shared button form materialization (container radius, outline
/// border, focus ring, progress stroke — pending upstream form-token
/// admission under the same protocol).
const double buttonCornerRadius = 12;
const double buttonBorderWidth = 1;
const double buttonFocusRingWidth = 2;
const double buttonSpinnerStroke = 2;

/// The typography role every button speaks with — the action role:
/// the label says the act, at every size.
const TypographyRole buttonTypographyRole = TypographyRole.action;
