/// The v1 materialization of the List Tile contract (Component
/// domain, chapter Entity — catalog §D7). Values live here and
/// nowhere else; upstream admission follows the registry protocol.
library;

/// How much of itself a tile gives to an entity. The padding is never
/// a distance here: it is a spacing RELATION chosen by the adapter —
/// only the proportions that have no relation live below.
final class ListTileDensitySpec {
  /// The extent under which an entity is never presented.
  final double minimumExtent;

  /// How much of the standard breathing the density keeps.
  final double breathingFactor;

  const ListTileDensitySpec({
    required this.minimumExtent,
    required this.breathingFactor,
  });
}

const ListTileDensitySpec standardListTileSpec = ListTileDensitySpec(
  minimumExtent: 64,
  breathingFactor: 1,
);
const ListTileDensitySpec compactListTileSpec = ListTileDensitySpec(
  minimumExtent: 56,
  breathingFactor: 0.75,
);
const ListTileDensitySpec largeListTileSpec = ListTileDensitySpec(
  minimumExtent: 80,
  breathingFactor: 1.5,
);
const ListTileDensitySpec denseListTileSpec = ListTileDensitySpec(
  minimumExtent: 48,
  breathingFactor: 0.5,
);

const double listTileCornerRadius = 12;
const double listTileBorderWidth = 1;
const double listTileDividerThickness = 1;

/// How present the ground of a brought-forward entity is.
const double listTileHighlightOpacity = 0.12;

/// A live entity is fully present — nothing is taken from it.
const double listTileFullOpacity = 1;

/// An entity that is no longer live is veiled.
const double listTileDisabledVeilOpacity = 0.38;

/// A past entity stays readable, never loud.
const double listTileArchivedOpacity = 0.6;

const double listTileProgressStroke = 2;
const double listTileProgressExtent = 20;
