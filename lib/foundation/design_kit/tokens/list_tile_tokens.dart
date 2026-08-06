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

/// The room a name needs to stay a name.
///
/// An entity is never presented without it: everything else is given
/// up before the words fall below this floor.
const double listTileWordsFloor = 96;

/// The room under which a second line of words says nothing.
///
/// Below it, what completes the name would be truncated to a stump:
/// the entity keeps its name alone, and keeps its dignity.
const double listTileSecondaryWordsFloor = 160;

/// What survives of the breathing when the room grows short.
///
/// The space is the FIRST thing an entity gives up — before any
/// information — and it is given up as a share of its own breathing,
/// never as a distance chosen here.
const double listTileSurrenderedGapFactor = 0.5;

const double listTileProgressStroke = 2;
const double listTileProgressExtent = 20;
