import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';
import '../foundation/mentora_regioned_layout.dart';

/// The official Analytics Layout — the form of a space where a person
/// observes a system.
///
/// It is not a dashboard, not a grid, not a list, not a feed and not a
/// detail. It is a set of VIEWS the application announces: each one an
/// identity that never changes, a name a person hears, and what there
/// is to observe — already built.
///
/// It expresses. It never decides.
///
/// It observes nothing itself: it counts nothing, adds nothing up,
/// averages nothing, compares nothing and projects nothing. What a
/// number means, what a period covers, what went up and what went down
/// — none of that exists here, because a shape that understood its
/// views would have decided something about them.
///
/// It filters nothing, sorts nothing and remembers nothing: the views
/// are read in the order they were announced, all of them, every time.
/// A view is HANDED, never interpreted — the components remain the
/// only owners of what an observation is made of.
///
/// It builds nothing at all, and it owns no order, no identity, no
/// refusal and no surface: the regioned foundation owns them, once,
/// for every shape whose regions the application names. What this
/// shape declares is its official kind, and the word an observation
/// uses for its regions — an alias, never a second field.
final class MentoraAnalyticsLayout extends MentoraRegionedLayout {
  const MentoraAnalyticsLayout({
    super.key,
    required super.frame,
    required super.pageSemanticLabel,
    required List<MentoraContentRegion> views,
    super.place,
    super.facets,
    super.intention,
    super.acts,
  }) : super(regions: views);

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.analytics;

  /// The views a person observes — the word this shape calls its
  /// regions by. It is an alias, never a second field.
  List<MentoraContentRegion> get views => regions;
}
