/// The v1 materialization of the Avatar contract (Component domain,
/// chapter Identity — catalog §D7). Values live here and nowhere
/// else; upstream admission follows the registry protocol.
library;

final class AvatarSizeSpec {
  /// The identity's extent. An avatar carries no act, so the
  /// reachable-target floor does not apply to it — what stays
  /// opposable is its legibility.
  final double extent;
  final double markSize;

  const AvatarSizeSpec({required this.extent, required this.markSize});
}

const AvatarSizeSpec extraSmallAvatarSpec = AvatarSizeSpec(
  extent: 24,
  markSize: 12,
);
const AvatarSizeSpec smallAvatarSpec = AvatarSizeSpec(
  extent: 32,
  markSize: 16,
);
const AvatarSizeSpec mediumAvatarSpec = AvatarSizeSpec(
  extent: 40,
  markSize: 20,
);
const AvatarSizeSpec largeAvatarSpec = AvatarSizeSpec(
  extent: 56,
  markSize: 28,
);
const AvatarSizeSpec extraLargeAvatarSpec = AvatarSizeSpec(
  extent: 72,
  markSize: 36,
);
const AvatarSizeSpec doubleExtraLargeAvatarSpec = AvatarSizeSpec(
  extent: 96,
  markSize: 48,
);

/// A rounded identity keeps the same softness at every extent: the
/// radius is a proportion of the identity, never a fixed distance.
const double avatarRoundedRadiusFactor = 0.25;

/// A square identity is squared — stated here so no widget ever codes
/// the absence of a radius either.
const double avatarSquareRadius = 0;

const double avatarBorderWidth = 1;

/// How present the ground is under the identity's own accent.
const double avatarGroundOpacity = 0.12;

/// A live identity is fully present — nothing is taken from it.
const double avatarFullOpacity = 1;

/// An identity that cannot be reached right now is dimmed, never
/// removed.
const double avatarUnavailableOpacity = 0.6;

/// An identity that is no longer live is veiled.
const double avatarDisabledVeilOpacity = 0.38;

/// A past identity stays readable, never loud.
const double avatarArchivedOpacity = 0.6;

const double avatarProgressStroke = 2;
