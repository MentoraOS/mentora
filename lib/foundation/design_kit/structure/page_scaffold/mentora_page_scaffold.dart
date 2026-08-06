import 'package:flutter/material.dart';

import '../../components/bottom_sheet/mentora_bottom_sheet_service.dart';
import '../../components/button/mentora_button.dart';
import '../../components/design_kit_scope.dart';
import '../../components/dialog/mentora_dialog_service.dart';
import '../../components/overlay/official_layers.dart';
import '../../components/snackbar/mentora_snackbar_service.dart';
import '../../tokens/page_scaffold_tokens.dart';
import '../app_bar/mentora_app_bar.dart';
import '../bottom_navigation/mentora_bottom_navigation.dart';
import '../navigation_drawer/mentora_navigation_drawer.dart';
import '../navigation_rail/mentora_navigation_rail.dart';
import '../search_bar/mentora_search_bar.dart';
import '../tabs/mentora_tabs.dart';
import 'mentora_page_scaffold_style.dart';
import 'mentora_page_scaffold_theme.dart';

/// The official Mentora page — the sixth Structural Component, and
/// the single point where every other structure is assembled.
///
/// A page is not a screen: it is a CONTEXT. It gathers a place, a way
/// through it, a content, the acts kept at hand and the layers that
/// come and go — and it decides none of them.
///
/// Five things it never does, and each is verified:
/// - it never knows the business: it assembles components, and knows
///   nothing of what they carry;
/// - it never knows the platform, and takes no responsive decision:
///   the application hands it a configuration already decided;
/// - it never chooses the way through the context: it is given the
///   structures, already built, and places them;
/// - it never touches the content: no padding, no scrolling, no
///   order, no widget of its own around it;
/// - it composes the temporary layers, and recreates none of them.
///
/// Every zone is TYPED, so the authority of each structure is
/// guaranteed by the compiler and not merely by a scan.
final class MentoraPageScaffold extends StatelessWidget {
  /// Where the person is — the App Bar remains its owner.
  final MentoraAppBar? place;

  /// The way through the context, beside the content — the Rail
  /// remains its owner.
  final MentoraNavigationRail? rail;

  /// The map of the space — the Drawer remains its owner, and the
  /// presentation it was given decides where it stands.
  final MentoraNavigationDrawer? orientation;

  /// The facets of the context — the Tabs remain their owner.
  final MentoraTabs? facets;

  /// The intention of finding — the Search Bar remains its owner.
  final MentoraSearchBar? intention;

  /// The principal level of the product, at the base of the page —
  /// the Bottom Navigation remains its owner.
  final MentoraBottomNavigation? bottomNavigation;

  /// The content. It belongs entirely to the application: the page
  /// wraps it in nothing and changes nothing about it.
  final Widget content;

  /// The acts a page keeps at hand — the Button remains their owner.
  final List<MentoraButton> acts;

  /// The layers that come and go. Given a service, the page composes
  /// the official host for it; given none, the layers already
  /// installed by the application keep serving. Nothing is ever
  /// recreated.
  final MentoraDialogService? dialogs;
  final MentoraBottomSheetService? sheets;
  final MentoraSnackbarService? messages;

  /// What the screen reader hears about the context itself.
  final String semanticLabel;

  const MentoraPageScaffold({
    super.key,
    required this.content,
    required this.semanticLabel,
    this.place,
    this.rail,
    this.orientation,
    this.facets,
    this.intention,
    this.bottomNavigation,
    this.acts = const [],
    this.dialogs,
    this.sheets,
    this.messages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MentoraPageScaffoldTheme.fromScope(
      DesignKitScope.of(context),
    );
    if (semanticLabel.isEmpty) {
      throw StateError(
        'A page announces the context it gathers: without a name it '
        'gathers nothing.',
      );
    }

    final visuals = theme.visuals;
    final map = orientation;
    final besideTheContent =
        map != null &&
        placementOf(map.presentation) == MentoraPageZonePlacement.beside;

    // Each zone travels as its own focus group, so moving through a
    // page follows its zones and never wanders between them.
    Widget zone(Widget child) => FocusTraversalGroup(child: child);

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (place != null) zone(place!),
        if (intention != null) zone(intention!),
        if (facets != null) zone(facets!),
        // The content is given exactly the room that is left, and
        // nothing else is done to it.
        Expanded(child: zone(content)),
        if (acts.isNotEmpty) zone(_acts(theme, visuals)),
      ],
    );

    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (besideTheContent) zone(map),
        if (rail != null) zone(rail!),
        Expanded(child: column),
      ],
    );

    // The principal level is the base of the page: it stands under
    // everything the context gathers, and never inside it.
    final frame = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: body),
        if (bottomNavigation != null) zone(bottomNavigation!),
      ],
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      child: AnimatedContainer(
        key: const Key('page-surface'),
        duration: theme.transitionDuration,
        curve: theme.curve,
        decoration: BoxDecoration(color: visuals.scene),
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: _layers(
              Stack(
                children: [
                  Positioned.fill(child: frame),
                  // A map that passes in front takes no room from the
                  // content: it covers the page it belongs to.
                  if (map != null && !besideTheContent)
                    Positioned.fill(child: zone(map)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The acts a page keeps at hand, under the line that separates
  /// them from the content they act upon.
  Widget _acts(
    MentoraPageScaffoldTheme theme,
    MentoraPageScaffoldVisuals visuals,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          key: const Key('page-acts-divider'),
          height: pageScaffoldFooterDividerThickness,
          thickness: pageScaffoldFooterDividerThickness,
          color: visuals.divider,
        ),
        Padding(
          padding: theme.actsPadding,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: theme.actsGap,
            runSpacing: theme.actsGap,
            children: acts,
          ),
        ),
      ],
    );
  }

  /// The temporary layers, composed in the official order — read from
  /// the single truth every container shares, never restated here.
  Widget _layers(Widget child) => mountOfficialLayers(
    child: child,
    dialogs: dialogs,
    sheets: sheets,
    messages: messages,
  );
}
