/// The v1 materialization of the App Bar contract (Component domain,
/// chapter Structure — catalog §D7). Values live here and nowhere
/// else; upstream admission follows the registry protocol.
library;

/// How much room a context takes at rest, and how little it keeps
/// once the content has taken over.
final class AppBarExtentSpec {
  /// The room the structure reserves — stable, so the content below
  /// never jumps while the context collapses inside it.
  final double reservedExtent;

  /// The room the context keeps once fully collapsed.
  final double collapsedExtent;

  const AppBarExtentSpec({
    required this.reservedExtent,
    required this.collapsedExtent,
  });
}

const AppBarExtentSpec standardAppBarSpec = AppBarExtentSpec(
  reservedExtent: 56,
  collapsedExtent: 56,
);
const AppBarExtentSpec largeTitleAppBarSpec = AppBarExtentSpec(
  reservedExtent: 112,
  collapsedExtent: 56,
);
const AppBarExtentSpec compactAppBarSpec = AppBarExtentSpec(
  reservedExtent: 48,
  collapsedExtent: 48,
);

const double appBarDividerThickness = 1;
const double appBarProgressThickness = 2;
const double appBarActionSpacingFactor = 0.5;

/// How far a stretched context may exceed the room it reserved.
const double appBarMaximumStretch = 0.25;

/// A live context is fully present — nothing is taken from it.
const double appBarFullOpacity = 1;

/// A context that is no longer live is veiled.
const double appBarDisabledVeilOpacity = 0.38;
