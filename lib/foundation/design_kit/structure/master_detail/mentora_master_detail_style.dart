import '../../tokens/master_detail_tokens.dart';

/// How the relation between the two spaces is presented.
///
/// The application announces it — it alone knows the surface, the
/// moment and the platform. The relation never chooses how it appears.
enum MentoraMasterDetailPresentation {
  /// One space at a time occupies the whole room.
  stacked,

  /// The two spaces stand side by side, each with its own room.
  split,

  /// The presenting space passes in front of the one that deepens.
  overlay,
}

/// Whether the presenting space is shown.
///
/// The relation never puts it away and never brings it back: it is
/// told.
enum MentoraMasterPaneVisibility { shown, hidden }

/// The two spaces of the relation — one presents, the other deepens.
enum MentoraMasterDetailRegion { master, detail }

/// The room the spaces take, already decided by the application.
///
/// The relation never measures the surface and never computes a
/// proportion: it is given an extent, and it expresses it.
final class MentoraMasterDetailLayoutSpecification {
  /// The room the presenting space takes when it stands beside the
  /// other, or when it passes in front of it.
  final double masterExtent;

  const MentoraMasterDetailLayoutSpecification({required this.masterExtent});

  /// A room that is not a room is refused — fail closed.
  ///
  /// This verifies a floor; it never chooses an extent.
  void verify() {
    if (!masterExtent.isFinite ||
        masterExtent < masterDetailMinimumPaneExtent) {
      throw StateError(
        'A space needs room to be a space: the extent announced is '
        'below the opposable floor of $masterDetailMinimumPaneExtent.',
      );
    }
  }
}

/// Whether the presenting space takes its own room, or passes in
/// front of the space that deepens and takes none from it.
///
/// This is the single truth about how the two spaces share the room:
/// everything that places them reads it here rather than deciding
/// again.
bool standsBesideTheDetail(MentoraMasterDetailPresentation presentation) =>
    presentation == MentoraMasterDetailPresentation.split;

/// Whether the presenting space exists in the relation right now.
///
/// A space that is not shown is not built: nothing of it is reachable,
/// focusable or announced — the relation never hides a space behind a
/// veil of its own.
bool showsMaster(
  MentoraMasterDetailPresentation presentation,
  MentoraMasterPaneVisibility visibility,
) => visibility == MentoraMasterPaneVisibility.shown;

/// Whether the deepening space exists in the relation right now.
///
/// Stacked shows one space at a time: the presenting space, when it is
/// shown, takes the whole room.
bool showsDetail(
  MentoraMasterDetailPresentation presentation,
  MentoraMasterPaneVisibility visibility,
) =>
    presentation != MentoraMasterDetailPresentation.stacked ||
    visibility == MentoraMasterPaneVisibility.hidden;

/// Whether a region exists under an announced presentation and
/// visibility — the single truth every placement reads.
bool showsRegion(
  MentoraMasterDetailRegion region,
  MentoraMasterDetailPresentation presentation,
  MentoraMasterPaneVisibility visibility,
) => region == MentoraMasterDetailRegion.master
    ? showsMaster(presentation, visibility)
    : showsDetail(presentation, visibility);
