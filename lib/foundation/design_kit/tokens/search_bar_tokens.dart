/// The v1 materialization of the Search Bar contract (Component
/// domain, chapter Structure — catalog §D7). Values live here and
/// nowhere else; upstream admission follows the registry protocol.
library;

/// How a variant of the intention bar presents itself.
final class SearchBarPresentationSpec {
  /// The extent the bar occupies.
  final double extent;

  /// How rounded it is.
  final double radius;

  /// Whether it rests on a ground of its own.
  final bool hasGround;

  /// Whether it delimits itself from what surrounds it.
  final bool hasBorder;

  const SearchBarPresentationSpec({
    required this.extent,
    required this.radius,
    required this.hasGround,
    required this.hasBorder,
  });
}

const SearchBarPresentationSpec standardSearchBarSpec =
    SearchBarPresentationSpec(
      extent: 48,
      radius: 12,
      hasGround: true,
      hasBorder: false,
    );

const SearchBarPresentationSpec expandedSearchBarSpec =
    SearchBarPresentationSpec(
      extent: 56,
      radius: 16,
      hasGround: true,
      hasBorder: false,
    );

/// A bar that rests above the content delimits itself from it.
const SearchBarPresentationSpec floatingSearchBarSpec =
    SearchBarPresentationSpec(
      extent: 48,
      radius: 100,
      hasGround: true,
      hasBorder: true,
    );

/// A bar that lives inside another structure borrows its ground.
const SearchBarPresentationSpec inlineSearchBarSpec =
    SearchBarPresentationSpec(
      extent: 40,
      radius: 12,
      hasGround: false,
      hasBorder: false,
    );

/// A bar that never leaves belongs to the chrome that carries it.
const SearchBarPresentationSpec persistentSearchBarSpec =
    SearchBarPresentationSpec(
      extent: 48,
      radius: 0,
      hasGround: true,
      hasBorder: false,
    );

const double searchBarBorderWidth = 1;
const double searchBarIconSize = 20;

/// The extent of one aid — the opposable reachable target always
/// prevails over it.
const double searchSuggestionExtent = 44;
const double searchSuggestionRadius = 10;

/// How present the ground of a held aid is.
const double searchSuggestionGroundOpacity = 0.12;

/// A live bar is fully present — nothing is taken from it.
const double searchBarFullOpacity = 1;

/// A bar that is no longer live is veiled.
const double searchBarDisabledVeilOpacity = 0.38;

const double searchBarProgressThickness = 2;
