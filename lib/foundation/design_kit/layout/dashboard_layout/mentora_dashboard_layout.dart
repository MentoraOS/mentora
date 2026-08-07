import 'package:flutter/widgets.dart';

import '../../components/card/mentora_card.dart';
import '../../components/card/mentora_card_style.dart';
import '../../components/design_kit_scope.dart';
import '../../components/text/mentora_text.dart';
import '../../structure/app_bar/mentora_app_bar.dart';
import '../foundation/mentora_layout.dart';
import '../foundation/mentora_layout_assembly.dart';
import '../foundation/mentora_layout_context.dart';
import '../foundation/mentora_layout_kind.dart';
import '../foundation/mentora_layout_style.dart';
import '../foundation/mentora_layout_theme.dart';

/// The official Dashboard Layout - a page whose content is a set of
/// panels.
///
/// A dashboard is not a grid: it is a set of subjects, each in its own
/// official container, laid beside one another for as long as the room
/// allows and then under one another. Nothing is measured and nothing
/// is computed: the panels take the room they need, the layer's
/// breathing separates them, and the arrangement follows the reading
/// direction on its own.
///
/// It is a specialization: the only thing it builds is the set of
/// panels, from the official container, the official words and the
/// official acts - and it styles none of them.
final class MentoraDashboardLayout extends MentoraLayout {
  @override
  final MentoraLayoutContext frame;

  /// Where the person is - the App Bar remains its owner.
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
  MentoraLayoutKind get kind => MentoraLayoutKind.dashboard;

  @override
  void verify() {
    if (panels.isEmpty) {
      throw StateError(
        'A dashboard shows subjects: without one it shows nothing, and '
        'an empty page is a page - never a dashboard.',
      );
    }
    for (final panel in panels) {
      if (panel.title.isEmpty) {
        throw StateError('A panel without a subject is not a panel.');
      }
    }
  }

  @override
  MentoraLayoutSurface surfaceOf(BuildContext context) {
    final theme = MentoraLayoutTheme.fromScope(DesignKitScope.of(context));

    return MentoraLayoutSurface.page(
      semanticLabel: pageSemanticLabel,
      place: place,
      content: Wrap(
        key: const Key('dashboard-panels'),
        spacing: theme.panelGap,
        runSpacing: theme.panelGap,
        children: [for (final panel in panels) _panel(theme, panel)],
      ),
    );
  }

  /// One subject, in the official container - never a container of the
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
