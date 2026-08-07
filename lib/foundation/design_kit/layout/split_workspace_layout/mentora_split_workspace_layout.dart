import 'package:flutter/widgets.dart';

import '../../structure/split_view/mentora_split_view.dart';
import '../../structure/split_view/mentora_split_view_style.dart';
import '../../structure/workspace/mentora_workspace_style.dart';
import '../mentora_layout.dart';
import '../mentora_layout_style.dart';

/// The official Split Workspace Layout — a room shared between
/// regions, in the working context of the product.
///
/// It is the shape of the tools people work in for hours: a way
/// through the product on one side, the thing being worked on beside
/// it, and what informs it beside that. The layout builds the official
/// shared workspace so that no product ever assembles one by hand.
///
/// It decides nothing: the regions, the room each of them takes and
/// the region that takes what is left are all announced, already
/// decided, by the application.
final class MentoraSplitWorkspaceLayout extends StatelessWidget {
  /// What every layout of the family is handed.
  final MentoraLayoutContext frame;

  /// The regions sharing the room — identities, in the order the
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
  Widget build(BuildContext context) {
    return MentoraLayoutAssembly(
      kind: MentoraLayoutKind.splitWorkspace,
      frame: frame,
      surface: MentoraWorkspaceSurface.shared(
        MentoraSplitView(
          regions: regions,
          layout: specification,
          onResizeRequested: onResizeRequested,
        ),
      ),
    );
  }
}
