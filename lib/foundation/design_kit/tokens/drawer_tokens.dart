/// The v1 materialization of the Navigation Drawer contract
/// (Component domain, chapter Structure — catalog §D7). Values live
/// here and nowhere else; upstream admission follows the registry
/// protocol.
library;

/// How a presentation of the orientation map occupies its room.
final class DrawerPresentationSpec {
  /// The room the map takes when it is open.
  final double width;

  /// How rounded the edge it shares with the content is.
  final double radius;

  /// Whether the scene behind is dimmed while the map is open.
  final bool dimsScene;

  /// Whether the map delimits itself from what surrounds it.
  final bool hasBorder;

  const DrawerPresentationSpec({
    required this.width,
    required this.radius,
    required this.dimsScene,
    required this.hasBorder,
  });
}

/// A map that never leaves belongs to the chrome that carries it.
const DrawerPresentationSpec permanentDrawerSpec = DrawerPresentationSpec(
  width: 280,
  radius: 0,
  dimsScene: false,
  hasBorder: true,
);

/// A map that comes and goes passes in front of the scene.
const DrawerPresentationSpec modalDrawerSpec = DrawerPresentationSpec(
  width: 320,
  radius: 20,
  dimsScene: true,
  hasBorder: false,
);

/// A map that can be put away stays beside the content. A rounded
/// edge and a delimiting line never coexist: what is rounded is
/// already distinct from what it stands beside.
const DrawerPresentationSpec dismissibleDrawerSpec = DrawerPresentationSpec(
  width: 300,
  radius: 20,
  dimsScene: false,
  hasBorder: false,
);

/// The veil over the scene behind an open modal map.
const double drawerScrimOpacity = 0.48;

const double drawerBorderWidth = 1;
const double drawerDividerThickness = 1;

/// The extent of one destination — the opposable reachable target
/// always prevails over it.
const double drawerDestinationExtent = 48;
const double drawerDestinationRadius = 12;
const double drawerIconSize = 22;

/// How present the ground of the place the person is in.
const double drawerSelectedGroundOpacity = 0.12;

/// A live map is fully present — nothing is taken from it.
const double drawerFullOpacity = 1;

/// A map that is put away shows nothing of itself.
const double drawerClosedOpacity = 0;

/// How far a closed map rests outside the scene, in fractions of its
/// own width.
const double drawerClosedOffset = -1;
const double drawerOpenedOffset = 0;
