import 'package:flutter/material.dart';
import '../../navigation/mentora_navigation_announcement.dart';

import '../../components/bottom_sheet/mentora_bottom_sheet_service.dart';
import '../../components/design_kit_scope.dart';
import '../../components/dialog/mentora_dialog_service.dart';
import '../../components/overlay/official_layers.dart';
import '../../components/snackbar/mentora_snackbar_service.dart';
import '../../tokens/workspace_tokens.dart';
import '../bottom_navigation/mentora_bottom_navigation.dart';
import '../navigation_drawer/mentora_navigation_drawer.dart';
import '../navigation_drawer/mentora_navigation_drawer_style.dart';
import '../navigation_rail/mentora_navigation_rail.dart';
import 'mentora_workspace_style.dart';
import 'mentora_workspace_theme.dart';

/// The official Mentora working context — the tenth and last
/// Structural Component, and the container of the whole application.
///
/// A workspace is not a page. A page is one context of work; a
/// workspace is THE context of work: the way through the product that
/// survives every change of surface, the surface being worked in, and
/// the layers that come and go above both.
///
/// Ten things it never does, and each is verified:
/// - it never knows the business, the data or a model;
/// - it never knows the screen, the platform or a breakpoint;
/// - it never owns a component: it is given official ones, typed;
/// - it never chooses a disposition: it is handed one, already decided,
///   and it refuses any disagreement with what it was given;
/// - it never decides the navigation: it is handed a resolved state,
///   and it holds every channel to that one truth;
/// - it never decides which surface is worked in: the surface is
///   SEALED, so the compiler admits exactly one;
/// - it never mounts a layer whose service it was not given;
/// - it never creates a scroll view;
/// - it never creates a padding: the surface is handed on untouched;
/// - it never reorders, wraps or rebuilds what it assembles.
final class MentoraWorkspace extends StatelessWidget {
  /// The surface being worked in — exactly one, guaranteed by the
  /// compiler and never by a runtime check.
  final MentoraWorkspaceSurface surface;

  /// The disposition, already decided by the application.
  final MentoraWorkspaceConfiguration configuration;

  /// Where the person is, already resolved by the application.
  final MentoraNavigationAnnouncement navigation;

  /// The map of the space — the Drawer remains its owner, and the
  /// presentation it was given decides where it stands.
  final MentoraNavigationDrawer? orientation;

  /// The principal navigation beside the surface — the Rail remains
  /// its owner.
  final MentoraNavigationRail? rail;

  /// The principal level at the base of the context — the Bottom
  /// Navigation remains its owner.
  final MentoraBottomNavigation? base;

  /// The layers that come and go. Given a service, the context mounts
  /// the official host for it; given none, the layers already
  /// installed by the application keep serving.
  final MentoraDialogService? dialogs;
  final MentoraBottomSheetService? sheets;
  final MentoraSnackbarService? messages;

  /// What the screen reader hears about the working context itself.
  final String semanticLabel;

  const MentoraWorkspace({
    super.key,
    required this.surface,
    required this.navigation,
    required this.semanticLabel,
    this.configuration = const MentoraWorkspaceConfiguration(),
    this.orientation,
    this.rail,
    this.base,
    this.dialogs,
    this.sheets,
    this.messages,
  });

  /// The widget of the surface being worked in.
  ///
  /// The switch is exhaustive by construction: adding an official
  /// surface one day will not compile until it is placed here.
  Widget get _surface => switch (surface) {
    MentoraWorkspacePageSurface(:final page) => page,
    MentoraWorkspaceSharedSurface(:final workspace) => workspace,
    MentoraWorkspaceRelationSurface(:final relation) => relation,
  };

  /// Where the person is, according to one navigation channel — or
  /// null when that channel says nothing.
  String? get _announcedByChannel {
    switch (configuration.navigation) {
      case MentoraWorkspaceNavigationChannel.orientation:
        return orientation?.controller.selectedId;
      case MentoraWorkspaceNavigationChannel.rail:
        return rail?.controller?.selectedId;
      case MentoraWorkspaceNavigationChannel.base:
        return base?.selectedDestinationId;
      case MentoraWorkspaceNavigationChannel.none:
        return null;
    }
  }

  /// Whether the channel announced is the channel that was given.
  bool get _channelMatchesWhatWasGiven {
    switch (configuration.navigation) {
      case MentoraWorkspaceNavigationChannel.none:
        return orientation == null && rail == null && base == null;
      case MentoraWorkspaceNavigationChannel.orientation:
        return orientation != null && rail == null && base == null;
      case MentoraWorkspaceNavigationChannel.rail:
        return rail != null && orientation == null && base == null;
      case MentoraWorkspaceNavigationChannel.base:
        return base != null && orientation == null && rail == null;
    }
  }

  /// The contracts a working context must honor — verified once, at
  /// build, and refused when they are not met.
  void _verify() {
    if (semanticLabel.isEmpty) {
      throw StateError(
        'A working context announces itself: without a name a person '
        'never knows where they are working.',
      );
    }
    if (navigation.destinationId.isEmpty) {
      throw StateError(
        'A working context is handed where the person is, already '
        'resolved: an empty identity resolves nothing.',
      );
    }
    if (!_channelMatchesWhatWasGiven) {
      throw StateError(
        'The disposition announced is not the one this context was '
        'given: a workspace expresses a disposition, it never repairs '
        'one.',
      );
    }
    if (configuration.navigation == MentoraWorkspaceNavigationChannel.none) {
      return;
    }
    final announced = _announcedByChannel;
    if (announced == null) {
      throw StateError(
        'The way through the product says nothing about where the '
        'person is: a context holds one truth, never none.',
      );
    }
    if (announced != navigation.destinationId) {
      throw StateError(
        'The way through the product and the working context disagree '
        'about where the person is: there is exactly one truth.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MentoraWorkspaceTheme.fromScope(DesignKitScope.of(context));
    _verify();

    final map = orientation;
    // Where a map stands is read from its own presentation — the
    // single truth every container shares.
    final besideTheSurface = map != null && standsBeside(map.presentation);

    // Each zone travels as its own focus group, so moving through a
    // context follows its zones and never wanders between them.
    Widget zone(Widget child) => FocusTraversalGroup(child: child);

    final column = Column(
      spacing: workspaceZoneGap,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The surface is given exactly the room that is left, and
        // nothing else is done to it.
        Expanded(child: zone(_surface)),
        if (base != null) zone(base!),
      ],
    );

    final body = Row(
      spacing: workspaceZoneGap,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (besideTheSurface) zone(map),
        if (rail != null) zone(rail!),
        Expanded(child: column),
      ],
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      child: AnimatedContainer(
        key: const Key('workspace-surface'),
        duration: theme.transitionDuration,
        curve: theme.curve,
        decoration: BoxDecoration(color: theme.scene),
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: mountOfficialLayers(
              dialogs: dialogs,
              sheets: sheets,
              messages: messages,
              child: Stack(
                children: [
                  Positioned.fill(child: body),
                  // A map that passes in front takes no room from the
                  // surface: it covers the context it belongs to.
                  if (map != null && !besideTheSurface)
                    Positioned.fill(child: zone(map)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
