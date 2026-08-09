import '../master_detail/mentora_master_detail.dart';
import '../page_scaffold/mentora_page_scaffold.dart';
import '../split_view/mentora_split_view.dart';

/// Which channel carries the navigation that survives a change of
/// surface.
///
/// The application announces it — it alone knows the surface, the
/// platform and the moment. The workspace expresses it, and refuses
/// any disagreement between what was announced and what was given.
enum MentoraWorkspaceNavigationChannel {
  /// The working context carries no navigation of its own.
  none,

  /// The map of the space — it stands where its own presentation says.
  orientation,

  /// The principal navigation, beside the surface.
  rail,

  /// The principal level, at the base of the context.
  base,
}

/// The disposition of the working context, already decided.
///
/// The workspace never chooses a disposition, never reads a
/// breakpoint and never measures a surface: it is handed this, and it
/// verifies that what it was given says the same thing.
final class MentoraWorkspaceConfiguration {
  final MentoraWorkspaceNavigationChannel navigation;

  const MentoraWorkspaceConfiguration({
    this.navigation = MentoraWorkspaceNavigationChannel.none,
  });
}

/// The surface being worked in.
///
/// It is SEALED: a working context is exactly one of the official
/// surfaces, and the compiler — not a scan, and not a runtime check —
/// guarantees it. No `Widget?` exists here, and none ever will.
sealed class MentoraWorkspaceSurface {
  const MentoraWorkspaceSurface();

  /// One page of the product.
  const factory MentoraWorkspaceSurface.page(MentoraPageScaffold page) =
      MentoraWorkspacePageSurface;

  /// A room shared between regions.
  const factory MentoraWorkspaceSurface.shared(MentoraSplitView workspace) =
      MentoraWorkspaceSharedSurface;

  /// Two spaces in relation — one presents, the other deepens.
  const factory MentoraWorkspaceSurface.relation(MentoraMasterDetail relation) =
      MentoraWorkspaceRelationSurface;
}

final class MentoraWorkspacePageSurface extends MentoraWorkspaceSurface {
  final MentoraPageScaffold page;

  const MentoraWorkspacePageSurface(this.page);
}

final class MentoraWorkspaceSharedSurface extends MentoraWorkspaceSurface {
  final MentoraSplitView workspace;

  const MentoraWorkspaceSharedSurface(this.workspace);
}

final class MentoraWorkspaceRelationSurface extends MentoraWorkspaceSurface {
  final MentoraMasterDetail relation;

  const MentoraWorkspaceRelationSurface(this.relation);
}

/// The official zones of a working context.
///
/// They exist so that a context is always assembled the same way, in
/// every product built on Mentora: a way through the product, the
/// surface being worked in, and the layers that come and go.
enum MentoraWorkspaceZone { navigation, surface, layers }
