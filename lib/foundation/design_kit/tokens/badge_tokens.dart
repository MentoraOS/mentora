/// The v1 materialization of the Badge contract (Component domain,
/// chapter State — catalog §D7). Values live here and nowhere else;
/// upstream admission follows the registry protocol.
library;

final class BadgeSizeSpec {
  /// The badge's own height. A badge is never a target: it carries no
  /// act, so the reachable-target floor does not apply to it — what
  /// stays opposable is its legibility (font scale and contrast).
  final double height;
  final double horizontalPadding;
  final double iconSize;
  final double dotDiameter;
  final double contentGapFactor;

  const BadgeSizeSpec({
    required this.height,
    required this.horizontalPadding,
    required this.iconSize,
    required this.dotDiameter,
    required this.contentGapFactor,
  });
}

const BadgeSizeSpec smallBadgeSpec = BadgeSizeSpec(
  height: 18,
  horizontalPadding: 6,
  iconSize: 12,
  dotDiameter: 6,
  contentGapFactor: 0.5,
);
const BadgeSizeSpec mediumBadgeSpec = BadgeSizeSpec(
  height: 22,
  horizontalPadding: 8,
  iconSize: 14,
  dotDiameter: 8,
  contentGapFactor: 0.5,
);
const BadgeSizeSpec largeBadgeSpec = BadgeSizeSpec(
  height: 26,
  horizontalPadding: 10,
  iconSize: 16,
  dotDiameter: 10,
  contentGapFactor: 1,
);

/// The two form materializations: a stated label, and the fully
/// rounded shapes that read as a single mark.
const double badgeCornerRadius = 6;
const double badgeFullRadius = 100;
const double badgeBorderWidth = 1;

/// The veil that says a state is no longer live.
const double badgeDisabledVeilOpacity = 0.38;

/// How present the tinted ground of a badge is under its own accent.
const double badgeGroundOpacity = 0.12;

/// An archived state is a memory: it stays readable, never loud.
const double badgeArchivedOpacity = 0.6;

/// A live state is fully present — nothing is taken from it.
const double badgeFullOpacity = 1;

const double badgeProgressStroke = 2;
