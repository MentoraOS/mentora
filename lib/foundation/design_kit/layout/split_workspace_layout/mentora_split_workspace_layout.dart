import 'package:flutter/widgets.dart';

import '../../structure/split_view/mentora_split_view.dart';
import '../../structure/split_view/mentora_split_view_style.dart';
import '../foundation/mentora_layout.dart';
import '../foundation/mentora_layout_assembly.dart';
import '../foundation/mentora_layout_context.dart';
import '../foundation/mentora_layout_kind.dart';

/// The official Split Workspace Layout - a room shared between
/// regions, in the working context of the product.
///
/// It is the shape of the tools people work in for hours: a way
/// through the product on one side, the thing being worked on beside
/// it, and what informs it beside that.
///
/// It decides nothing: the regions, the room each of them takes and
/// the region that takes what is left are all announced, already
/// decided, by the application.
final class MentoraSplitWorkspaceLayout extends MentoraLayout {
  @override
  final MentoraLayoutContext frame;

  /// The regions sharing the room - identities, in the order the
  /// application presents them.
  final List<MentoraSplitRegion> regions;

  /// The room each region takes, already decided.
  final MentoraSplitLayoutSpecification specification;

  /// What a person asked of a separation. The layout hands the
  /// intention on; the application decides.
  final ValueChanged<MentoraSplitResizeIntention>? onResizeRequested;

  const MentoraSplitWorkspaceLayout({
    super.key,
    required this.frame,
    required this.regions,
    required this.specification,
    this.onResizeRequested,
  });

  @override
  MentoraLayoutKind get kind => MentoraLayoutKind.splitWorkspace;

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    return MentoraLayoutSurface.shared(
      MentoraSplitView(
        regions: regions,
        layout: specification,
        onResizeRequested: onResizeRequested,
      ),
    );
  }
}
