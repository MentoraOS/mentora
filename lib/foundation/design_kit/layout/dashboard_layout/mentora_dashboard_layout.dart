import 'package:flutter/widgets.dart';

import '../../components/card/mentora_card.dart';
import '../../components/card/mentora_card_style.dart';
import '../../components/design_kit_scope.dart';
import '../../components/text/mentora_text.dart';
import '../../structure/app_bar/mentora_app_bar.dart';
import '../../structure/page_scaffold/mentora_page_scaffold.dart';
import '../../structure/workspace/mentora_workspace_style.dart';
import '../mentora_layout.dart';
import '../mentora_layout_style.dart';
import '../mentora_layout_theme.dart';

/// The official Dashboard Layout — a page whose content is a set of
/// panels.
///
/// A dashboard is not a grid: it is a set of subjects, each in its own
/// official container, laid beside one another for as long as the room
/// allows and then under one another. Nothing is measured and nothing
/// is computed: the panels take the room they need, the family's
/// breathing separates them, and the arrangement follows the reading
/// direction on its own.
///
/// It composes, and nothing else: the container is a MentoraCard, the
/// subject a MentoraText, the acts MentoraButtons — the layout styles
/// none of them and knows nothing of what a panel carries.
final class MentoraDashboardLayout extends StatelessWidget {
  /// What every layout of the family is handed.
  final MentoraLayoutContext frame;

  /// Where the person is — the App Bar remains its owner.
  final MentoraAppBar? place;

  /// The subjects the dashboard shows.
  final List<MentoraDashboardPanel> panels;

  /// What the screen reader hears about the page itself.
  final String pageSemanticLabel;

  const MentoraDashboardLayout({
    super.key,
    required this.frame,
    required this.panels,
    required this.pageSemanticLabel,
    this.place,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MentoraLayoutTheme.fromScope(DesignKitScope.of(context));
    if (pageSemanticLabel.isEmpty) {
      throw StateError(
        'A page announces the context it gathers: without a name it '
        'gathers nothing.',
      );
    }
    if (panels.isEmpty) {
      throw StateError(
        'A dashboard shows subjects: without one it shows nothing, and '
        'an empty page is a page — never a dashboard.',
      );
    }
    for (final panel in panels) {
      if (panel.title.isEmpty) {
        throw StateError('A panel without a subject is not a panel.');
      }
    }

    return MentoraLayoutAssembly(
      kind: MentoraLayoutKind.dashboard,
      frame: frame,
      surface: MentoraWorkspaceSurface.page(
        MentoraPageScaffold(
          semanticLabel: pageSemanticLabel,
          place: place,
          content: Wrap(
            key: const Key('dashboard-panels'),
            spacing: theme.panelGap,
            runSpacing: theme.panelGap,
            children: [for (final panel in panels) _panel(theme, panel)],
          ),
        ),
      ),
    );
  }

  /// One subject, in the official container — never a container of the
  /// layout's own making.
  Widget _panel(MentoraLayoutTheme theme, MentoraDashboardPanel panel) {
    return MentoraCard(
      key: Key('dashboard-panel-${panel.title}'),
      variant: MentoraCardVariant.outlined,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: theme.panelLineGap,
        children: [
          MentoraText(panel.title, role: theme.panelTitleRole),
          panel.content,
          if (panel.acts.isNotEmpty)
            Wrap(spacing: theme.panelLineGap, children: panel.acts),
        ],
      ),
    );
  }
}
